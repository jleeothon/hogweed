module Hogweed

  class Sample

    attr_reader :output
    attr_reader :input

    # Receives the expected output and a hash or array of inputs
    # output - 1 or 0
    def initialize output, *input
      @output = output
      @input = input.freeze
    end

  end

end
