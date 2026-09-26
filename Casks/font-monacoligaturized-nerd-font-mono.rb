cask "font-monacoligaturized-nerd-font-mono" do
  version "1.1.0"
  sha256 "82e6246508de65d7499b6d13d6f1f4c13862ef0d41f23a3916227bd9b74e5ad1"

  url "https://github.com/thep0y/monaco-nerd-font/releases/download/v#{version}/MonacoLigaturizedNerdFontMono.zip"
  name "MonacoLigaturized Nerd Font Mono"
  homepage "https://github.com/thep0y/monaco-nerd-font"

  font "MonacoLigaturizedNerdFontMono-Bold.ttf"
  font "MonacoLigaturizedNerdFontMono-BoldItalic.ttf"
  font "MonacoLigaturizedNerdFontMono-Italic.ttf"
  font "MonacoLigaturizedNerdFontMono-Regular.ttf"

  # No zap stanza required
end
