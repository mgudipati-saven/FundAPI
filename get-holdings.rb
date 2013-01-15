#!/usr/bin/env ruby -wKU
require 'redis'

$redisdb = Redis.new

ARGV.each do |a|
  arr = $redisdb.zrevrange "FUND::HOLDINGS::#{a}", 0, -1
  arr.each do |holding|
    hash = JSON.parse holding
    puts "#{hash['HoldingCompany']}\t#{hash['HoldingValue']}"
  end
end


