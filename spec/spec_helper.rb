require "pathname"

# Load stuff.
[
  "lib/**/*.rb",
].each do |fmask|
  Dir["./#{fmask}"].each do |fn|
    ##puts "-- req '#{fn}'"
    require fn
  end
end

# TODO: When this becomes a gem, use gem instead of direct copy.
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
