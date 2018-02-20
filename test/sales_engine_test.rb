# Tests for the SalesEngine class
require './test/test_helper'
require './lib/sales_engine'
class SalesEngineTest < MiniTest::Test
  def setup
    @files = { items: './data/items.csv',
               merchants: './data/merchants.csv',
               invoices: './data/invoices.csv' }
    @se             = SalesEngine.from_csv(@files)
    @merchant_repo  = @se.merchants
    @item_repo      = @se.items
    @inv_repo       = @se.invoices
  end

  def test_from_csv_method_and_existance
    assert_instance_of SalesEngine, @se
  end

  def test_has_merch_and_items_and_invoices
    assert_instance_of ItemRepository, @se.items
    assert_instance_of MerchRepository, @se.merchants
    assert_instance_of InvoiceRepository, @se.invoices
  end

  def test_items_method
    merchant = @merchant_repo.find_by_id(12_334_478)

    assert_equal 7, merchant.items.size
    assert_instance_of Item, merchant.items[0]
  end

  def test_merchants_method
    item = @item_repo.find_by_id(263_420_195)

    assert_equal 'DenesDoorDecor', item.merchant.name
  end

  def test_invoice_merchant_method
    assert_instance_of Merchant, @inv_repo.all.first.merchant
  end

  def test_merchant_invoices_method
    assert_instance_of Invoice, @merchant_repo.all.first.invoices.first
  end
end
