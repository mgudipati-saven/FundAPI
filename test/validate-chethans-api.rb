#!/usr/bin/env ruby -wKU
require 'httparty'
require 'json'
require 'awesome_print'

puts "http://122.183.102.229:8080/data_api/fund/basedata.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/basedata.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/sponsor.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/sponsor.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/manager.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/manager.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/expenses.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/expenses.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/investments.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/investments.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/performance.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/performance.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/performanceMetrics.json?fundSymbol=AAAAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/performanceMetrics.json?fundSymbol=AAAAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/holdings.json?fundSymbol=AACXX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/holdings.json?fundSymbol=AACXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/assetAllocation.json?fundSymbol=AACXX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/assetAllocation.json?fundSymbol=AACXX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/sectorAllocation.json?fundSymbol=DGDAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/sectorAllocation.json?fundSymbol=DGDAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/geographicalAllocation.json?fundSymbol=DGDAX"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/geographicalAllocation.json?fundSymbol=DGDAX')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/search/listFundsByNameOrSymbol.json?value=Alternative"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/search/listFundsByNameOrSymbol.json?value=Alternative')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/list/fundGroup.json"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/list/fundGroup.json')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/list/secondaryGroup.json"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/list/secondaryGroup.json')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/list/benchmarkIndices.json"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/list/benchmarkIndices.json')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/list/loadFunds.json"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/list/loadFunds.json')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/list/fundSponsor.json"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/list/fundSponsor.json')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/list/dividendFrequency.json"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/list/dividendFrequency.json')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed

puts "http://122.183.102.229:8080/data_api/fund/search.json?fundGrp=1&initInv=1000,10000&initInvFilter=bt"
res = HTTParty.get('http://122.183.102.229:8080/data_api/fund/search.json?fundGrp=1&initInv=1000,10000&initInvFilter=bt')
parsed = JSON.parse(res.body)
puts JSON.pretty_generate parsed
