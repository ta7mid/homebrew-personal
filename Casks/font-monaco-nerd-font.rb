cask "font-monaco-nerd-font" do
  version "1.1.0"
  sha256 "8fe12ea548e81b216698a645f450506534cfab6279fcd9fb89a9ec21a41038ae"

  url "https://github.com/thep0y/monaco-nerd-font/releases/download/v#{version}/MonacoNerdFont.zip"
  name "Monaco Nerd Font"
  homepage "https://github.com/thep0y/monaco-nerd-font"

  font "MonacoNerdFont-Bold.ttf"
  font "MonacoNerdFont-BoldItalic.ttf"
  font "MonacoNerdFont-Italic.ttf"
  font "MonacoNerdFont-Regular.ttf"

  # No zap stanza required
end
