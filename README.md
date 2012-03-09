
Organize and share your console hacks
=====================================

Introduction
------------

HackTree lets you organize and share your console hacks in a simple and efficient way.

Console hacks (or tricks) are handy methods you use in IRB console to do repetitive tasks. HackTree gives you the following opportunities:

* Create hacks using a simple and uniform DSL.
* Describe your hacks, much like you describe tasks in Rakefiles.
* List available hacks and instantly view their descriptions right in your console.
* Share hacks with your teammates, reuse them in different projects.


Setup (Rails 3)
---------------

Add to your `Gemfile`:

~~~
gem "hack_tree"
#gem "hack_tree", :git => "git://github.com/dadooda/hack_tree.git"    # Edge version.
~~~

Install the gem:

~~~
$ bundle install
~~~

Generate essentials:

~~~
$ rails generate hack_tree
~~~


Usage
-----

Start console:

~~~
$ rails console
~~~

List available hacks:

~~~
>> c
~~~

Request help on a hack:

~~~
>> c.hello?
~~~

Use a hack:

~~~
>> c.hello
Hello, world!

>> c.hello "Ruby"
Hello, Ruby!
~~~

Create a hack (create and edit `lib/hacks/ping.rb`):

~~~
HackTree.define do
  desc "Play ping-pong"
  hack :ping do
    puts "Pong!"
  end
end
~~~

Reload hacks:

~~~
>> c.hack_tree.reload
~~~

Use your hack:

~~~
>> c.ping
Pong!
~~~

That's it for the basics, read further for more detailed information.


Definition language
-------------------

### Overview ###

The definition language has just 3 statements: `desc`, `group` and `hack`.

To enter the definition language use the wrapper block:

~~~
HackTree.define do
  ...
end
~~~

> NOTE: Inside the wrapper `self` is the object of type `HackTree::Instance`.

### Defining hacks ###

To define a hack, use `hack`. To describe it, use `desc`.

~~~
HackTree.define do
  desc "Say hello to the world"
  hack :hello do
    puts "Hello, world!"
  end
end
~~~

### Handling hack arguments ###

Hack arguments are block arguments in regular Ruby syntax.

~~~
HackTree.define do
  desc "Say hello to the world or to a specific person"
  hack :hello do |*args|
    puts "Hello, %s!" % (args[0] || "world")
  end
~~~

In Ruby 1.9 this form will also work:

~~~
HackTree.define do
  desc "Say hello to the world or to a specific person"
  hack :hello do |who = "world"|
    puts "Hello, #{who}!"
  end
end
~~~

### Using full descriptions ###

Once your hack begins to take arguments it is recommended that you extend `desc` to a full block of text. Keep the heading line, **add a few examples** and possibly some other descriptive information.

~~~
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
~~~

See it in console:

~~~
>> c
hello            # Say hello to the world or to a specific person

>> c.hello?
Say hello to the world or to a specific person

Examples:

  >> c.hello
  Hello, world!

  >> c.hello "Ruby"
  Hello, Ruby!
~~~

### Defining groups ###

Groups act as namespaces and are used to encapsulate hacks and other groups. You can nest groups to any level.

~~~
HackTree.define do
  desc "DB management"
  group :db do
    desc "List tables in native format"
    hack :tables do
      ...
    end

    desc "Get `ActiveRecord::Base.connection`"
    hack :conn do
      ...
    end
  end
end
~~~

See it in console:

~~~
>> c
db/              # DB management
...

>> c.db
conn             # Get `ActiveRecord::Base.connection`
tables           # List tables in native format
~~~

### Exiting from hacks, returning values ###

If the hack runs uninterrupted, it returns the result of its last statement.

~~~
>> HackTree.define do
  hack :five do
    5
  end
end

>> c.five
=> 5
~~~

To exit from a hack, use `next`. Unfortunately, **you cannot** use `break` or `return`, please keep that in mind.

~~~
HackTree.define do
  hack :hello do |*args|
    who = args[0] || "world"

    if who == "Java"
      puts "Goodbye, Java!"
      next false
    end

    puts "Hello, #{who}!"

    true
  end
end
~~~

In the above example, the hack should return `false` if the argument is "Java".

See it in console:

~~~
>> c.hello "Ruby"
Hello, Ruby!
=> true

>> c.hello "Java"
Goodbye, Java!
=> false
~~~

### Handling external dependencies ###

In real life it's possible that your hack depends on particular gems, environment settings, etc.

Please follow these recommendations when dealing with dependencies:

* Make sure your hack can be loaded regardless of dependencies. In other words, use dependencies **inside** the hack, not outside of it.
* Use `begin ... rescue` to catch possible unmet dependencies. Upon an unmet dependency report about it and return a noticeable result, e.g. `false`.

Example:

~~~
HackTree.define do
  group :db do
    desc "Get `ActiveRecord::Base.connection`"
    hack :conn do
      begin
        ActiveRecord::Base.connection
      rescue
        puts "Error: ActiveRecord not found"
        false
      end
    end
  end
end
~~~

### Defining classes and methods to be used in hacks ###

If your hack needs to use a custom method or class, it is recommended that you use a hierarchy of Ruby module namespaces matching your hack's name.

Example (`lib/hacks/db/tables.rb`):

~~~
HackTree.define do
  group :db do
    desc "List tables in native format"
    hack :tables do
      tables = Hacks::DB::Tables.get_tables
      tables.each do |table|
        puts table
      end
    end
  end
end

module Hacks
  module DB
    module Tables
      def self.get_tables
        # Some logic here.
        ["authors", "books"]
      end
    end
  end
end
~~~


Copyright
---------

Copyright &copy; 2012 Alex Fortuna.

Licensed under the MIT License.


Feedback
--------

Send bug reports, suggestions and criticisms through [project's page on GitHub](http://github.com/dadooda/hack_tree).
