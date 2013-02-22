=begin
key => "fund.tickers.auto.complete"
val => sorted set of fund tickers with auto completion list (google suggest).
e.g.=> "fund.tickers.auto.complete" => ['A', 'AA', 'AAA', 'AAAAX', ...]

key => "fund.names.auto.complete"
val => sorted set of fund names with auto completion list (google suggest).
e.g.=> "fund.names.auto.complete" => ['A', 'AC', ...]
=end

require 'redis'

$redisdb = Redis.new
$redisdb.select 0

# create a sorted set of google suggestions for fund tickers
puts "Generating google suggestion list for fund tickers..."
$redisdb.zunionstore "all.tickers", ["fund.tickers", "etf.tickers"]
arr = $redisdb.zrange "all.tickers", 0, -1
arr.each do |ticker|
  (1..(ticker.length)).each do |n|
    prefix = ticker[0...n]
    $redisdb.zadd "fund.tickers.auto.complete", 0, prefix
  end
  $redisdb.zadd "fund.tickers.auto.complete", 0, "#{ticker}*"
end

# create a sorted set of google suggestions for fund names
puts "Generating google suggestion list for fund names..."
arr = $redisdb.zrange "fund.names", 0, -1
arr.each do |name|
  (1..(name.length)).each do |n|
    prefix = name[0...n]
    $redisdb.zadd "fund.names.auto.complete", 0, prefix
  end
  $redisdb.zadd "fund.names.auto.complete", 0, "#{name}*"
end

=begin rdoc
 * Name: gen-auto-complete.rb
 * Description: Generates auto completion (google suggest) list for fund tickers and names
 * Call using "ruby gen-auto-complete"  
 * Author: Murthy Gudipati
 * Date: 07-Feb-2011
 * License: Saven Technologies Inc.
=end
