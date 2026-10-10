cask "font-monego-nerd-font-fix" do
  version :latest
  sha256 :no_check

  url "https://github.com/cseelus/monego.git",
      branch:    "master",
      only_path: "Monego-Nerd-Font"
  name "Monego Nerd Font Fix (Monego)"
  homepage "https://github.com/cseelus/monego"

  font "Monego_Nerd_Fixed-Bold.otf"
  font "Monego_Nerd_Fixed-BoldItalic.otf"
  font "Monego_Nerd_Fixed-Italic.otf"
  font "Monego_Nerd_Fixed-Regular.otf"

  # No zap stanza required
end
