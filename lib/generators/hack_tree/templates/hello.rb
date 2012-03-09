HackTree.define do
  desc <<-EOT
    Say hello to the world or to a specific person

    Examples:

      >> c.hello
      Hello, world!

      >> c.hello "Ruby"
      Hello, Ruby!
  EOT
  hack :hello do |who = "world"|
    puts "Hello, #{who}!"
  end
end
