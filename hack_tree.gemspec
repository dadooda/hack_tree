require File.expand_path("../lib/hack_tree/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "hack_tree"
  s.version = HackTree::VERSION
  s.authors = ["Alex Fortuna"]
  s.email = ["alex.r@askit.org"]
  s.homepage = "http://github.com/dadooda/hack_tree"

  # Copy these from class's description, adjust markup.
  s.summary = %q{Organize and share your console hacks}
  s.description = %q{HackTree lets you organize and share your console hacks in a simple and efficient way.

* Create hacks using a simple and uniform DSL.
* Describe your hacks, much like you describe tasks in Rakefiles.
* List available hacks with descriptions right in your console.
* Share hacks with your teammates, reuse them in different projects.}
  # end of s.description=

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f)}
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
end
