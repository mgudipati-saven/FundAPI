#!/usr/bin/env ruby -wKU
require 'redis'

$redisdb = Redis.new

ARGV.each do |a|
  arr = $redisdb.keys "FUND::HISTORY::#{a}::*"
  puts "----Turnover----"
  arr.sort.each do |key|
    puts "#{key}\t#{$redisdb.hget key, "Turnover"}"
  end

  puts "----Total Net Assets----"
  arr.sort.each do |key|
    puts "#{key}\t#{$redisdb.hget key, "TotalNetAssets"}"
  end

  puts "----Total Returns----"
  arr.sort.each do |key|
    puts "#{key}\t#{$redisdb.hget key, "TotalReturns"}"
  end
end


