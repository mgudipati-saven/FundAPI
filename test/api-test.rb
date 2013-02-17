#!/usr/bin/env ruby -wKU
require 'httparty'
require 'json'

print "invalid command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=invalid&ticker=SPY')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 10
  puts "passed"
else
  puts "failed"
end

print "valid components command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components&ticker=SPY')
parsed = JSON.parse(res.body)
if parsed['components']
  puts "passed"
else
  puts "failed"
end

print "invalid components command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "valid searchByComponent command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent&ticker=IBM')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid searchByComponent command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "valid profile command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile&ticker=SPY')
parsed = JSON.parse(res.body)
if parsed['profile']
  puts "passed"
else
  puts "failed"
end

print "invalid profile command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end
