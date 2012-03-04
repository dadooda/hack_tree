require File.join(File.dirname(__FILE__), "base")

module HackTree
  module Parser
    # DSL <tt>desc</tt> parser.
    class Desc < Base
      # Parse description text, always return Array of 2 elements.
      #
      #   process(content)    # => [nil, nil]. Neither brief nor full description is present.
      #   process(content)    # => ["...", nil]. Brief description is present, full isn't.
      #   process(content)    # => ["...", "..."]. Both brief and full descriptions are present.
      def process(content)
        lines = content.lstrip.lines.to_a
        return [nil, nil] if lines.empty?

        # If we're here, `brief` is certainly present.
        brief = lines.shift.rstrip

        # Extract full lines with original indentation on the left.

        indented_lines = []
        gap = true    # We're skipping the gap between the brief and the full.

        lines.each do |line|
          line = line.rstrip
          next if gap and line.empty?

          # First non-empty line, the gap is over.
          gap = false

          indented_lines << line
        end

        # Compute minimum indentation level. Empty lines don't count.
        indent = indented_lines.reject(&:empty?).map do |s|
          s.match(/\A(\s*)\S/)[1].size
        end.min.to_i

        # Apply indentation.
        unindented_lines = indented_lines.map do |line|
          line.empty?? line : line[indent..-1]
        end

        # Reject empty lines at the end.
        final_lines = []
        buf = []
        unindented_lines.each do |line|
          # Accumulate empty lines.
          if line.empty?
            buf << line
            next
          end

          # Non-empty line, flush `buf` and start over.
          final_lines += buf + [line]
          buf = []
        end

        [
          brief,
          (final_lines.join("\n") if not final_lines.empty?),
        ]
      end
    end
  end # Parser
end
