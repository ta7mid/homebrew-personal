# frozen_string_literal: true

# Run from the tap root with Solargraph's own gem environment and the Ruby it is built against:
#   ruby="$(brew --prefix ruby)/bin/ruby"; gems="$(brew --prefix solargraph)/libexec"
#   GEM_HOME="$gems" GEM_PATH="$gems:$("$ruby" -e 'puts Gem.default_dir')" "$ruby" .solargraph/check.rb
require 'solargraph'
Dir.chdir(File.expand_path('..', __dir__))
workspace = Solargraph::Workspace.new(Dir.pwd)
files = workspace.config.calculated
raise 'Homebrew source not found: use the standard tap layout' unless files.any? { |f| f.end_with?('/Homebrew/formula.rb') }
raise 'Index exceeds max_files' unless files.size <= workspace.config.max_files
raise 'Excluded source indexed' if files.any? { |f| f.match?(%r{/Homebrew/(vendor|test|rubocops|cmd|dev-cmd)/}) }
raise 'Source parse failure' unless files.all? { |f| Solargraph::Source.load(f).parsed? }
library = Solargraph::Library.new(workspace)
library.map!
base_maps = library.bench.source_maps.to_a
api = Solargraph::ApiMap.new
checks = {
  'formula env' => ["class Probe < Formula\n def install\n  ENV.app|\n end\nend", 'append'],
  'formula inreplace' => ["class Probe < Formula\n def install\n  inreplace \"file\" do |s|\n   s.gsub!|\n  end\n end\nend", 'gsub!'],
  'service platform' => ["class Probe < Formula\n service do\n  on_macos do\n   run|\n  end\n end\nend", 'run'],
  'formula metadata' => ["class Probe < Formula\n  dep|\nend", 'depends_on'],
  'formula install path' => ["class Probe < Formula\n def install\n  bin.ins|\n end\nend", 'install'],
  'formula lookup path' => ["class Probe < Formula\n def install\n  Formula[\"ruby\"].bin.ins|\n end\nend", 'install'],
  'formula test path' => ["class Probe < Formula\n test do\n  testpath.wri|\n end\nend", 'write'],
  'formula test assertions' => ["class Probe < Formula\n test do\n  assert_e|\n end\nend", 'assert_equal'],
  'formula resource' => ["class Probe < Formula\n resource \"test\" do\n  sha|\n end\nend", 'sha256'],
  'formula platform' => ["class Probe < Formula\n on_arm do\n  dep|\n end\nend", 'depends_on'],
  'formula service' => ["class Probe < Formula\n service do\n  run|\n end\nend", 'run'],
  'formula livecheck' => ["class Probe < Formula\n livecheck do\n  reg|\n end\nend", 'regex'],
  'formula patch' => ["class Probe < Formula\n patch do\n  sha|\n end\nend", 'sha256'],
  'formula stable' => ["class Probe < Formula\n stable do\n  url|\n end\nend", 'url'],
  'formula head' => ["class Probe < Formula\n head do\n  dep|\n end\nend", 'depends_on'],
  'formula bottle' => ["class Probe < Formula\n bottle do\n  sha|\n end\nend", 'sha256'],
  'cask artifact' => ["cask \"probe\" do\n app|\nend", 'app'],
  'cask version chain' => ["cask \"probe\" do\n version.major.no_|\nend", 'no_dots'],
  'cask livecheck' => ["cask \"probe\" do\n livecheck do\n  reg|\n end\nend", 'regex'],
  'cask hook path' => ["cask \"probe\" do\n uninstall_preflight do\n  staged_path.jo|\n end\nend", 'join'],
  'cask platform' => ["cask \"probe\" do\n on_arm do\n  bin|\n end\nend", 'binary'],
  'cask language' => ["cask \"probe\" do\n language \"en\", default: true do\n  sha|\n end\nend", 'sha256'],
  'cask deeply nested hook' => ["cask \"probe\" do\n on_macos do\n  on_arm do\n   preflight do\n    staged_path.jo|\n   end\n  end\n end\nend", 'join'],
  'cask caveats' => ["cask \"probe\" do\n caveats do\n  requires_ros|\n end\nend", 'requires_rosetta']
}
failed = []
filename = File.join(Dir.pwd, 'probe.rb')
checks.each do |name, (code, expected)|
  marker = code.rindex('|')
  before, after = code[0...marker], code[(marker + 1)..]
  position = [before.count("\n"), before.lines.last.to_s.chomp.length]
  probe = Solargraph::SourceMap.map(Solargraph::Source.load_string(before + after, filename))
  api.catalog(Solargraph::Bench.new(workspace: workspace, source_maps: base_maps + [probe]))
  pins = api.clip_at(filename, position).complete.pins
  good = pins.any? { |pin| pin.name == expected }
  puts "#{good ? 'PASS' : 'FAIL'} #{name}"
  failed << name unless good
end
abort "Failed: #{failed.join(', ')}" unless failed.empty?

# Global cask entry point must not import cask-only stanzas into formulae.
formula = Solargraph::SourceMap.map(Solargraph::Source.load_string("class Probe < Formula\n  app\nend", filename))
api.catalog(Solargraph::Bench.new(workspace: workspace, source_maps: base_maps + [formula]))
raise 'Cask stanzas leaked into formula scope' if api.clip_at(filename, [1, 5]).complete.pins.any? { |p| p.name == 'app' }
raise 'Definition navigation lost upstream source' unless api.get_path_pins('Formula#bin').first.location.filename.end_with?('/Homebrew/formula.rb')
puts "PASS scope isolation and upstream definition location"

# Signature help must use a block's receiver, not just the enclosing class.
{
  'cask signature' => ["cask \"probe\" do\n depends_on(|macos: :big_sur)\nend", 'Cask::DSL#depends_on'],
  'resource signature' => ["class Probe < Formula\n resource \"test\" do\n  url(|\"https://example.com\")\n end\nend", 'Resource#url'],
  'ordinary Ruby block signature' => ["[1].each do\n [\"a\"].join(|\",\")\nend", 'Array#join']
}.each do |name, (code, expected)|
  before, after = code.split('|', 2)
  position = [before.count("\n"), before.lines.last.to_s.chomp.length]
  probe = Solargraph::SourceMap.map(Solargraph::Source.load_string(before + after, filename))
  api.catalog(Solargraph::Bench.new(workspace: workspace, source_maps: base_maps + [probe]))
  raise "Failed #{name}" unless api.clip_at(filename, position).signify.any? { |pin| pin.path == expected }
  puts "PASS #{name}"
end
puts "Verified #{checks.size} completion scenarios and #{files.size} indexed files"
