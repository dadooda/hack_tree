require File.expand_path("../base", __FILE__)

module HackTree
  module Node
    class Hack < Base
      # The actual code block to execute.
      attr_accessor :block
    end # Hack
  end
end
