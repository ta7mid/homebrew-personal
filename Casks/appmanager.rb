cask "appmanager" do
  arch arm: "aarch64", intel: "x86_64"

  version "3.8.0"
  sha256 arm64_linux:  "a2a990162b45fef8f28ef7f6975d796d87ea01990e9c618e9ac27048f421474f",
         x86_64_linux: "599685be011e11971a3115c38f40b00ad84b123b0dd925a655d109e0ad93fac2"

  url "https://github.com/kem-a/AppManager/releases/download/v#{version}/AppManager-#{version}-anylinux-#{arch}.AppImage"
  name "AppManager"
  desc "AppImage installer and manager"
  homepage "https://github.com/kem-a/AppManager"

  depends_on :linux

  app_image "AppManager-#{version}-anylinux-#{arch}.AppImage", target: "AppManager.AppImage"
  binary "AppManager-#{version}-anylinux-#{arch}.AppImage", target: "app-manager"

  zap trash: [
    "~/.config/autostart/com.github.AppManager.desktop",
    "~/.local/bin/app-manager",
    "~/.local/share/app-manager",
    "~/.local/share/app-manager/installations.json",
    "~/.local/share/icons/hicolor/scalable/apps/com.github.AppManager.svg",
    "~/.local/share/icons/hicolor/symbolic/apps/com.github.AppManager-symbolic.svg",
    "~/Applications/AppManager",
  ]
end
