# typed: false
# frozen_string_literal: true

# Run from the tap root with `brew ruby .rubocop-lsp/check.rb`.
require "json"

Dir.chdir(File.expand_path("..", __dir__))
raise "Homebrew config not found: use the standard tap layout" unless File.exist?("../../../.rubocop.yml")

# The same wrapper `brew style` runs, so the language server and the command line cannot drift.
def rubocop(args, stdin: nil)
  command = [HOMEBREW_BREW_FILE.to_s, "rubocop", "--force-exclusion", "--format", "json", *args]
  output = if stdin
    Utils.popen_write(*command, "--stdin", stdin.fetch(:path)) { it.write(stdin.fetch(:source)) }
  else
    Utils.popen_read(*command)
  end
  JSON.parse(output[output.index("{")..])
end

def offences(result)
  result.fetch("files").flat_map { |file| file.fetch("offenses").map { [file.fetch("path"), it.fetch("cop_name")] } }
end

def cops_for(source, path)
  offences(rubocop(["--config", ".rubocop-lsp.yml"], stdin: { path:, source: })).map(&:last).uniq
end

targets = ["Formula", "Casks"]
mine = offences(rubocop(["--config", ".rubocop-lsp.yml", *targets]))
# What `brew style <tap>` runs: `Library/tap_rubocop_style.yml` and `dev-cmd/style.rb`'s default.
theirs = offences(rubocop(["--config", (HOMEBREW_LIBRARY/"tap_rubocop_style.yml").to_s,
                           "--except", "FormulaAuditStrict", *targets]))
unless mine.sort == theirs.sort
  abort "Diverged from brew style:\n  only here:  #{(mine - theirs).inspect}\n  only there: #{(theirs - mine).inspect}"
end
puts "PASS #{mine.size} offence(s) match brew style across #{targets.join(" and ")}"

# Homebrew's cops load only through `Library/.rubocop.yml`; the `.rubocop.yml` Homebrew syncs
# into taps carries neither the `require` nor the `plugins` that bring them in. Prove each
# department is live rather than merely configured.
formula = <<~RUBY
  class Probe < Formula
    desc "The probe"
    homepage "https://brew.sh/"
    url "https://brew.sh/probe-1.0.tgz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"

    def install
      FileUtils.rm_rf prefix
    end
  end
RUBY
cask = <<~RUBY
  cask "probe" do
    sha256 :no_check
    version :latest

    url "https://brew.sh/probe.dmg"
    name "Probe"
    desc "Probe utility"
    homepage "https://brew.sh/"

    app "Probe.app"
  end
RUBY

formula_cops = cops_for(formula, "Formula/probe.rb")
cask_cops = cops_for(cask, "Casks/probe.rb")
{
  "FormulaAudit/Desc" => formula_cops,
  "Homebrew/NoFileutilsRmrf" => formula_cops,
  "Cask/StanzaOrder" => cask_cops,
}.each do |cop, fired|
  abort "FAIL #{cop} did not fire; got #{fired.inspect}" unless fired.include?(cop)
  puts "PASS #{cop}"
end

# `brew style` passes `--except FormulaAuditStrict`, which the language server never sees. The
# probe formula has no `test do`, so `FormulaAuditStrict/TestPresent` would fire if it were on.
strict = formula_cops.grep(%r{\AFormulaAuditStrict/})
abort "FAIL FormulaAuditStrict is enabled: #{strict.inspect}" if strict.any?
puts "PASS FormulaAuditStrict stays disabled, matching brew style"
