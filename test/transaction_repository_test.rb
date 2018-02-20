require_relative 'test_helper'
require_relative '../lib/transaction_repository'
class TransactionRepositoryTest < MiniTest::Test
  def setup
    @tr  = TransactionRepository.new
    @csv = './data/transactions.csv'
    @tr.from_csv(@csv)
  end

  def test_existence
    assert_instance_of TransactionRepository, @tr
  end

  def test_all_method
    assert_equal 4985, @tr.all.size
  end

  def test_find_by_id_method
    assert_nil @tr.find_by_id(-1)
    assert_equal 'failed', @tr.find_by_id(66).result
  end
end