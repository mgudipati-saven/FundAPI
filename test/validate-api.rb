#!/usr/bin/env ruby -wKU
require 'httparty'
require 'json'
require 'colorize'

########## fund invalid command ##########
printf "%-80s", "invalid etf command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=invalid&ticker=SPY')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 10
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund components ##########
printf "%-80s", "valid etf components command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components&ticker=SPY')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['components']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid etf components command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['components']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid components command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=components')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## etf searchByComponent ##########
printf "%-80s", "valid etf searchByComponent command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent&ticker=IBM')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid etf searchByComponent command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid searchByComponent command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=searchByComponent')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## etf profile ##########
printf "%-80s", "valid etf profile command test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile&ticker=SPY')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['profile']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid etf profile command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['profile']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid etf profile command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/etfs.json?cmd=profile')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund tickers ##########
printf "%-80s", "valid fund tickers command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=tickers')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund names ##########
printf "%-80s", "valid fund names command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=names')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['names']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund sponsors ##########
printf "%-80s", "valid fund sponsors command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsors')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['sponsors']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund pgroups ##########
printf "%-80s", "valid fund pgroups command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=pgroups')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['pgroups']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund sgroups ##########
printf "%-80s", "valid fund sgroups command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sgroups')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['sgroups']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund benchmarks ##########
printf "%-80s", "valid fund benchmarks command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=benchmarks')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['benchmarks']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund complete ##########
printf "%-80s", "valid fund complete command given fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete&ticker=FM')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['results']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund complete command given fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete&name=Fidelity')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['results']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund complete command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=complete')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByName ##########
printf "%-80s", "valid fund searchByName command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName&name=Fidelity%20Emerging%20Asia%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund searchByName command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName&name=Stupd%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByName command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByName')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByPrimaryGroup ##########
printf "%-80s", "valid fund searchByPrimaryGroup command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByPrimaryGroup&pgrp=US%20Equity')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund searchByPrimaryGroup command with non-existent group test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByPrimaryGroup&pgrp=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByPrimaryGroup command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByPrimaryGroup')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchBySecondaryGroup ##########
printf "%-80s", "valid fund searchBySecondaryGroup command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchBySecondaryGroup&sgrp=Utilities')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund searchBySecondaryGroup command with non-existent group test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchBySecondaryGroup&sgrp=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchBySecondaryGroup command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchBySecondaryGroup')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByBenchmarkIndex ##########
printf "%-80s", "valid fund searchByBenchmarkIndex command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByBenchmarkIndex&bindex=S%26P%20500')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund searchByBenchmarkIndex command with non-existent index test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByBenchmarkIndex&bindex=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByBenchmarkIndex command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByBenchmarkIndex')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByLoadType ##########
printf "%-80s", "valid fund searchByLoadType command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByLoadType&type=N')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund searchByLoadType command with non-existent load test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByLoadType&type=O')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByLoadType command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByLoadType')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByInitialInvestment ##########
printf "%-80s", "valid fund searchByInitialInvestment command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByInitialInvestment&lt=500')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByInitialInvestment command with invalid param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByInitialInvestment&lt=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByInitialInvestment command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByInitialInvestment')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByReturns ##########
printf "%-80s", "valid fund searchByReturns command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByReturns&param=Yr1&gt=25')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByReturns command with invalid param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByReturns&param=Yr1&gt=XX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByReturns command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByReturns')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund searchByRatios ##########
printf "%-80s", "valid fund searchByRatios command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios&param=ExpenseRatio&lt=0.5')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['tickers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByRatios command with invalid param, lt, test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios&param=ExpenseRatio&lt=XX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByRatios command with invalid param, param, test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios&param=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 20
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund searchByRatios command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=searchByRatios')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund prices ##########
printf "%-80s", "valid fund prices command test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['prices']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund prices command with non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['prices']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund prices command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=prices')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund alloc ##########
printf "%-80s", "valid fund asset alloc command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=asset&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['alloc']['asset']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund sector alloc command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=sector&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['alloc']['sector']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund geography alloc command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=geo&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['alloc']['geo']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund asset alloc command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=asset&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['alloc']['asset']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund sector alloc command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=sector&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['alloc']['sector']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund geography alloc command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=geo&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['alloc']['geo']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund alloc command with missing type, ticker and name params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund alloc command with missing ticker and name params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&type=geo')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund alloc command with missing ticker and type params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund alloc command with missing type and name params test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund alloc command with missing just the type param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=alloc&ticker=FMAGX&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund holdings ##########
printf "%-80s", "valid fund holdings command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['holdings']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund holdings command given a fund name test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings&name=Fidelity%20Magellan%20Fund')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['holdings']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund holdings command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings&name=Fidelity')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['holdings']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund holdings command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=holdings')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund history ##########
printf "%-80s", "valid fund history command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=hist&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['history']
  puts JSON.pretty_generate parsed['history']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund history command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=hist&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['history']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund history command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=hist')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund fees ##########
printf "%-80s", "valid fund fees command given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=fees&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['fees']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund fees command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=fees&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['fees']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund fees command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=fees')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund ratios ##########
printf "%-80s", "valid fund ratios given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=ratios&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['ratios']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund ratios command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=ratios&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['ratios']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund ratios command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=ratios')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund managers ##########
printf "%-80s", "valid fund managers given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=managers&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['managers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund managers command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=managers&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['managers']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund managers command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=managers')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund profile ##########
printf "%-80s", "valid fund profile given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=profile&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['profile']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund profile command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=profile&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['profile']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund profile command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=profile')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund sponsor ##########
printf "%-80s", "valid fund sponsor given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsor&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['sponsor']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund sponsor command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsor&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['sponsor']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund sponsor command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=sponsor')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund returns ##########
printf "%-80s", "valid fund returns given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['returns']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund returns command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['returns']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund returns command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

########## fund basics ##########
printf "%-80s", "valid fund basics given a fund ticker test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=basics&ticker=FMAGX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['basics']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "valid fund basics command given a non-existent fund test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=basics&ticker=XXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['basics']
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end

printf "%-80s", "invalid fund basics command with missing param test..."
res = HTTParty.get('http://127.0.0.1:8080/funds.json?cmd=returns')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
if parsed['errors'] and parsed['errors'][0]['code'] == 30
  printf "%20s", "passed\n".green
else
  printf "%20s", "failed\n".red
end
