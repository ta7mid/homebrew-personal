class Vicinae < Formula
  desc "Application launcher and command palette"
  homepage "https://vicinae.com/"
  url "https://github.com/vicinaehq/vicinae/archive/refs/tags/v0.29.0.tar.gz"
  sha256 "826b226844c66ea2fa97fdf8eb580d8c8e08533c699ffa0c361cc2d171625dd3"
  license "GPL-3.0-or-later"
  head "https://github.com/vicinaehq/vicinae.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "extra-cmake-modules" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "qttools" => :build
  depends_on "cmark-gfm"
  depends_on "libqalculate"
  depends_on "node@22"
  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "qtimageformats"
  depends_on "qtkeychain"
  depends_on "qtshadertools"
  depends_on "qtsvg"

  uses_from_macos "perl" => :build

  on_macos do
    depends_on xcode: ["26.0", :build]
    depends_on arch: :arm64
    depends_on macos: :tahoe
  end

  on_linux do
    depends_on "wayland-protocols" => :build
    depends_on "libxcb"
    depends_on "libxkbcommon"
    depends_on "mesa"
    depends_on "openssl@3"
    depends_on "qtwayland"
    depends_on "systemd"
    depends_on "wayland"
    depends_on "xcb-util-keysyms"

    resource "layer-shell-qt" do
      url "https://download.kde.org/stable/plasma/6.7.5/layer-shell-qt-6.7.5.tar.xz"
      sha256 "ccdcfec7081ca956f7a52c9113a4df3a226575bfbe98b56a2a9a4d7d7e19e8f0"
    end
  end

  fails_with :gcc do
    version "14"
    cause "Requires C++23 support, including std::print and std::chrono time zones"
  end

  # Match upstream's Glaze version; the core formula tracks a newer major release.
  resource "glaze" do
    url "https://github.com/stephenberry/glaze/archive/refs/tags/v7.2.0.tar.gz"
    sha256 "17dba19ae63ae48f94994f00d49d5cb3c8f1306db1046c534c4828662490b7d4"
  end

  resource "syntax-highlighting" do
    url "https://download.kde.org/stable/frameworks/6.20/syntax-highlighting-6.20.0.tar.xz"
    sha256 "6e2862a3857c11e9a75accc6e3acfcc16f634ee878586b4d2a97b573f52bfdc0"
  end

  resource "numen" do
    url "https://github.com/vicinaehq/numen/archive/refs/tags/v0.6.1.tar.gz"
    sha256 "afb91a3953c8540a3d92ef05fb8693d982c1cd64a5d5b166e78cd7086c8b9f51"
  end

  def install
    vendor = libexec/"vendor"
    resources.each do |r|
      r.stage do
        system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
                        "-DBUILD_SHARED_LIBS=#{(r.name == "layer-shell-qt") ? "ON" : "OFF"}",
                        "-DCMAKE_INSTALL_RPATH=#{vendor}/lib",
                        "-DBUILD_TESTING=OFF",
                        "-DBUILD_TESTS=OFF",
                        "-Dglaze_DEVELOPER_MODE=OFF",
                        "-Dglaze_ENABLE_FUZZING=OFF",
                        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
                        "-DCMAKE_DISABLE_FIND_PACKAGE_XercesC=ON",
                        "-DKDE_INSTALL_QTPLUGINDIR=#{vendor}/plugins",
                        "-DKDE_INSTALL_QMLDIR=#{vendor}/qml",
                        *std_cmake_args(install_prefix: vendor)
        system "cmake", "--build", "build"
        system "cmake", "--install", "build"
      end
    end

    %w[api extension-manager].each do |package|
      cd "src/typescript/#{package}" do
        system "npm", "ci", "--no-audit", "--no-fund"
      end
    end

    args = %W[
      -DCMAKE_PREFIX_PATH=#{vendor}
      -DCMAKE_INSTALL_RPATH=#{vendor}/lib
      -DUSE_SYSTEM_GLAZE=ON
      -DUSE_SYSTEM_KF6=ON
      -DUSE_SYSTEM_NUMEN=ON
      -DUSE_SYSTEM_CMARK_GFM=ON
      -DUSE_SYSTEM_QT_KEYCHAIN=ON
      -DUSE_SYSTEM_LAYER_SHELL=ON
      -DINSTALL_NODE_MODULES=OFF
      -DVICINAE_NODE_RUNTIME_DOWNLOAD=OFF
      -DBUNDLE_SOULVER_CORE=OFF
      -DAUTO_ENABLE_AUTOSTART=OFF
      -DINSTALL_MODULES_LOAD_CONFIG=OFF
      -DIGNORE_CCACHE=ON
      -DFETCHCONTENT_FULLY_DISCONNECTED=ON
      -DVICINAE_PROVENANCE=homebrew
    ]
    args << "-DVICINAE_GIT_TAG=v#{version}" if build.stable?

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    runtime_env = { "VICINAE_NODE_BIN" => formula_opt_bin("node@22")/"node" }
    if OS.mac?
      app = prefix/"Vicinae.app"
      (app/"Contents/MacOS").install "build/bin/vicinae-browser-link",
                                   "build/bin/vicinae-server" => "Vicinae",
                                   "build/bin/vicinae"        => "vicinae-cli"
      (app/"Contents").install "build/Info.plist"
      (app/"Contents/Resources").install "extra/vicinae.icns", "extra/themes"
      system "/usr/libexec/PlistBuddy", "-c", "Add :LSEnvironment dict", app/"Contents/Info.plist"
      system "/usr/libexec/PlistBuddy", "-c",
             "Add :LSEnvironment:VICINAE_NODE_BIN string #{formula_opt_bin("node@22")}/node",
             app/"Contents/Info.plist"
      %w[Vicinae vicinae-cli vicinae-browser-link].each do |binary|
        system "/usr/bin/codesign", "--force", "--sign", "-", app/"Contents/MacOS"/binary
      end
      system "/usr/bin/codesign", "--force", "--sign", "-",
             "--entitlements", "extra/Vicinae.entitlements", app
      (bin/"vicinae").unlink
      (bin/"vicinae").write_env_script app/"Contents/MacOS/vicinae-cli", runtime_env
    else
      runtime_env["QT_PLUGIN_PATH"] = "#{vendor}/plugins:$QT_PLUGIN_PATH"
      runtime_env["QML_IMPORT_PATH"] = "#{vendor}/qml:$QML_IMPORT_PATH"
      runtime_env["XDG_DATA_DIRS"] = "#{share}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      (libexec/"vicinae").install bin/"vicinae"
      (bin/"vicinae").write_env_script libexec/"vicinae/vicinae", runtime_env
    end
  end

  service do
    run [opt_bin/"vicinae", "server"]
    keep_alive true
    log_path var/"log/vicinae.log"
    error_log_path var/"log/vicinae.log"
  end

  def caveats
    if OS.mac?
      <<~EOS
        Open Vicinae with:
          open #{opt_prefix}/Vicinae.app

        The vicinae cask provides the same command. Unlink this formula before
        switching to the cask.
      EOS
    else
      <<~EOS
        Run Vicinae in your graphical session with:
          vicinae server

        Snippet expansion and pasting require access to /dev/input and /dev/uinput.
        See https://docs.vicinae.com for your desktop's setup instructions.
      EOS
    end
  end

  test do
    script = shell_output("#{bin}/vicinae script template --title 'Homebrew Test' --lang bash --mode silent")
    assert_match "# @vicinae.title Homebrew Test", script
    assert_match "# @vicinae.mode silent", script
    (testpath/"script.sh").write script
    system bin/"vicinae", "script", "check", testpath/"script.sh"

    (testpath/"invalid.sh").write "#!/bin/bash\necho invalid\n"
    output = shell_output("#{bin}/vicinae script check #{testpath}/invalid.sh 2>&1")
    assert_match "Invalid schema version, expected 1", output
  end
end
