module HackTree
  # Instance of the system.
  class Instance
    # Configuration object.
    attr_accessor :conf

    # Array of Node::Base successors.
    attr_accessor :nodes

    def initialize(attrs = {})
      clear
      attrs.each {|k, v| send("#{k}=", v)}
    end

    # Get action object.
    #
    #   >> r.action
    #   hello       # Say hello
    #   >> r.action.hello
    #   Hello, world!
    def action
      ActionContext.new(self)
    end

    # Create action object. See HackTree::action for examples.
    def action
      ActionContext.new(self)
    end

    # List direct children of <tt>node</tt>. Return Array, possibly an empty one.
    #
    #   children_of(nil)    # => [...], children of root.
    #   children_of(node)   # => [...], children of `node`.
    def children_of(parent)
      @nodes.select {|node| node.parent == parent}
    end

    def clear
      clear_conf
      clear_nodes
    end

    def clear_conf
      @conf = Config.new({
        :brief_desc_stub => "(no description)",
        :global_name_align => 16..32,
        :group_format => "%s/",
        :hack_format => "%s",
        :local_name_align => 16..32,
      })
      nil
    end

    def clear_nodes
      @nodes = []
      nil
    end

    # Perform logic needed to do IRB completion. Returns Array if completion is handled successfully, <tt>nil</tt>
    # if input is not related to HackTree.
    #
    #   completion_logic("c.he", :enabled_as => :c)    # => ["c.hello"]
    def completion_logic(input, options = {})
      o = {}
      options = options.dup

      o[k = :enabled_as] = options.delete(k)

      raise ArgumentError, "Unknown option(s): #{options.inspect}" if not options.empty?
      raise ArgumentError, "options[:enabled_as] must be given" if not o[:enabled_as]

      # Check if this input is related to us.
      if not mat = input.match(/\A#{o[:enabled_as]}\.((?:[^.].*)|)\z/)
        return nil
      end

      lookup = mat[1]

      # Parse lookup string into node name and prefix.
      global_name, prefix = if mat = lookup.match(/\A(?:([^.]*)|(.+)\.(.*?))\z/)
        if mat[1]
          # "something".
          ["", mat[1]]
        else
          # "something.other", "something.other.other.".
          [mat[2], mat[3]]
        end
      else
        # Handle no match just in case.
        ["", ""]
      end

      base = if global_name == ""
        # Base is root.
        nil
      else
        # Find a named base node. If not found, return no candidates right away.
        find_node(global_name) or return []
      end
      
      # Select sub-nodes.
      candidates = children_of(base).select do |node|
        # Select those matching `prefix`.
        node.name.to_s.index(prefix) == 0
      end.map do |node|
        # Provide 1+ candidates per item.
        case node
        when Node::Group
          # A neat trick to prevent IRB from appending a " " after group name.
          [node.name, "#{node.name}."]
        else
          [node.name]
        end.map(&:to_s)
      end.flatten(1).map do |s|
        # Convert to final names.
        [
          "#{o[:enabled_as]}.",
          ("#{global_name}." if global_name != ""),
          s,
        ].compact.join
      end

      candidates
    end

    # Define groups/hacks via the DSL. See HackTree::define for examples.
    def define(&block)
      raise "Code block expected" if not block
      DslContext.new(self).instance_eval(&block)
      nil
    end

    # Search for the node by its global name, return <tt>Node::*</tt> or <tt>nil</tt>.
    #
    #   find_node("hello")            # => Node::* or nil
    #   find_node("do.some.stuff")    # => Node::* or nil
    #
    # See also: #find_local_node.
    def find_node(global_name)
      @nodes.find {|node| node.global_name == global_name}
    end

    # Search for a local node, return <tt>Node::*</tt> or <tt>nil</tt>.
    #
    #   find_node(:hello)                   # Search at root.
    #   find_node(:hello, :parent => grp)   # Search in `grp` group.
    #
    # See also: #find_node.
    def find_local_node(name, parent)
      @nodes.find {|r| r.name == name.to_sym and r.parent == parent}
    end
  end
end
