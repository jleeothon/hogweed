module Hogweed

  # A perceptron with a boolean output.
  class Perceptron

    # A hash of input names and their weights, or a list of weights
    attr_reader :weights

    # * threshold - threashold value of sum for output to be true, false otherwise
    # * learn_rate - the rate for learning at back propagation.
    # * iterations - maximum number of iterations
    # * weight - the weight for all nodes if this is numeric, or a random weight for each number
    # * input - either symbols that enumerate the inputs of this perceptron, or
    # an integer that indicates the number of inputs.
    def initialize threshold, learn_rate, iterations, weight, *input
      @threshold = threshold
      @learn_rate = learn_rate
      @iterations = iterations

      input_type = if input.count == 1 and input[0].is_a? Fixnum
        :array
      elsif input.all? { |i| i.is_a? Symbol }
        :hash
      else
        raise "inputs must be a Fixnum or a list symbols"
      end

      unless weight.is_a? Fixnum or weight.is_a? Range
        raise "weight must be Fixnum or Range"
      end

      @weights = if weight.is_a? Numeric # when fixed
        case input_type
        when :array
          Array::new input[0], weight
        when :hash
          input.each.with_object(Hash::new) { |i, h| h[i] = weight }
        end
      elsif weight.is_a? Range # when random
        case input_type
        when :array
          (0...input[0]).map { rand(weight) }
        when :hash
          input.each.with_object(Hash::new) { |i, h| h[i] = rand(weight) }
        end
      end

      @weights.freeze
    end

    # Returns 1 or 0
    def feed *input
      validate_input input
      s = if @weights.is_a? Array
        reduce_array_input input
      elsif @weights.is_a? Hash
        reduce_hash_input input
      end
      if s >= @threshold then 1 else 0 end
    end

    # Receives a list of samples
    def train *samples
      samples.each do |sample|
        raise TypeError::new("Sample is not a Hogweed::Sample") unless sample.is_a? Hogweed::Sample
        validate_input sample.input
      end
      errors = false
      @iterations.times do
        errors = false
        error = true
        # puts "weights #{@weights}"
        until error.nil?
          samples.each do |sample|
            out = self.feed *sample.input
            error = if out != sample.output
              errors = true
              # puts "#{sample.output - out}"
              sample.output - out
            else
              nil
            end
            back_propagate(sample.input, error) if error
          end
        end
        break if not errors
      end
      if errors
        raise "Did not converge"
      end
    end

    def array_input?
      @weights.is_a? Array
    end

    def hash_input?
      @weights.is_a? Hash
    end

  private

    def reduce_array_input input
      input.map.with_index do |r, i|
        r * @weights[i]
      end.reduce do |m, v|
        m + v
      end
    end

    def reduce_hash_input input
      input.map do |k, v|
        v * @weights[k]
      end.reduce do |m, v|
        m + v
      end
    end

    def validate_input input
      if self.array_input?
        unless input.is_a? Array and @weights.count == input.count
          raise TypeError::new("Input must be an array of length #{@weights.count}")
        end
      elsif self.hash_input?
        unless input.is_a? Hash and @weights.keys == input.keys
          raise TypeError::new("Input must be hash of #{@weights.keys}")
        end
      end
    end

    # Returns the error
    def back_propagate input, error
      if self.array_input?
        back_propagate_array input, error
      elsif self.hash_input?
        back_propagate_hash input, error
      end
      error
    end

    def back_propagate_array input, error
      @weights = @weights.map.with_index do |w, i|
        w + @learn_rate * error * input[i]
      end
    end

    def back_propagate_hash input, error
      @weights = @weights.each.with_object(Hash::new) do |(k, w), h|
        h[k] = w + @learn_rate * error * input[k]
      end
    end

  end

end
