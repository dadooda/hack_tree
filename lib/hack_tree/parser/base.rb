module HackTree
  module Parser
    # Base class for parsers. Parsers generally process text into collection(s).
    class Base
      def initialize(attrs = {})
        attrs.each {|k, v| send("#{k}=", v)}
      end

      # Synonym of #process.
      def [](content)
        process(content)
      end

      def process(content)
        # NOTE: In parser meaning "content" argument name looks more solid. For mapper "data" is more appropriate. Both are okay for their cases.
        raise "Redefine `process` in your class (#{self.class})"
      end

      private

      def require_attr(attr)
        send(attr) or raise "`#{attr}` is not set"
      end
    end
  end
end
