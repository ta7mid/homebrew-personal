# frozen_string_literal: true

# Solargraph 0.60.4 binds only the block at the cursor. Resolve enclosing blocks
# first so nested Homebrew DSL blocks see their parent's @yieldreceiver tags.
# Loaded only by Solargraph, never by Homebrew. No Homebrew code is executed.
module HomebrewTapSolargraph
  module NestedBlocks
    def rebind(api_map)
      closure.rebind(api_map) if closure.is_a?(Solargraph::Pin::Block)
      super
    end
  end

  # Solargraph 0.60.4's signature lookup uses the named namespace, discarding
  # the block receiver used for completion. Keep signature help in the same DSL.
  module BlockSignatures
    def signify
      return super unless closure.is_a?(Solargraph::Pin::Block)
      return [] unless cursor.argument? && cursor.recipient_node

      chain = Solargraph::Parser.chain(cursor.recipient_node, cursor.filename)
      chain.define(api_map, closure, locals).grep(Solargraph::Pin::Method)
    end
  end
end

Solargraph::Pin::Block.prepend(HomebrewTapSolargraph::NestedBlocks)
Solargraph::SourceMap::Clip.prepend(HomebrewTapSolargraph::BlockSignatures)
