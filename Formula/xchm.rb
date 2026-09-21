class Xchm < Formula
  desc "Compiled HTML Help (CHM) file viewer built on chmlib"
  homepage "https://github.com/rzvncj/xCHM"
  url "https://github.com/rzvncj/xCHM/archive/refs/tags/1.40.tar.gz"
  sha256 "b07e6459c90af4067d0c128cc86e8905c976b200e32cdb7cea64134609885ac3"
  license "GPL-2.0-or-later"
  head "https://github.com/rzvncj/xCHM.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "chmlib"
  depends_on "gettext" => :no_linkage
  depends_on "wxwidgets@3.2"

  uses_from_macos "libiconv" => :no_linkage

  on_linux do
    depends_on "xorg-server" => :test
  end

  def install
    args = %W[
      --disable-silent-rules
      --enable-optimize
      --with-libiconv-prefix=#{Formula["libiconv"].prefix}
      --with-libintl-prefix=#{Formula["gettext"].prefix}
      --with-wx-config=#{Formula["wxwidgets@3.2"].bin/"wx-config-3.2"}
    ]
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "Usage: xchm ", shell_output("#{bin}/xchm --help 2>&1", 255)

    resource "homebrew-example.chm" do
      url "https://raw.githubusercontent.com/dottedmag/pychm/9db50a881aa19649da100e5168d45401ee8f694b/tests/integration/example.chm"
      sha256 "729ecdc2a8c29e9672b0162d07fb01910882ce012bd5f7f1d72ac87f2df9ca54"
    end

    resource("homebrew-example.chm").stage testpath
    xvfb_pid = pid = nil

    begin
      if OS.linux? && ENV.exclude?("DISPLAY")
        ENV["DISPLAY"] = ":99"
        xvfb_pid = spawn Formula["xorg-server"].bin/"Xvfb", ENV["DISPLAY"]
        30.times do
          break if File.socket?("/tmp/.X11-unix/X99")

          sleep 1
        end
      end
      pid = spawn bin/"xchm", testpath/"example.chm"

      # A CHM the viewer parsed successfully is kept open for random access,
      # while a rejected one is closed again, so the file being held open
      # shows the document was loaded.
      chm_loaded = T.let(false, T::Boolean)
      30.times do
        sleep 1
        chm_loaded = if OS.mac?
          Utils.popen_read("lsof", "-p", pid.to_s).include?("example.chm")
        else
          Dir["/proc/#{pid}/fd/*"].any? do |fd|
            File.readlink(fd).end_with?("/example.chm")
          rescue SystemCallError
            false
          end
        end
        break if chm_loaded
      end
      assert chm_loaded, "xchm is not holding example.chm open"
    ensure
      [pid, xvfb_pid].compact.each do |p|
        Process.kill("TERM", p)
        Process.wait(p)
      rescue SystemCallError
        nil
      end
    end
  end
end
