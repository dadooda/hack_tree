module HackTree
  # Definition DSL context.
  class DslContext
    # NOTE: Please keep methods to an absolute minimum. This is the DSL, I want as little confusion as possible.

    # Initialize self.
    def initialize(instance, parent = nil)
      @instance, @parent = instance, parent
      @desc_parser = Parser::Desc.new
    end

    def desc(text)
      @brief_desc, @full_desc = @desc_parser[text]
    end

    def group(name, &block)
      raise "Code block expected" if not block

      name = name.to_sym

      # TODO: Check forbidden names.

      # It is allowed to reopen the groups. Find the named group.
      group = @instance.nodes.find {|r| r.name == name}

      if group
        if not group.is_a? Node::Group
          raise "Node '#{name}' already exists and it's not a group"
        end

        # It is allowed to redefine group description with another description.
        # If there is no description, the original one is retained on reopen.
        if @brief_desc
          group.brief_desc = @brief_desc
          group.full_desc = @full_desc
        end
      else
        # Create.
        group = Node::Group.new({
          :brief_desc => @brief_desc,
          :full_desc => @full_desc,
          :name => name,
          :parent => @parent,
        })

        @instance.nodes << group
      end

      # Clear last used descriptions.
      @brief_desc = @full_desc = nil

      # Create sub-context and dive into it.
      context = self.class.new(@instance, group)
      context.instance_eval(&block)
    end

    def hack(name, &block)
      raise "Code block expected" if not block

      name = name.to_sym

      # TODO: Check forbidden names.

      # It is allowed to redefine the hacks. Find the named hack.
      hack = @instance.nodes.find {|r| r.name == name}

      if hack
        if not hack.is_a? Node::Hack
          raise "Node '#{name}' already exists and it's not a hack"
        end

        # Modify hack.
        hack.brief_desc = @brief_desc
        hack.full_desc = @full_desc
        hack.block = block
      else
        # Create.
        hack = Node::Hack.new({
          :block => block,
          :brief_desc => @brief_desc,
          :full_desc => @full_desc,
          :name => name,
          :parent => @parent,
        })

        @instance.nodes << hack
      end

      # Clear last used descriptions.
      @brief_desc = @full_desc = nil

      nil
    end
  end # DslContext
end
