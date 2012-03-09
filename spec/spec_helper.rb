# NOTE: I usually support `STANDALONE` mode in specs for Rails projects' components
#       to be able to test them without loading the environment. This project does not
#       depend on Rails *BUT* I still want a consistent RSpec file structure.
#       If this is confusing, feel free to propose something better. :)

# No Rails, we're always standalone... and free! :)
STANDALONE = 1

if STANDALONE
  # Provide root path object.
  module Standalone
    eval <<-EOT
      def self.root
        # This is an absolute path, it's perfectly safe to do a `+` and then `require`.
        Pathname("#{File.expand_path('../..', __FILE__)}")
      end
    EOT
  end

  # Load stuff.
  [
    "lib/hack_tree/**/*.rb",
  ].each do |fmask|
    Dir[Standalone.root + fmask].each do |fn|
      require fn
    end
  end
end

# When this becomes a gem, use gem instead of direct copy.
module RSpec
  module PrintOnFailure
    module Helpers
      # Output <tt>message</tt> before the failed tests in <tt>block</tt>. Useful when input and expected data
      # are defined as collections.
      #
      #   sets = [
      #     ["hello", "HELLO"],
      #     ["123", "456"],
      #   ]
      #
      #   sets.each do |input, expected|
      #     print_on_failure("-- input:'#{input}'") do
      #       input.upcase.should == expected
      #     end
      #   end
      def print_on_failure(message, &block)
        begin
          yield
        rescue Exception
          # Catch just everything, report and then re-run. The test may fail due to an exception, not necessarily unmatched expectation.
          puts message
          yield
        end
      end
    end
  end
end

begin
  # 2.x.
  RSpec.configure do |config|
    config.include ::RSpec::PrintOnFailure::Helpers
  end
rescue NameError
  # 1.3.
  Spec::Runner.configure do |config|
    config.include ::RSpec::PrintOnFailure::Helpers
  end
end
