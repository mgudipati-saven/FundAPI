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

print "valid fund tickers command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=tickers')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid fund names command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=names')
parsed = JSON.parse(res.body)
if parsed['names']
  puts "passed"
else
  puts "failed"
end

print "valid fund sponsors command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsors')
parsed = JSON.parse(res.body)
if parsed['sponsors']
  puts "passed"
else
  puts "failed"
end

print "valid fund pgroups command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=pgroups')
parsed = JSON.parse(res.body)
if parsed['pgroups']
  puts "passed"
else
  puts "failed"
end

print "valid fund sgroups command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sgroups')
parsed = JSON.parse(res.body)
if parsed['sgroups']
  puts "passed"
else
  puts "failed"
end

print "valid fund benchmarks command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=benchmarks')
parsed = JSON.parse(res.body)
if parsed['benchmarks']
  puts "passed"
else
  puts "failed"
end

print "valid fund complete command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete&ticker=FM')
parsed = JSON.parse(res.body)
if parsed['results']
  puts "passed"
else
  puts "failed"
end

print "valid fund complete command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete&name=Fidelity')
parsed = JSON.parse(res.body)
if parsed['results']
  puts "passed"
else
  puts "failed"
end

print "invalid fund complete command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "valid fund searchByName command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName&name=Fidelity%20Emerging%20Asia%20Fund')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByName command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "valid fund prices command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['prices']
  puts "passed"
else
  puts "failed"
end

print "invalid fund prices command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "valid fund asset alloc command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=asset&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
if parsed['alloc']['asset']
  puts "passed"
else
  puts "failed"
end

print "valid fund sector alloc command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=sector&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
if parsed['alloc']['sector']
  puts "passed"
else
  puts "failed"
end

print "valid fund geography alloc command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=geo&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
if parsed['alloc']['geo']
  puts "passed"
else
  puts "failed"
end

print "valid fund asset alloc command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=asset&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['alloc']['asset']
  puts "passed"
else
  puts "failed"
end

print "valid fund sector alloc command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=sector&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['alloc']['sector']
  puts "passed"
else
  puts "failed"
end

print "valid fund geography alloc command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=geo&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['alloc']['geo']
  puts "passed"
else
  puts "failed"
end

print "invalid fund alloc command with missing type, ticker and name params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "invalid fund alloc command with missing ticker and name params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=geo')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "invalid fund alloc command with missing ticker and type params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "invalid fund alloc command with missing type and name params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

print "invalid fund alloc command with missing just the type param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&ticker=FMAGX&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end
