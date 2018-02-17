require './test/test_helper'
require './lib/merch_repo'

class MerchRepoTest < MiniTest::Test
  def setup
    csv = './data/merchants.csv'
    @mr = MerchRepo.new(csv, nil)
  end

  def test_existence
    assert_instance_of MerchRepo, @mr
  end

  def test_all_method
    assert_equal 475, @mr.all.size
  end

  def test_find_by_id_method
    assert_instance_of Merchant, @mr.find_by_id(12_334_105)
    assert_nil @mr.find_by_id(-2)
  end

  def test_find_by_name_method
    assert_instance_of Merchant, @mr.find_by_name('uniford')
    assert_instance_of Merchant, @mr.find_by_name('Uniford')
    assert_nil @mr.find_by_name('Darth Plagueis the Wise')
  end

  def test_find_all_by_name
    assert_equal 8, @mr.find_all_by_name('Dar').size
    assert_equal 8, @mr.find_all_by_name('dar').size
    assert_equal 0, @mr.find_all_by_name('Darth').size
  end
end