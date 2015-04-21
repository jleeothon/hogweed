module Hogweed

  class InputWeights
    def initialize weight, learn_rate
      @weight_gen = if weight.is_a? Numeric
        Proc::new { weight }
      elsif weight.is_a? Range
        Proc::new { rand(weight) }
      end
      @learn_rate = learn_rate
    end

    def reduce input
    end

    def validate input
    end

    def back_prop input, error
    end
  end

  class ArrayInputWeights < Hogweed::InputWeights
    def initialize weight, learn_rate, count
      super weight, learn_rate
      @weights = Array.new count, @weight_gen.call
    end

    def reduce input
      input.map.with_index do |r, i|
        r * @weights[i]
      end.reduce do |m, v|
        m + v
      end
    end

    def validate input
      unless input.is_a? Array and @weights.count == input.count
        raise TypeError::new("Input must be an Array of length #{@weights.count}")
      end
    end

    def back_prop input, error
      @weights = @weights.map.with_index do |w, i|
        w + @learn_rate * error * input[i]
      end
    end
  end

  class HashInputWeights < Hogweed::InputWeights
    def initialize weight, learn_rate, inputs
      super weight, learn_rate
      @weights = hash.each.with_object({}) { |i, h| h[i] = @weight_gen.call }
    end

    def reduce input
      input.map do |k, v|
        v * @weights[k]
      end.reduce do |m, v|
        m + v
      end
    end

    def validate
      unless input.is_a? Hash and @weights.keys == input.keys
        raise TypeError::new("Input must be Hash of #{@weights.keys}")
      end
    end

    def back_prop input, error
      @weights = @weights.each.with_object(Hash::new) do |(k, w), h|
        h[k] = w + @learn_rate * error * input[k]
      end
    end

  end

end