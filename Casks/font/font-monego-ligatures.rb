cask "font-monego-ligatures" do
  version :latest
  sha256 :no_check

  url "https://github.com/cseelus/monego.git",
      branch:    "master",
      only_path: "Monego-with-ligatures"
  name "Monego Ligatures"
  homepage "https://github.com/cseelus/monego"

  font "MonegoLigatures-Bold.otf"
  font "MonegoLigatures-BoldItalic.otf"
  font "MonegoLigatures-Italic.otf"
  font "MonegoLigatures-Regular.otf"

  # No zap stanza required
end
