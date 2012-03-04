[
  "hack_tree/**/*.rb",
].each do |fmask|
  Dir[File.join(File.dirname(__FILE__), fmask)].each do |fn|
    require fn
  end
end

module HackTree
  VERSION = "0.1.0"

  # Standard hacks bundled with the gem, their global names.
  STD_HACKS = [
    "hack_tree.reload",
    "ls",
  ]

  # Clear everything. See Instance#clear.
  def self.clear
    instance.clear
  end

  # Clear config. See Instance#clear_conf.
  def self.clear_conf
    instance.clear_conf
  end

  # Clear group/hack definitions ("nodes" in general). See Instance#clear_nodes.
  def self.clear_nodes
    instance.clear_nodes
  end

  # Get configuration object.
  #
  # See also:
  #
  # * HackTree::Config
  # * Instance#conf
  def self.conf
    instance.conf
  end

  # Define hacks.
  #
  #   HackTree.define do
  #     group :greeting do
  #       desc "Say hello"
  #       hack :hello do |*args|
  #         puts "Hello, %s!" % (args[0] || "world")
  #       end
  #     end
  #   end
  def self.define(&block)
    instance.define(&block)
  end

  # Enable HackTree globally.
  #
  #   >> HackTree.enable
  #   Greetings.
  #   >> c
  #   hello         # Say hello
  #   >> c.hello
  #   Hello, world!
  #
  # Options:
  #
  #   :completion => T|F      # Enable completion enhancement. Default is true.
  #   :with_std => [...]      # Load only these standard hacks.
  #   :without_std => [...]   # Load all but these standard hacks.
  #   :quiet => T|F           # Be quiet. Default is false.
  #
  # Examples:
  #
  # TODO.
  def self.enable(method_name = :c, options = {})
    options = options.dup
    o = {}

    o[k = :completion] = (v = options.delete(k)).nil?? true : v
    o[k = :with_std] = options.delete(k)
    o[k = :without_std] = options.delete(k)
    o[k = :quiet] = (v = options.delete(k)).nil?? false : v

    raise ArgumentError, "Unknown option(s): #{options.inspect}" if not options.empty?

    if o[:with_std] and o[:without_std]
      # Exception is better than warning. It has a stack trace.
      raise ArgumentError, "Options `:with_std` and `:without_std` are mutually exclusive"
    end

    @enabled_as = method_name

    if not o[:quiet]
      # Print the banner before everything. If there are warnings, we'll know they are related to us somehow.
      ::Kernel.puts "Console hacks are available. Use `%s`, `%s.hack?`, `%s.hack [args]`" % ([@enabled_as]*3)
    end

    # NOTE: This can't be put into `Instance`, it's a name-based global.
    eval <<-EOT
      module ::Kernel
        private

        def #{method_name}
          ::HackTree.instance.action
        end
      end
    EOT

    # Install completion enhancement.
    if o[:completion]
      old_proc = Readline.completion_proc

      Readline.completion_proc = lambda do |input|
        candidates = instance.completion_logic(input, :enabled_as => @enabled_as)

        # NOTE: Block result.
        if candidates.is_a? Array
          candidates
        elsif old_proc
          # Pass control.
          old_proc.call(input)
        else
          # Nothing we can do.
          []
        end
      end # @completion_proc =
    end # if o[:completion]

    # Load standard hacks.

    global_names = if (ar = o[:with_std])
      # White list.
      STD_HACKS & ar.map(&:to_s)
    elsif (ar = o[:without_std])
      # Black list.
      STD_HACKS - ar.map(&:to_s)
    else
      # Default.
      STD_HACKS
    end

    global_names.each do |global_name|
      bn = global_name.gsub(".", "/") + ".rb"
      fn = File.join(File.dirname(__FILE__), "../hacks", bn)
      load fn
    end

    nil
  end

  def self.enabled_as
    @enabled_as
  end

  def self.instance
    @instance ||= Instance.new
  end
end

#--------------------------------------- Junk

if false
      # * Using array is a reliable way to ensure a newline after the banner.
      ::Kernel.puts [
        #"",
        "Console hacks are available. Use `%s`, `%s.hack?`, `%s.hack [args]`" % ([@enabled_as]*3),
        #"",
      ]
end

if false
  # Node (group/hack) regexp without delimiters.
  NAME_REGEXP = /[a-zA-Z_]\w*/

  # Node names which can't be used due to serious reasons.
  FORBIDDEN_NAMES = [
    :inspect,
    :method_missing,
    :to_s,
  ]
end

if false
  # Create the action object.
  #
  #   module Kernel
  #     # Access our hacks via <tt>c</tt>.
  #     def c
  #       ::HackTree.action
  #     end
  #   end
  #
  #   >> c
  #   hello       # Say hello
  #   >> c.hello
  #   Hello, world!
  #
  # See also ::enable.
  def self.action
    ActionContext.new(@nodes)
  end

  # Clear self.
  def self.clear
    # Request re-initialization upon first use of any kind.
    @is_initialized = false
  end

  # Access nodes (groups/hacks) created via the DSL.
  def self.nodes
    @nodes
  end

  # See #nodes.
  def self.nodes=(ar)
    @nodes = ar
  end

  # NOTE: We need this wrapper to create private singletons.
  class << self
    private

    # On-the-fly initializer.
    def _otf_init
      return if @is_initialized

      @is_initialized = true
      @nodes = []
      @dsl_root = DslContext.new(@nodes)
    end
  end # class << self
end
