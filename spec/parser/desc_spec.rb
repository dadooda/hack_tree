require File.expand_path("../spec_helper", __FILE__)

describe HackTree::Parser::Desc do
  before :each do
    @parser = described_class.new
  end

  it "should generally work" do
    sets = [
      ["", [nil, nil]],
      ["  ", [nil, nil]],
      [" \t\n \n ", [nil, nil]],
      ["Brief", ["Brief", nil]],
      ["   Brief\t\t\n\n", ["Brief", nil]],
      ["\n\n\nBrief\t\t\n\n", ["Brief", nil]],
      ["Brief\nFull 1  \nFull 2", ["Brief", "Full 1\nFull 2"]],
      ["Brief\nFull 1  \nFull 2\n\n    ", ["Brief", "Full 1\nFull 2"]],
      ["Brief\n\n\nFull 1\nFull 2", ["Brief", "Full 1\nFull 2"]],
      ["Brief\n  Full 1\n  Full 2", ["Brief", "Full 1\nFull 2"]],
      ["Brief\n  Full 1\n    Full 2", ["Brief", "Full 1\n  Full 2"]],
      ["Brief\n  Full 1\n\n    Full 2", ["Brief", "Full 1\n\n  Full 2"]],
      ["Brief\n  Full 1\n  \n    Full 2", ["Brief", "Full 1\n\n  Full 2"]],

      # File-based tests for more complex cases.
      [["000"], [["000,brief"], ["000,full"]]],
      [["010"], [["010,brief"], ["010,full"]]],
    ]

    path = Pathname(__FILE__[0..-4])

    sets.each do |input_spec, expected_spec|
      input = if input_spec.is_a? Array
        # Input is a file reference.
        File.read(path + "#{input_spec[0]}.txt")
      else
        # Input is plain.
        input_spec
      end

      expected = expected_spec.map do |spec|
        # Same rule as for input.
        spec.is_a?(Array) ? File.read(path + "#{spec[0]}.txt") : spec
      end

      print_on_failure("-- input_spec:#{input_spec.inspect}") do
        @parser[input].should == expected
      end
    end
  end
end
