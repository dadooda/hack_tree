HackTree.define do
  desc <<-EOT
    List groups/hacks globally
    
    Examples:

      >> c.ls /^ls$/
      ls               # List groups/hacks globally

      >> c.ls /he/
      hello            # Say hello to the world or to a specific person

      >> c.ls /person/
      hello            # Say hello to the world or to a specific person

      >> c.ls "dsl"
      dsl/             # Get domain-specific language contexts
      dsl.gemfile      # Get Bundler `Gemfile` context
      dsl.rspec        # Get RSpec specfile context

      >> c.ls "dsl.r"
      dsl.rspec        # Get RSpec specfile context
  EOT
  hack :ls do |filter = nil|
    nodes = @nodes

    # Apply filter.
    if filter
      re = case filter
      when Regexp
        filter
      when String
        Regexp.compile(Regexp.escape(filter))
      else
        raise ArgumentError, "Unsupported filter #{filter.inspect}"
      end

      nodes = nodes.select do |r|
        [
          # Logical order.
          r.global_name =~ re,
          r.brief_desc && r.brief_desc =~ re,

          # TODO: Include full as an option, later.
          #r.full_desc && r.full_desc =~ re,    # Better without full_desc, or examples may match.
        ].any?
      end
    end

    nodes = nodes.sort_by do |node|
      [
        node.is_a?(::HackTree::Node::Group) ? 0 : 1,    # Groups first.
        node.name.to_s,
      ]
    end

    # Compute name alignment width.
    names = nodes.map {|node| ::HackTree::Tools.format_node_name(node)}
    name_align = ::HackTree::Tools.compute_name_align(names, @conf.global_name_align)

    nodes.each do |node|
      brief_desc = node.brief_desc || ::HackTree.conf.brief_desc_stub

      fmt = "%-#{name_align}s%s"

      ::Kernel.puts(fmt % [
        ::HackTree::Tools.format_node_name(node, node.global_name),
        brief_desc ? " # #{brief_desc}" : "",
      ])
    end # nodes.each

    nil
  end
end
