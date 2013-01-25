#!/usr/bin/env ruby -wKU
require 'redis'
require 'json'

$redisdb = Redis.new

ARGV.each do |a|
	puts "----#{a}---"
	dbkey = "FUND::BASIC::#{a}"
	p $redisdb.hgetall dbkey
end