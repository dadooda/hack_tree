module HackTree
  # Configuration object.
  class Config
    # If set, substitute missing brief descriptions with this text.
    attr_accessor :brief_desc_stub

    # Aligned width of full names, Range.
    #
    #   global_name_align = 16..32
    attr_accessor :global_name_align

    # Mask to format group names (Kernel::sprintf).
    attr_accessor :group_format

    # Mask to format hack names (Kernel::sprintf).
    attr_accessor :hack_format

    # Aligned width of (namespaced) names, Range.
    #
    #   local_name_align = 16..32
    attr_accessor :local_name_align

    def initialize(attrs = {})
      attrs.each {|k, v| send("#{k}=", v)}
    end
  end
end
