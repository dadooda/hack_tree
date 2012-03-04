module HackTree
  module Tools
    #   compute_name_align(["alfa", "bravo"], 8..16)    # => 8
    def self.compute_name_align(names, limit)
      (v = eval(vn = "names")).is_a?(klass = Array) or raise ArgumentError, "`#{vn}` must be #{klass}, #{v.class} (#{v.inspect}) given"
      (v = eval(vn = "limit")).is_a?(klass = Range) or raise ArgumentError, "`#{vn}` must be #{klass}, #{v.class} (#{v.inspect}) given"

      computed = names.map(&:size).select {|n| n <= limit.max}.max.to_i

      [limit.min, computed].max
    end

    #   format_node_name(node)          # => "hello"
    #   format_node_name(node, "yo")    # => "yo"
    def self.format_node_name(node, name = nil)
      case node
      when Node::Group
        ::HackTree.conf.group_format
      when Node::Hack
        ::HackTree.conf.hack_format
      else
        raise ArgumentError, "Unknown node class #{node.class}, SE" 
      end % (name || node.name).to_s
    end
  end
end
