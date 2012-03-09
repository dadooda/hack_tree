module HackTree
  # Context to execute the actions.
  class ActionContext
    # NOTE: No useless methods here, please.

    def initialize(instance, parent = nil)
      @instance, @parent = instance, parent

      # Suppress warnings.
      vrb, $VERBOSE = $VERBOSE, nil

      # Insert lookup routine for existing methods.
      (methods.map(&:to_s) - Node::FORBIDDEN_NAMES.map(&:to_s)).each do |method_name|
        next if not method_name =~ /\A(#{Node::NAME_REGEXP})\?{,1}\z/
        node_name = $1.to_sym
        instance_eval <<-EOT
          def #{method_name}(*args)
            if @instance.find_local_node(:#{node_name}, @parent)
              _dispatch(:#{method_name}, *args)
            else
              super
            end
          end
        EOT
      end

      # Restore warnings.
      $VERBOSE = vrb

      # Create direct methods. In case your console's completion is sane by itself, it will help.
      # IRB's default completion isn't sane yet (2012-02-25).
      @instance.nodes.select do |node|
        node.parent == @parent
      end.each do |node|
        # NOTE: This is slightly different from "existing method lookup routine" used above. Let's keep them separate.
        instance_eval <<-EOT
          def #{node.name}(*args)
            _dispatch(:#{node.name}, *args)
          end
        EOT
      end
    end

    def inspect
      # NOTES:
      #
      # * Exceptions raised here result in `(Object doesn't support #inspect)`. No other details are available, be careful.
      # * We don't return value from here, we **print** it directly.

      nodes = @instance.nodes.select {|node| node.parent == @parent}

      # Empty group?
      if nodes.empty?
        ::Kernel.puts "No groups/hacks here"
        return nil
      end

      # Not empty group, list contents.

      nodes = nodes.sort_by do |node|
        [
          node.is_a?(Node::Group) ? 0 : 1,    # Groups first.
          node.name.to_s,
        ]
      end

      # Compute name alignment width.
      names = nodes.map {|node| Tools.format_node_name(node)}
      name_align = Tools.compute_name_align(names, @instance.conf.local_name_align)

      nodes.each do |node|
        brief_desc = node.brief_desc || @instance.conf.brief_desc_stub

        fmt = "%-#{name_align}s%s"

        ::Kernel.puts(fmt % [
          Tools.format_node_name(node),
          brief_desc ? " # #{brief_desc}" : "",
        ])
      end # nodes.each

      nil
    end

    def method_missing(method_name, *args)
      _dispatch(method_name.to_sym, *args)
    end

    private

    #   _dispatch(:hello)     # Group/hack request.
    #   _dispatch(:hello?)    # Help request.
    def _dispatch(request, *args)
      raise ArgumentError, "Invalid request #{request.inspect}" if not request.to_s =~ /\A(#{Node::NAME_REGEXP})(\?{,1})\z/
      node_name = $1.to_sym
      is_question = ($2 != "")

      node = @instance.find_local_node(node_name, @parent)

      # NOTE: Method return result.
      if node
        if is_question
          # Help request.
          out = [
            node.brief_desc || @instance.conf.brief_desc_stub,
            (["", node.full_desc] if node.full_desc),
          ].flatten(1).compact

          # `out` are lines of text, eventually.
          ::Kernel.puts out.empty?? "No description, please provide one" : out

          # For groups list contents after description.
          #if node.is_a? Node::Group
          #  ::Kernel.puts ["", self.class.new(@instance, node).inspect]
          #end
        else
          # Group/hack request.
          case node
          when Node::Group
            # Create and return a new nested access context.
            self.class.new(@instance, node)
          when Node::Hack
            # Invoke hack in the context of `HackTree` instance.
            @instance.instance_exec(*args, &node.block)
          else
            raise "Unknown node class #{node.class}, SE"
          end
        end # if is_question
      else
        ::Kernel.puts "Node not found: '#{node_name}'"
      end
    end
  end # ActionContext
end
