# typed: strict

# Analysis only: Sorbet reads this file; Homebrew never loads it.
# Sources and generated DSL declarations come from the installed Homebrew, which
# already binds most DSL blocks with `T.proc.bind`. Keep these overrides focused
# on the gaps that remain, retaining upstream definitions.

# The actual cask method is private to Cask::CaskLoader::AbstractContentLoader.
# Expose only its entry point at the top level, with the block receiver upstream
# already declares on the private definition.
sig {
  params(
    header_token: String,
    options:      T.untyped,
    block:        T.nilable(T.proc.bind(Cask::DSL).void),
  ).returns(Cask::Cask)
}
def cask(header_token, **options, &block); end

class Formula
  # Homebrew extends formula instances with these helpers when running tests.
  # See Homebrew/test.rb, `formula.extend(Homebrew::Assertions)`.
  include Homebrew::Assertions

  # Nil outside `install` and `test`, which are the only places formulae use them.
  sig { returns(Pathname) }
  def buildpath; end

  sig { returns(Pathname) }
  def testpath; end

  # Nil only when no resource of that name is defined.
  sig {
    params(
      name:  T.nilable(String),
      klass: T.class_of(Resource),
      block: T.nilable(T.proc.bind(Resource).void),
    ).returns(Resource)
  }
  def resource(name = nil, klass = Resource, &block); end

  class << self
    # `test` stores the block as an instance method via `define_method`, so it
    # runs against a formula instance rather than the class.
    sig { params(block: T.proc.bind(Formula).returns(BasicObject)).void }
    def test(&block); end
  end
end

module SharedEnvExtension
  # Nil only before the build environment is set up.
  sig { returns(String) }
  def cc; end

  sig { returns(String) }
  def cxx; end
end

class Cask::DSL
  # Nil only when read before the stanza is set.
  sig { params(arg: T.nilable(T.any(String, Symbol))).returns(Cask::DSL::Version) }
  def version(arg = nil); end

  # The block runs against the caveats object, not the cask.
  sig {
    params(
      strings: String,
      block:   T.nilable(T.proc.bind(Cask::DSL::Caveats).void),
    ).returns(T.any(String, Cask::DSL::Caveats))
  }
  def caveats(*strings, &block); end
end

module Kernel
  # Missing from Sorbet's payload; see Process.spawn for the accepted forms.
  sig { params(args: T.anything, options: T.anything).returns(Integer) }
  def spawn(*args, **options); end
end
