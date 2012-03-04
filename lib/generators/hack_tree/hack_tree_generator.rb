class HackTreeGenerator < Rails::Generators::Base   #:nodoc:
  source_root File.join(File.dirname(__FILE__), "templates")

  def go
    copy_file (bn = "hack_tree.rb"), "config/initializers/#{bn}"
    copy_file (bn = "hello.rb"), "lib/hacks/#{bn}"
    readme "INSTALL"
  end
end
