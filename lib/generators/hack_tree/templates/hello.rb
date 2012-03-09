HackTree.define do
  desc <<-EOT
    Say hello to the world or to a specific person

    Examples:

      >> c.hello
      Hello, world!

      >> c.hello "Ruby"
      Hello, Ruby!
  EOT
  hack :hello do |*args|
    puts "Hello, %s!" % (args[0] || "world")
  end
end
