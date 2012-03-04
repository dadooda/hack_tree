require File.join(File.dirname(__FILE__), "base")

module HackTree
  module Node
    class Hack < Base
      # The actual code block to execute.
      attr_accessor :block
    end # Hack
  end
end
