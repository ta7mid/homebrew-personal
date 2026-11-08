cask "ghostty" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.4.0"
  sha256 arm64_linux:  "932e21c671c215e6140633027acb4e8705cef3377d335202211c32d88b5bf506",
         x86_64_linux: "50ad4f8b54a01e7d41426e7d12ffae9c88aa1c516ac140755e2bca596e1d2ae6"

  url "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v#{version}/Ghostty-#{version}-#{arch}.AppImage"
  name "Ghostty"
  desc "Terminal emulator that uses platform-native UI and GPU acceleration"
  homepage "https://ghostty.org/"

  depends_on :linux

  app_image "Ghostty-#{version}-#{arch}.AppImage", target: "Ghostty.AppImage"
  binary "Ghostty-#{version}-#{arch}.AppImage", target: "ghostty"

  zap trash: "~/.local/state/ghostty"
end
