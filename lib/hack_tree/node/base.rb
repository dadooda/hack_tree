module HackTree
  module Node
    class Base
      # Brief 1-line description, if present.
      attr_accessor :brief_desc

      # Multi-line description, if present.
      attr_accessor :full_desc

      # Node name, Symbol.
      attr_accessor :name

      # Parent group or <tt>nil</tt>.
      attr_accessor :parent

      def initialize(attrs = {})
        attrs.each {|k, v| send("#{k}=", v)}
      end

      #   global_name   # => "hello"
      #   global_name   # => "rails.db.tables"
      def global_name
        pcs = []
        cursor = self
        begin
          pcs << cursor.name
          cursor = cursor.parent
        end while cursor

        pcs.reverse.join(".")
      end
    end # Base
  end
end
