#!/usr/bin/env ruby -wKU
require 'httparty'
require 'json'

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=cmdnotfound&ticker=SPY')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
p parsed
if parsed['errors']
  p parsed['errors'][0]['code']
end

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components&ticker=SPY')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
p parsed
if parsed['errors']
  p parsed['errors'][0]['code']
elsif parsed['components']
  parsed['components'].each do |comp|
    hash = JSON.parse(comp)
    p hash['TickerSymbol'], hash  ['ShareQuantity']
  end
end

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
p parsed
if parsed['errors']
  p parsed['errors'][0]['code']
end

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent&ticker=IBM')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
p parsed
if parsed['errors']
  p parsed['errors'][0]['code']
elsif parsed['tickers']
  parsed['tickers'].each do |ticker|
    p ticker
  end
end

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
if parsed['errors']
  p parsed['errors'][0]['code']
end

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile&ticker=SPY')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
p parsed
if parsed['profile']
  p parsed['profile']['CUSIP']
end

res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile')
p res.body, res.code, res.message, res.headers.inspect
parsed = JSON.parse(res.body)
p parsed
if parsed['errors']
  p parsed['errors'][0]['code']
end
