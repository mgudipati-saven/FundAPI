#!/usr/bin/env ruby -wKU
require 'redis'

$redisdb = Redis.new

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
