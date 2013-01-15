#!/usr/bin/env ruby -wKU
require 'redis'
require 'json'

# connect to redis db 1
$redisdb = Redis.new
$redisdb.select 1

ARGV.each do |a|
  	data = $redisdb.get "338::#{a}"
  	if data
		hash = JSON.parse data
		puts "#{hash['SYMBOL.TICKER']}\t#{hash['NAV.PRICE']}\t#{hash['INSTR_NAME2']}"
	end
end


