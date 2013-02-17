#!/usr/bin/env ruby -wKU
require 'httparty'
require 'json'

########## fund invalid command ##########
print "invalid etf command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=invalid&ticker=SPY')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 10
  puts "passed"
else
  puts "failed"
end

########## fund components ##########
print "valid etf components command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components&ticker=SPY')
parsed = JSON.parse(res.body)
if parsed['components']
  puts "passed"
else
  puts "failed"
end

print "valid etf components command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components&ticker=XXX')
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

########## etf searchByComponent ##########
print "valid etf searchByComponent command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent&ticker=IBM')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid etf searchByComponent command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent&ticker=XXX')
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

########## etf profile ##########
print "valid etf profile command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile&ticker=SPY')
parsed = JSON.parse(res.body)
if parsed['profile']
  puts "passed"
else
  puts "failed"
end

print "valid etf profile command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['profile']
  puts "passed"
else
  puts "failed"
end

print "invalid etf profile command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund tickers ##########
print "valid fund tickers command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=tickers')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

########## fund names ##########
print "valid fund names command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=names')
parsed = JSON.parse(res.body)
if parsed['names']
  puts "passed"
else
  puts "failed"
end

########## fund sponsors ##########
print "valid fund sponsors command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsors')
parsed = JSON.parse(res.body)
if parsed['sponsors']
  puts "passed"
else
  puts "failed"
end

########## fund pgroups ##########
print "valid fund pgroups command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=pgroups')
parsed = JSON.parse(res.body)
if parsed['pgroups']
  puts "passed"
else
  puts "failed"
end

########## fund sgroups ##########
print "valid fund sgroups command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sgroups')
parsed = JSON.parse(res.body)
if parsed['sgroups']
  puts "passed"
else
  puts "failed"
end

########## fund benchmarks ##########
print "valid fund benchmarks command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=benchmarks')
parsed = JSON.parse(res.body)
if parsed['benchmarks']
  puts "passed"
else
  puts "failed"
end

########## fund complete ##########
print "valid fund complete command given fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete&ticker=FM')
parsed = JSON.parse(res.body)
if parsed['results']
  puts "passed"
else
  puts "failed"
end

print "valid fund complete command given fund name test..."
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

########## fund searchByName ##########
print "valid fund searchByName command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName&name=Fidelity%20Emerging%20Asia%20Fund')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid fund searchByName command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName&name=Stupd%20Fund')
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

########## fund searchByPrimaryGroup ##########
print "valid fund searchByPrimaryGroup command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByPrimaryGroup&pgrp=US%20Equity')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid fund searchByPrimaryGroup command with non-existent group test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByPrimaryGroup&pgrp=XXX')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByPrimaryGroup command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByPrimaryGroup')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund searchBySecondaryGroup ##########
print "valid fund searchBySecondaryGroup command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchBySecondaryGroup&sgrp=Utilities')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid fund searchBySecondaryGroup command with non-existent group test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchBySecondaryGroup&sgrp=XXX')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchBySecondaryGroup command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchBySecondaryGroup')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund searchByBenchmarkIndex ##########
print "valid fund searchByBenchmarkIndex command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByBenchmarkIndex&bindex=S%26P%20500')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid fund searchByBenchmarkIndex command with non-existent index test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByBenchmarkIndex&bindex=XXX')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByBenchmarkIndex command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByBenchmarkIndex')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund searchByLoadType ##########
print "valid fund searchByLoadType command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByLoadType&type=N')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "valid fund searchByLoadType command with non-existent load test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByLoadType&type=O')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByLoadType command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByLoadType')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

########## fund searchByInitialInvestment ##########
print "valid fund searchByInitialInvestment command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByInitialInvestment&lt=500')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByInitialInvestment command with invalid param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByInitialInvestment&lt=XXX')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByInitialInvestment command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByInitialInvestment')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

########## fund searchByReturns ##########
print "valid fund searchByReturns command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByReturns&param=Yr1&gt=25')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByReturns command with invalid param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByReturns&param=Yr1&gt=XX')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByReturns command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByReturns')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

########## fund searchByRatios ##########
print "valid fund searchByRatios command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios&param=ExpenseRatio&lt=0.5')
parsed = JSON.parse(res.body)
if parsed['tickers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByRatios command with invalid param, lt, test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios&param=ExpenseRatio&lt=XX')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByRatios command with invalid param, param, test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios&param=XXX')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  puts "passed"
else
  puts "failed"
end

print "invalid fund searchByRatios command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund prices ##########
print "valid fund prices command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['prices']
  puts "passed"
else
  puts "failed"
end

print "valid fund prices command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices&ticker=XXX')
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

########## fund alloc ##########
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

########## fund holdings ##########
print "valid fund holdings command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['holdings']
  puts "passed"
else
  puts "failed"
end

print "valid fund holdings command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
if parsed['holdings']
  puts "passed"
else
  puts "failed"
end

print "valid fund holdings command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings&name=Fidelity')
parsed = JSON.parse(res.body)
if parsed['holdings']
  puts "passed"
else
  puts "failed"
end

print "invalid fund holdings command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund history ##########
print "valid fund history command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=hist&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['history']
  puts "passed"
else
  puts "failed"
end

print "valid fund history command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=hist&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['history']
  puts "passed"
else
  puts "failed"
end

print "invalid fund history command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=hist')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund fees ##########
print "valid fund fees command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=fees&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['fees']
  puts "passed"
else
  puts "failed"
end

print "valid fund fees command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=fees&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['fees']
  puts "passed"
else
  puts "failed"
end

print "invalid fund fees command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=fees')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund ratios ##########
print "valid fund ratios given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=ratios&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['ratios']
  puts "passed"
else
  puts "failed"
end

print "valid fund ratios command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=ratios&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['ratios']
  puts "passed"
else
  puts "failed"
end

print "invalid fund ratios command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=ratios')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund managers ##########
print "valid fund managers given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=managers&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['managers']
  puts "passed"
else
  puts "failed"
end

print "valid fund managers command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=managers&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['managers']
  puts "passed"
else
  puts "failed"
end

print "invalid fund managers command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=managers')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund profile ##########
print "valid fund profile given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=profile&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['profile']
  puts "passed"
else
  puts "failed"
end

print "valid fund profile command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=profile&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['profile']
  puts "passed"
else
  puts "failed"
end

print "invalid fund profile command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=profile')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund sponsor ##########
print "valid fund sponsor given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsor&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['sponsor']
  puts "passed"
else
  puts "failed"
end

print "valid fund sponsor command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsor&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['sponsor']
  puts "passed"
else
  puts "failed"
end

print "invalid fund sponsor command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsor')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund returns ##########
print "valid fund returns given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['returns']
  puts "passed"
else
  puts "failed"
end

print "valid fund returns command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['returns']
  puts "passed"
else
  puts "failed"
end

print "invalid fund returns command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end

########## fund basics ##########
print "valid fund basics given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=basics&ticker=FMAGX')
parsed = JSON.parse(res.body)
if parsed['basics']
  puts "passed"
else
  puts "failed"
end

print "valid fund basics command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=basics&ticker=XXX')
parsed = JSON.parse(res.body)
if parsed['basics']
  puts "passed"
else
  puts "failed"
end

print "invalid fund basics command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns')
parsed = JSON.parse(res.body)
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  puts "passed"
else
  puts "failed"
end
