require './lib/sales_engine'

class SalesEngineTest < Minitest::Test

  def test_existence
    se = SalesEngine.new

    assert_instance_of SalesEngine, se
  end


end