module Hogweed

  # A perceptron with a boolean output.
  class Perceptron

    # * threshold - threashold value of sum for output to be true, false otherwise
    # * learn_rate - the rate for learning at back propagation.
    # * iterations - maximum number of iterations
    # * weight - the weight for all nodes if this is numeric, or a random weight for each number
    # * input - either symbols that enumerate the inputs of this perceptron, or
    # an integer that indicates the number of inputs.
    def initialize threshold, learn_rate, iterations, weight, *input
      @threshold = threshold
      @iterations = iterations

      unless weight.is_a? Fixnum or weight.is_a? Range
        raise "weight must be Fixnum or Range"
      end

      input_type = if input.count == 1 and input[0].is_a? Fixnum
        @weights = Hogweed::ArrayInputWeights::new weight, learn_rate, input[0]
      elsif input.all? { |i| i.is_a? Symbol }
        @weights = Hogweed::HashInputWeights::new weight, learn_rate, input
      else
        raise "inputs must be a Fixnum or a list symbols"
      end

    end

    # Returns 1 or 0
    def feed *input
      @weights.validate input
      if @weights.reduce(input) >= @threshold
        1
      else
        0
      end
    end

    # Receives a list of samples
    def train *samples
      unless samples.all? { |s| s.is_a? Hogweed::Sample }
        raise TypeError::new("Sample is not a Hogweed::Sample")
      end
      errors = true
      @iterations.times do
        errors = false
        error = true
        until error.nil?
          samples.each do |sample|
            out = self.feed *sample.input
            error = if out != sample.output
              errors = true
              sample.output - out
            else
              nil
            end
            @weights.back_prop(sample.input, error) if error
          end
        end
        break if not errors
      end
      if errors
        raise "Did not converge"
      end
    end

  end

end
