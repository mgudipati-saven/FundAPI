=begin
  key => "fund.tickers.auto.complete"
  val => sorted set of fund tickers with auto completion list (google suggest).

  key => "fund.series.names"
  val => sorted set of fund names.

  key => "fund.series.names.auto.complete"
  val => sorted set of fund series names with auto completion list (google suggest).
=end

require 'redis'

$redisdb = Redis.new
$redisdb.select 0

# create a sorted set of google suggestions for fund tickers
puts "Generating google suggestion list for fund tickers..."
$redisdb.del "fund.tickers.auto.complete"
$redisdb.zunionstore "all.tickers", ["fund.tickers", "etf.tickers"]
arr = $redisdb.zrange "all.tickers", 0, -1
arr.each do |ticker|
  (1..(ticker.length)).each do |n|
    prefix = ticker[0...n]
    $redisdb.zadd "fund.tickers.auto.complete", 0, prefix
  end
  $redisdb.zadd "fund.tickers.auto.complete", 0, "#{ticker}*"
end

# create a sorted set of fund series names...
puts "Creating sorted set for fund series names..."
$redisdb.del "fund.series.names"
arr = $redisdb.zrange "fund.tickers", 0, -1
arr.each do |ticker|
  # obtain the fund id...
  id = $redisdb.get "mf:#{ticker}:id"
  if id
    # obtain the fund series name from basic data for this fund id
    name = $redisdb.hget "mf:#{id}:basics", :SeriesName
    if name
      # add the series to the set
      $redisdb.zadd "fund.series.names", 0, name
    end
  end
end

# create a sorted set of google suggestions for fund names
puts "Generating google suggestion list for fund series names..."
$redisdb.del "fund.series.names.auto.complete"
arr = $redisdb.zrange "fund.series.names", 0, -1
arr.each do |name|
  (1..(name.length)).each do |n|
    prefix = name[0...n]
    $redisdb.zadd "fund.series.names.auto.complete", 0, prefix
  end
  $redisdb.zadd "fund.series.names.auto.complete", 0, "#{name}*"
end

=begin rdoc
 * Name: post-load-mf.rb
 * Description: post processing after loading mutual fund basic data file.
 * Call using "ruby post-load-mf.rb"  
 * Author: Murthy Gudipati
 * Date: 22-Feb-2013
 * License: Saven Technologies Inc.
=end
