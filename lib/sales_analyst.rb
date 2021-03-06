require_relative 'arithmetic'
require 'bigdecimal'
# This is the SalesAnalyst class
class SalesAnalyst
  include Arithmetic
  def initialize(sales_engine)
    @sales_engine = sales_engine
  end

  def items
    @sales_engine.items.all
  end

  def merchants
    @sales_engine.merchants.all
  end

  def invoices
    @sales_engine.invoices.all
  end

  def invoice_items
    @sales_engine.invoice_items.all
  end

  def total_revenue_by_date(date)
    data = invoices.select { |invoice| invoice.created_at == date }
    data.map(&:total).reduce(:+)
  end

  def average_items_per_merchant
    @average_items_per_merchant ||= calc_avg_items_per_merch
  end

  def calc_avg_items_per_merch
    average(items.size, merchants.size).to_f.round(2)
  end

  def average_items_per_merchant_standard_deviation
    @average_items_per_merchant_standard_deviation ||=
      calc_avg_items_per_merch_stdev
  end

  def calc_avg_items_per_merch_stdev
    data = merchants.map { |merchant| merchant.items.size }
    standard_deviation(data, average_items_per_merchant).round(2)
  end

  def merchants_with_high_item_count
    std_deviation = average_items_per_merchant_standard_deviation
    avg           = average_items_per_merchant
    merchants.select do |merchant|
      data = merchant.items.size
      z_score(data, avg, std_deviation) > 1
    end
  end

  def average_item_price_for_merchant(merchant_id)
    inventory = @sales_engine.merchants.find_by_id(merchant_id).items
    prices    = inventory.map(&:unit_price)
    average(prices.reduce(:+), inventory.size)
  end

  def average_average_price_per_merchant
    numerator = merchants.reduce(0) do |sum, merchant|
      sum + average_item_price_for_merchant(merchant.id)
    end
    average(numerator, merchants.size)
  end

  def average_invoices_per_merchant
    @average_invoices_per_merchant ||= calc_avg_inv_per_merch
  end

  def calc_avg_inv_per_merch
    average(invoices.size, merchants.size).to_f
  end

  def most_sold_item_for_merchant(merch_id)
    merchant     = @sales_engine.merchants.find_by_id(merch_id)
    items        = merchant.all_items_by_quantity
    max_quantity = merchant.sales_quantities[items.last.id]
    items.select { |item| merchant.sales_quantities[item.id] == max_quantity }
  end

  def merchants_with_only_one_item
    merchants.select { |merchant| merchant.items.size == 1 }
  end

  def merchants_with_only_one_item_registered_in_month(month)
    candidates = merchants.select do |merchant|
      merchant.created_at.strftime('%B') == month
    end
    candidates.select { |merchant| merchant.items.size == 1 }
  end

  def revenue_by_merchant(id)
    merchant = @sales_engine.merchants.find_by_id(id)
    merchant.invoices.map(&:total).reduce(:+)
  end

  def best_item_for_merchant(id)
    merchant      = @sales_engine.merchants.find_by_id(id)
    invoice_items = merchant.invoice_items

    top = invoice_items.max_by do |ii|
      ii.unit_price * merchant.sales_quantities[ii.item_id]
    end

    @sales_engine.items.find_by_id(top.item_id)
  end

  def merchants_ranked_by_revenue
    @merchants_ranked_by_revenue ||= calc_merch_ranked_by_rev
  end

  def calc_merch_ranked_by_rev
    merchants.sort_by do |merchant|
      merchant.invoices.map(&:total).reduce(:+)
    end.reverse
  end

  def merchants_with_pending_invoices
    merchants.select do |merchant|
      merchant.invoices.map(&:is_paid_in_full?).include?(false)
    end
  end

  def top_revenue_earners(size = 20)
    merchants_ranked_by_revenue[0...size]
  end

  def net_invoices(merchant_id)
    @sales_engine.invoices.find_all_by_merchant_id(merchant_id).size
  end

  def average_invoices_per_merchant_standard_deviation
    @average_invoices_per_merchant_standard_deviation ||=
      calc_avg_inv_per_merch_stdev
  end

  def calc_avg_inv_per_merch_stdev
    data = merchants.map { |merchant| net_invoices(merchant.id) }
    standard_deviation(data, average_invoices_per_merchant).round(2)
  end

  def top_merchants_by_invoice_count
    std_deviation = average_invoices_per_merchant_standard_deviation
    avg           = average_invoices_per_merchant
    merchants.select do |merchant|
      data = net_invoices(merchant.id)
      z_score(data, avg, std_deviation) > 2
    end
  end

  def bottom_merchants_by_invoice_count
    std_deviation = average_invoices_per_merchant_standard_deviation
    merchants.select do |merchant|
      data = net_invoices(merchant.id)
      z_score(data, average_invoices_per_merchant, std_deviation) < -2
    end
  end

  def average_daily_invoices
    @average_daily_invoices ||= calc_avg_daily_inv
  end

  def calc_avg_daily_inv
    average(invoices.size, 7)
  end

  def find_days
    @find_days ||= calc_find_days
  end

  def calc_find_days
    data = invoices.group_by(&:weekday_created)
    data.each_key { |day| data[day] = data[day].size }
  end

  def std_deviation_daily_invoices
    @std_deviation_daily_invoices ||= calc_stdev_daily_inv
  end

  def calc_stdev_daily_inv
    standard_deviation(find_days.invert, average_daily_invoices)
  end

  def top_days_by_invoice_count
    find_days.select do |_k, invoice|
      z_score(invoice, average_daily_invoices, std_deviation_daily_invoices) > 1
    end.keys
  end

  def invoice_status(status)
    data = invoices.select { |invoice| invoice.status == status }.size
    ((data.to_f / invoices.size) * 100).round(2)
  end

  def average_item_price
    @average_item_price ||= calc_avg_item_price
  end

  def calc_avg_item_price
    numerator = items.map { |item| item.unit_price.to_i }.reduce(:+)
    average(numerator, items.size)
  end

  def average_item_price_standard_deviation
    @average_item_price_standard_deviation ||= calc_avg_item_price_stdev
  end

  def calc_avg_item_price_stdev
    data = items.map { |item| item.unit_price.to_i }
    standard_deviation(data, average_item_price)
  end

  def golden_items
    std_deviation = average_item_price_standard_deviation
    items.select do |item|
      data = item.unit_price.to_i
      z_score(data, average_item_price, std_deviation) > 2
    end
  end
end
