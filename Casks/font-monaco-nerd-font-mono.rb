cask "font-monaco-nerd-font-mono" do
  version "1.1.0"
  sha256 "d71fd284122f2626efb5367fb147c2c512bd97f01389aeb358a3bd097515d8de"

  url "https://github.com/thep0y/monaco-nerd-font/releases/download/v#{version}/MonacoNerdFontMono.zip"
  name "Monaco Nerd Font Mono"
  homepage "https://github.com/thep0y/monaco-nerd-font"

  font "MonacoNerdFontMono-Bold.ttf"
  font "MonacoNerdFontMono-BoldItalic.ttf"
  font "MonacoNerdFontMono-Italic.ttf"
  font "MonacoNerdFontMono-Regular.ttf"

  # No zap stanza required
end
