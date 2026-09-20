# frozen_string_literal: true

# Analysis only: Solargraph reads these comments; Homebrew never loads this file.
# Sources and generated DSL declarations come from the installed Homebrew.
# Solargraph 0.60 does not consume their Sorbet return types or block bindings.
# Keep these YARD overrides focused on that gap, retaining upstream definitions.

# The actual cask method is private to Cask::CaskLoader::AbstractContentLoader.
# Expose only its entry point globally, not every Cask::DSL method.
# @!parse
#   module Kernel
#     # Declare a Homebrew cask.
#     # @param token [String]
#     # @yieldreceiver [Cask::DSL]
#     # @return [Cask::Cask]
#     def cask(token, **options, &block); end
#   end

# Homebrew extends formula instances with these helpers when running tests.
# @!parse
#   class Formula
#     include Homebrew::Assertions
#   end

# Homebrew already models the special ENV object as a class for documentation.
# Expose both build environments' helpers; the active environment is runtime-only.
# @!parse
#   class ENV
#     extend Stdenv
#     extend Superenv
#   end
# @!override SharedEnvExtension#cc
#   @return [String]
# @!override SharedEnvExtension#cxx
#   @return [String]
# @!override Formula#inreplace
#   @yieldparam s [StringInreplaceExtension]

# Formula class-level DSL blocks execute against different receivers.
# @!override Formula.test
#   @yieldreceiver [::Object<self>]
# @!override Formula.resource
#   @yieldreceiver [Resource]
# @!override Formula.patch
#   @yieldreceiver [Resource::Patch]
# @!override Formula.bottle
#   @yieldreceiver [BottleSpecification]
# @!override Formula.service
#   @yieldreceiver [Homebrew::Service]
# @!override Formula.stable
#   @yieldreceiver [SoftwareSpec]
#   @return [SoftwareSpec]
# @!override Formula.head
#   @yieldreceiver [SoftwareSpec]
# @!override Formula.livecheck
#   @yieldreceiver [Livecheck]
#   @return [Livecheck]
# @!override SoftwareSpec#resource
#   @yieldreceiver [Resource]
#   @return [Resource]
# @!override SoftwareSpec#patch
#   @yieldreceiver [Resource::Patch]
# @!override SoftwareSpec#bottle
#   @yieldreceiver [BottleSpecification]
# @!override Resource#patch
#   @yieldreceiver [Resource::Patch]
# @!override Resource#livecheck
#   @yieldreceiver [Livecheck]
# @!override Formula#resource
#   @yieldreceiver [Resource]
#   @return [Resource]

# Paths and common build helpers enable chained completion in install/test.
# @!override Formula.[]
#   @return [Formula]
# @!override Formula#prefix
#   @return [Pathname]
# @!override Formula#bin
#   @return [Pathname]
# @!override Formula#sbin
#   @return [Pathname]
# @!override Formula#lib
#   @return [Pathname]
# @!override Formula#libexec
#   @return [Pathname]
# @!override Formula#include
#   @return [Pathname]
# @!override Formula#share
#   @return [Pathname]
# @!override Formula#etc
#   @return [Pathname]
# @!override Formula#var
#   @return [Pathname]
# @!override Formula#opt_prefix
#   @return [Pathname]
# @!override Formula#opt_bin
#   @return [Pathname]
# @!override Formula#opt_lib
#   @return [Pathname]
# @!override Formula#opt_include
#   @return [Pathname]
# @!override Formula#man
#   @return [Pathname]
# @!override Formula#man1
#   @return [Pathname]
# @!override Formula#doc
#   @return [Pathname]
# @!override Formula#pkgshare
#   @return [Pathname]
# @!override Formula#buildpath
#   @return [Pathname]
# @!override Formula#testpath
#   @return [Pathname]
# @!override Formula#build
#   @return [BuildOptions]
# @!override Formula#version
#   @return [Version]
# @!override Formula#std_cmake_args
#   @return [Array<String>]
# @!override Formula#std_configure_args
#   @return [Array<String>]
# @!override Formula#std_meson_args
#   @return [Array<String>]
# @!override Homebrew::Assertions#shell_output
#   @return [String]
# @!override Homebrew::Assertions#pipe_output
#   @return [String]
# @!override Pathname#/
#   @return [Pathname]

