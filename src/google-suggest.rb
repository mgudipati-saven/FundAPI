require 'rubygems'
require 'redis'

r = Redis.new

=begin
# create a sorted set of google suggestions for fund tickers
if r.exists("fund:tickers")
    puts "Creating google suggestion list for fund tickers..."
    
    arr = r.zrange "fund:tickers", 0, -1
    arr.each do |ticker|
      (1..(ticker.length)).each do |n|
          prefix = ticker[0...n]
          r.zadd "fund:tickers:auto.complete", 0, prefix
      end
      r.zadd "fund:tickers:auto.complete", 0, "#{ticker}*"
    end
end
=end

def complete(r,prefix,count)
    results = []
    rangelen = 50 # This is not random, try to get replies < MTU size
    start = r.zrank("fund:tickers:auto.complete",prefix)
    return [] if !start
    while results.length != count
        range = r.zrange("fund:tickers:auto.complete",start,start+rangelen-1)
        start += rangelen
        break if !range or range.length == 0
        range.each {|entry|
            minlen = [entry.length,prefix.length].min
            if entry[0...minlen] != prefix[0...minlen]
                count = results.length
                break
            end
            if entry[-1..-1] == "*" and results.length != count
                results << entry[0...-1]
            end
        }
    end
    return results
end

complete(r,ARGV[0],10).each{|res|
    puts res
}