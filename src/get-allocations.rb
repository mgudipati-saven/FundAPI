#!/usr/bin/env ruby -wKU
require 'redis'
require 'json'

$redisdb = Redis.new

ARGV.each do |a|
  puts "----Geography Allocation---"
  arr = $redisdb.zrevrange "FUND::ALLOCATION::GEOGRAPHY::#{a}", 0, -1
  arr.each do |allocation|
    hash = JSON.parse allocation
    puts "#{hash['Country']}\t#{hash['Allocation']}\t#{hash['Date']}"
  end

  puts "----Sector Allocation---"
  arr = $redisdb.zrevrange "FUND::ALLOCATION::SECTOR::#{a}", 0, -1
  arr.each do |allocation|
    hash = JSON.parse allocation
    puts "#{hash['Sector']}\t#{hash['Allocation']}\t#{hash['Date']}"
  end

  puts "----Asset Allocation---"
  arr = $redisdb.zrevrange "FUND::ALLOCATION::ASSET::#{a}", 0, -1
  arr.each do |allocation|
    hash = JSON.parse allocation
    puts "#{hash['Asset']}\t#{hash['Allocation']}\t#{hash['Date']}"
  end
end


