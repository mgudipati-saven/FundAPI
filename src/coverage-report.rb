#!/usr/bin/env ruby

require 'csv'
require 'redis'
require 'json'

# open redis db
$redisdb = Redis.new
$redisdb.select 0

# hash bucket to hold fields and the corresponding tickers for which data is missing
# "ManagementFees" => [AAAAX, AAABX, ...]
rows_h = Hash.new

# collect stats
# for all tickers loop through each data table and gather fields and tickers for which data is missing
tickers_a = $redisdb.zrange "fund.tickers", 0, -1
tickers_a.each do |ticker|
  # fund fees
  fields_a = $redisdb.hkeys "fund:#{ticker}:fees"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:fees", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end

  # fund ratios
  fields_a = $redisdb.hkeys "fund:#{ticker}:ratios"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:ratios", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end

  # fund managers
  fields_a = $redisdb.hkeys "fund:#{ticker}:managers"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:managers", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end

  # fund profile
  fields_a = $redisdb.hkeys "fund:#{ticker}:profile"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:profile", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end

  # fund sponsor
  fields_a = $redisdb.hkeys "fund:#{ticker}:sponsor"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:sponsor", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end

  # fund basics
  fields_a = $redisdb.hkeys "fund:#{ticker}:basics"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:basics", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end

  # fund returns
  fields_a = $redisdb.hkeys "fund:#{ticker}:returns"
  fields_a.each do |field|
    val = $redisdb.hget "fund:#{ticker}:returns", field
    if !val or val == ""
      if !rows_h[field]
        # create an array to hold the tickers
        rows_h[field] = Array.new
      end
      rows_h[field] << ticker
    end
  end
end

#
# create a csv file of fund fields, coverage and the ticker list for which data is missing
#
# ManagementFees, 90.00, FMAGX, ZZZZX, ...
# RedemptionFee, 99.00, FMAGX, ZZZZX, ...
# ...
# ...
headers_a = [
  "Fund Field",
  "% Coverage",
  "Num Tickers",
  "Missing Ticker List"
  ]
CSV.open("field-coverage-report.csv", "wb", :headers => headers_a, :write_headers => true) do |csv|
  rows_h.each do |key, value|
    coverage = (tickers_a.length-value.length).to_f/tickers_a.length * 100
    csv << [key, '%.2f' % coverage, value.length] + value
  end
end

=begin rdoc
 * Name: coverage-report.rb
 * Description: Creates a report of fund field coverage.
 * Call using "ruby coverage-report.rb"  
 * Author: Murthy Gudipati
 * Date: 07-Feb-2012
 * License: Saven Technologies Inc.
=end

