#!/usr/bin/env ruby -wKU
require 'redis'

$redisdb = Redis.new

=begin
res = []
arr = $redisdb.zrange "fund:tickers", 0, -1
puts arr
arr.each do |ticker|
  ratio = $redisdb.hget "fund:#{ticker}:ratios", "TotalExpenseRatio"
  if ratio.to_f < 0.5
    res << ticker
  end
end
puts res
=end

=begin
res = []
arr = $redisdb.zrange "fund:tickers", 0, -1
arr.each do |ticker|
  loadtype = $redisdb.hget "fund:#{ticker}:fees", "LoadType"
  if loadtype === "N"
    res << ticker
  end
end
puts res
=end

res = []
arr = $redisdb.zrange "fund:tickers", 0, -1
arr.each do |ticker|
  amt = $redisdb.hget "fund:#{ticker}:profile", "InitialInvestment"
  if amt != "" && amt.to_i <= 500
    res << ticker
  end
end
puts res
