# typed: false
# frozen_string_literal: true

# Run from the tap root with `brew ruby sorbet/check.rb`.
require "tmpdir"
require "yaml"

Dir.chdir(File.expand_path("..", __dir__))
raise "Homebrew source not found: use the standard tap layout" unless File.exist?("../../../Homebrew/formula.rb")

# Sorbet's override file takes literal paths, not globs, so a new formula or cask is silently
# left at `typed: false` unless it is added. Fail loudly instead.
dsl_files = (Dir["Formula/*.rb"] + Dir["Casks/*.rb"]).sort
# YAML reads the `true:` key as a boolean, which is what Sorbet writes and reads too.
listed = YAML.load_file("sorbet/typed_overrides.yaml").fetch(true).map { it.delete_prefix("./") }.sort
unchecked = dsl_files - listed
raise "Add to sorbet/typed_overrides.yaml: #{unchecked.join(", ")}" if unchecked.any?

stale = listed - dsl_files
raise "No such file, drop from sorbet/typed_overrides.yaml: #{stale.join(", ")}" if stale.any?

puts "PASS #{dsl_files.size} DSL file(s) raised to `typed: true`"

# Drive the same entry point Zed does, so the editor and this check cannot diverge. `brew ruby`
# needs `--` before arguments meant for the script rather than for itself.
def srb(*args)
  output = Utils.popen_read(HOMEBREW_BREW_FILE.to_s, "ruby", "sorbet/srb.rb", "--", *args, err: :out)
  output.scan(%r{^(\S+):\d+: .*? https://srb\.help/(\d+)$}).map { |path, code| [File.basename(path), code.to_i] }
end

errors = srb
abort "FAIL #{errors.size} error(s) in the tap:\n#{errors.map { "  #{it.join(" ")}" }.join("\n")}" if errors.any?
puts "PASS the tap typechecks clean"

# A clean run proves nothing on its own: it is also what `typed: false` and missing shims look
# like. Check that the DSL is really being resolved, and that real mistakes are really caught.
probes = {
  "formula DSL resolves"         => [[], <<~'RUBY'],
    class ProbeOk < Formula
      desc "Probe"
      homepage "https://brew.sh/"
      url "https://brew.sh/probe-1.0.tgz"
      sha256 "0" * 64

      resource "extra" do
        url "https://brew.sh/extra-1.0.tgz"
        sha256 "0" * 64
      end

      def install
        system ENV.cc, buildpath.glob("*.c").first.to_s
        bin.install "probe"
      end

      test do
        resource("extra").stage testpath
        assert_match version.to_s, shell_output("#{bin}/probe --version")
      end
    end
  RUBY
  "cask DSL resolves"            => [[], <<~'RUBY'],
    cask "probe-ok" do
      version "1.0"
      sha256 :no_check

      url "https://brew.sh/probe-#{version.major}.dmg"
      name "Probe"
      desc "Probe utility"
      homepage "https://brew.sh/"

      livecheck do
        url :homepage
        regex(/probe[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
      end

      app "Probe.app"

      caveats do
        requires_rosetta
      end
    end
  RUBY
  "misspelled formula stanza"    => [[7003], <<~RUBY],
    class ProbeTypo < Formula
      shar256 "0" * 64
    end
  RUBY
  "misspelled cask stanza"       => [[7003], <<~RUBY],
    cask "probe-typo" do
      homepag "https://brew.sh/"
    end
  RUBY
  "cask stanza inside a formula" => [[7003], <<~RUBY],
    class ProbeScope < Formula
      app "Probe.app"
    end
  RUBY
}

# Run the probes through the committed config so the two cannot drift, swapping only the file
# set. They live outside the tap to keep a failed run from leaving anything behind.
config = File.readlines("sorbet/config", chomp: true)
             .map(&:strip).reject { it.empty? || it.start_with?("#") || it.start_with?("--typed-override") }
Dir.mktmpdir do |dir|
  paths = probes.each_with_index.to_h do |(name, (_, source)), index|
    path = File.join(dir, "probe_#{index}.rb")
    File.write(path, source)
    [name, path]
  end
  File.write(File.join(dir, "overrides.yaml"), "true:\n#{paths.values.map { "  - '#{it}'\n" }.join}")

  found = srb("--no-config", *config, "--dir=#{dir}", "--typed-override=#{dir}/overrides.yaml")
  probes.each do |name, (expected, _)|
    actual = found.select { it.first == File.basename(paths.fetch(name)) }.map(&:last).sort
    abort "FAIL #{name}: expected #{expected.inspect}, got #{actual.inspect}" if actual != expected.sort
    puts "PASS #{name}"
  end
end
