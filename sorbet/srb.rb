# typed: false
# frozen_string_literal: true

# Analysis only: runs Homebrew's vendored Sorbet with this tap as the project root, reading
# `sorbet/config` beside this file. `brew typecheck` cannot be used instead: Homebrew's own
# config ignores `Formula` and `Casks`, so it never sees a tap's DSL files. Run this through
# `brew ruby`, which is what resolves the typecheck bundle group. No Homebrew code is executed.

# Installing the group prints progress with `ohai`, and stdout is where the language server
# speaks JSON-RPC, so keep that chatter on stderr until the setup is done.
stdout = $stdout.dup
$stdout.reopen($stderr)
# The cop guards where Homebrew's own source may install gems; this is a tap's tooling.
# rubocop:disable Homebrew/InstallBundlerGems
Utils::GemSetup.install_bundler_gems!(groups: ["typecheck"], setup_path: true)
# rubocop:enable Homebrew/InstallBundlerGems
$stdout.reopen(stdout)

args = ARGV.dup
if args.include?("--lsp")
  watchman = which("watchman", ORIGINAL_PATHS)
  args += watchman ? ["--watchman-path", watchman.to_s] : ["--disable-watchman"]
end

exec("srb", "tc", *args)
