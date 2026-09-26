cask "font-monacoligaturized-nerd-font" do
  version "1.1.0"
  sha256 "d518605d3ecabf1f61dbd332c0766dd4b855b107a06bc877617496353407a50c"

  url "https://github.com/thep0y/monaco-nerd-font/releases/download/v#{version}/MonacoLigaturizedNerdFont.zip"
  name "MonacoLigaturized Nerd Font"
  homepage "https://github.com/thep0y/monaco-nerd-font"

  font "MonacoLigaturizedNerdFont-Bold.ttf"
  font "MonacoLigaturizedNerdFont-BoldItalic.ttf"
  font "MonacoLigaturizedNerdFont-Italic.ttf"
  font "MonacoLigaturizedNerdFont-Regular.ttf"

  # No zap stanza required
end
