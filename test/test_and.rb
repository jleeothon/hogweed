require 'minitest/autorun'
require 'minitest/pride'

require 'hogweed'

class TestAnd < Minitest::Test

  def setup
    @samples = [
        Hogweed::Sample::new(0, 0, 0, 0),
        Hogweed::Sample::new(0, 0, 0, 1),
        Hogweed::Sample::new(0, 0, 1, 0),
        Hogweed::Sample::new(0, 0, 1, 1),
        Hogweed::Sample::new(0, 1, 0, 0),
        Hogweed::Sample::new(0, 1, 0, 1),
        Hogweed::Sample::new(0, 1, 1, 0),
        Hogweed::Sample::new(1, 1, 1, 1),
    ]
    @p = Hogweed::Perceptron::new(0.5, 0.3, 10000, 1, 3)
  end

  def test_train
    @p.train(*@samples)
  end

  def test_ask_000
    @p.train(*@samples)
    a = @p.feed 0, 0, 0
    assert_equal 0, a
  end

  def test_ask_001
    @p.train(*@samples)
    a = @p.feed 0, 0, 1
    assert_equal 0, a
  end

  def test_ask_010
    @p.train(*@samples)
    a = @p.feed 0, 1, 0
    assert_equal 0, a
  end

  def test_ask_011
    @p.train(*@samples)
    a = @p.feed 0, 1, 1
    assert_equal 0, a
  end

  def test_ask_100
    @p.train(*@samples)
    a = @p.feed 1, 0, 0
    assert_equal 0, a
  end

  def test_ask_101
    @p.train(*@samples)
    a = @p.feed 1, 0, 1
    assert_equal 0, a
  end

  def test_ask_110
    @p.train(*@samples)
    a = @p.feed 1, 1, 0
    assert_equal 0, a
  end

  def test_ask_111
    @p.train(*@samples)
    a = @p.feed 1, 1, 1
    assert_equal 1, a
  end

end