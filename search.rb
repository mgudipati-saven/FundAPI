#!/usr/bin/env ruby -wKU
require 'redis'
require 'json'

$redisdb = Redis.new

p ARGV
p key1 = (ARGV[0] != nil) ? "FUND::GROUP::PRIMARY::#{ARGV[0]}" : nil
p key2 = (ARGV[1] != nil) ? "FUND::GROUP::SECONDARY::#{ARGV[1]}" : nil
if key1 && key2
	p $redisdb.sinter key1, key2
elsif key1
	p $redisdb.sinter key1
elsif key2
	p $redisdb.sinter key2
end


