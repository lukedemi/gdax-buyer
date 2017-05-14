#!/usr/bin/env ruby
require 'coinbase/exchange'
require 'pry'

class Buyer
  def initialize(currency)
    @currency = currency
    @product_id = "#{@currency}-USD"
    @delay = 30
    @gdax_api = Coinbase::Exchange::Client.new(
      ENV['GDAX_API_KEY'],
      ENV['GDAX_API_SECRET'],
      ENV['GDAX_API_PASS']
    )
  end

  def open_orders
    @gdax_api.orders(
      status: 'open',
      product_id: @product_id
    )
  end

  def open_order_amount
    open_orders.map { |o| o['size'].to_f * o['price'].to_f }
               .reduce(&:+)
  end

  def oldest_order
    open_orders.sort_by { |o| o['created_at'] }
               .first
  end

  def cancel_order(order)
    @gdax_api.cancel(order['id'])
    while true
      begin
        @gdax_api.order(order['id'])
      rescue Coinbase::Exchange::NotFoundError
        return
      end
    end
  end

  def order_age(order)
    Time.now.utc - Time.parse(order['created_at'])
  end

  def oldest_order_age
    oldest_order = open_orders.sort_by { |o| o['created_at'] }.first
    order_age(oldest_order)
  end

  def account(currency)
    @gdax_api.accounts
             .select { |a| a['currency'] == currency }
             .first
  end

  def available_usd
    account('USD')['available'].to_f
  end

  def last_trade_price
    @gdax_api.last_trade(product_id: @product_id)['price'].to_f
  end

  def place_limit_buy(amt, price)
    @gdax_api.bid(
      amt,
      price.to_f.round(2),
      product_id: @product_id
    )
  end

  def buy_loop(usd_pool, buy_size, discount)
    while true
      last_price = last_trade_price
      sale_price = last_price * (1 - discount)
      if available_usd > (sale_price * buy_size) &&
         open_order_amount < usd_pool
        puts "placing buy #{discount * 100}% under $#{last_price} ($#{sale_price})"
        place_limit_buy(buy_size, sale_price)
        sleep(@delay)
      elsif open_orders.empty?
        sleep(@delay)
      else
        order = oldest_order
        if order_age(order) < @delay
          puts "oldest order still less than @delay #{order_age(order)}"
          sleep(@delay)
        else
          puts "killing the oldest order (#{order['price']})"
          cancel_order(order)
        end
      end
    end
  end
end