# Cask stanza blocks and delegated values.
# @!override Cask::DSL#livecheck
#   @yieldreceiver [Livecheck]
#   @return [Livecheck]
# @!override Cask::DSL#caveats
#   @yieldreceiver [Cask::DSL::Caveats]
# @!override Cask::DSL#language
#   @yieldreceiver [self]
#   @return [String]
# @!override Cask::DSL#preflight
#   @yieldreceiver [Cask::DSL::Preflight]
# @!override Cask::DSL#postflight
#   @yieldreceiver [Cask::DSL::Postflight]
# @!override Cask::DSL#uninstall_preflight
#   @yieldreceiver [Cask::DSL::UninstallPreflight]
# @!override Cask::DSL#uninstall_postflight
#   @yieldreceiver [Cask::DSL::UninstallPostflight]
# @!override Cask::DSL#version
#   @return [Cask::DSL::Version]
# @!override Cask::DSL#arch
#   @return [String]
# @!override Cask::DSL#staged_path
#   @return [Pathname]
# @!override Cask::DSL#caskroom_path
#   @return [Pathname]
# @!override Cask::DSL#appdir
#   @return [Pathname]
# @!override Cask::DSL::Base#cask
#   @return [Cask::Cask]
# @!override Cask::DSL::Base#version
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Base#staged_path
#   @return [Pathname]
# @!override Cask::DSL::Base#caskroom_path
#   @return [Pathname]
# @!override Cask::DSL::Base#appdir
#   @return [Pathname]
# @!override Cask::Cask#version
#   @return [Cask::DSL::Version]
# @!override Cask::Cask#staged_path
#   @return [Pathname]
# @!override Cask::DSL::Version#major
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#minor
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#patch
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#major_minor
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#before_comma
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#after_comma
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#major_minor_patch
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#minor_patch
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#no_dividers
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#chomp
#   @return [Cask::DSL::Version]
# @!override Cask::DSL::Version#csv
#   @return [Array<Cask::DSL::Version>]

# These version helpers are generated with define_method and have no DSL RBI.
# See Homebrew/cask/dsl/version.rb, DIVIDERS and define_divider_methods.
# @!parse
#   class Cask::DSL::Version
#     # Remove dots from the version.
#     # @return [self]
#     def no_dots; end
#     # Remove hyphens from the version.
#     # @return [self]
#     def no_hyphens; end
#     # Remove underscores from the version.
#     # @return [self]
#     def no_underscores; end
#     # Replace dots with hyphens.
#     # @return [self]
#     def dots_to_hyphens; end
#     # Replace dots with underscores.
#     # @return [self]
#     def dots_to_underscores; end
#     # Replace hyphens with dots.
#     # @return [self]
#     def hyphens_to_dots; end
#     # Replace hyphens with underscores.
#     # @return [self]
#     def hyphens_to_underscores; end
#     # Replace underscores with dots.
#     # @return [self]
#     def underscores_to_dots; end
#     # Replace underscores with hyphens.
#     # @return [self]
#     def underscores_to_hyphens; end
#   end

# These blocks retain the cask receiver even when nested inside each other.
# @!override Cask::DSL#on_arm
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_intel
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_macos
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_linux
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_system
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_big_sur
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_monterey
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_ventura
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_sonoma
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_sequoia
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_tahoe
#   @yieldreceiver [Cask::DSL]
# @!override Cask::DSL#on_golden_gate
#   @yieldreceiver [Cask::DSL]

# OnSystem generates methods on inclusion; service's RBI omits these methods.
# @!parse
#   module OnSystem::MacOSAndLinux
#     # Evaluate the block on macOS, retaining the enclosing DSL receiver.
#     # @yieldreceiver [self]
#     def on_macos(&block); end
#     # Evaluate the block on Linux, retaining the enclosing DSL receiver.
#     # @yieldreceiver [self]
#     def on_linux(&block); end
#     # Evaluate the block on ARM, retaining the enclosing DSL receiver.
#     # @yieldreceiver [self]
#     def on_arm(&block); end
#     # Evaluate the block on Intel, retaining the enclosing DSL receiver.
#     # @yieldreceiver [self]
#     def on_intel(&block); end
#   end
