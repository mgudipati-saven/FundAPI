#!/usr/bin/env ruby -wKU
require 'redis'
require 'json'

$redisdb = Redis.new

ARGV.each do |a|
    p $redisdb.smembers "FUND::NAME::#{a}"
end
