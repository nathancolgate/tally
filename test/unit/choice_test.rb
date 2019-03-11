require File.dirname(__FILE__) + '/../test_helper'

class ChoiceTest < Test::Unit::TestCase
  fixtures :choices

  def setup
    @choice = Choice.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Choice,  @choice
  end
end
