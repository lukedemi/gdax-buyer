#!/usr/bin/env ruby
require_relative 'lib/buyer'

usd_pool = ENV.fetch('USD_POOL', '30').to_f # maximum about of usd to have out in orders
buy_size = ENV.fetch('BUY_SIZE', '0.01').to_f # size per buy order
discount = ENV.fetch('DISCOUNT', '0.003').to_f # percentage discount per buy
currency = ENV.fetch('CURRENCY', 'LTC') # currency out of LTC, BTC, ETH

buyer = Buyer.new(currency)
buyer.buy_loop(usd_pool, buy_size, discount)
