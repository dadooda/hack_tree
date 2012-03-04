
Organize and share your console hacks
=====================================

WARNING! THIS IS WORK IN PROGRESS, NOTHING IS GUARANDEED TO WORK AT ALL
-----------------------------------------------------------------------

Introduction
------------

HackTree lets you organize and share your console hacks in an effective and uniform way. Blah-blah-blah.


Setup (Rails 3)
---------------

Add to your `Gemfile`:

~~~
group :development do
  gem "hack_tree"
end
~~~

Install the gem:

~~~
$ bundle install
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

Use the hack:

~~~
>> c.hello
>> c.hello "Ruby"
~~~

Place your application's hacks in `lib/hacks/`.


Copyright
---------

Copyright &copy; 2012 Alex Fortuna.

Licensed under the MIT License.


Feedback
--------

Send bug reports, suggestions and criticisms through [project's page on GitHub](http://github.com/dadooda/hack_tree).
