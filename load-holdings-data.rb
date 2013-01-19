#!/usr/bin/env ruby -wKU
require 'csv'
require 'redis'
require 'json'

$redisdb = Redis.new

ARGV.each do |a|
  $datafile = a
end

CSV.foreach($datafile, :quote_char => '"', :col_sep =>'|', :row_sep =>:auto, :encoding => 'windows-1251:utf-8') do |row|
  if row[1] == "2"
    # holding information => "MFH"|"2"|"T Rowe Price Corporate Income Fund"|"WellPoint, 5.00%, 1/15/11"|"2010-05-31"|"373000"
    fname = row[2]
    #holdingCompany = row[3]
    #holdingDate = row[4]
    if fname
      hash = {"HoldingCompany" => row[3], "HoldingDate" => row[4], "HoldingValue" => row[5]}
      #puts "#{fname} => #{row[3]}"
      #puts "#{fname} => #{hash}"
      json = JSON.generate hash
      setkey = "FUND::HOLDINGS::#{fname}"
      score = row[5]
      $redisdb.zadd setkey, score, json
    end
  elsif row[1] == "3"
    # asset allocation => "MFH"|"3"|"UBS Global Allocation Fund"|"Bond"|"9.77"|"2010-09-30"
    fname = row[2]
    if fname
      hash = {"Asset" => row[3], "Allocation" => row[4], "Date" => row[5]}
      #puts "#{fname} => #{hash}"
      json = JSON.generate hash
      setkey = "FUND::ALLOCATION::ASSET::#{fname}"
      score = row[4]
      $redisdb.zadd setkey, score, json
    end        
  elsif row[1] == "4"
    # sector allocation => "MFH"|"4"|"UBS Global Allocation Fund"|"Commercial Banks"|"2010-06-30"|"2.94"
    fname = row[2]
    if fname
      hash = {"Sector" => row[3], "Date" => row[4], "Allocation" => row[5]}
      #puts "#{fname} => #{hash}"
      json = JSON.generate hash
      setkey = "FUND::ALLOCATION::SECTOR::#{fname}"
      score = row[5]
      $redisdb.zadd setkey, score, json
    end    
  elsif row[1] == "5"
    # geography allocation => "MFH"|"5"|"Aquila Three Peaks Opportunity Growth Fund"|"United States of America"|"6.9"|"2010-09-30"
    fname = row[2]
    if fname
      hash = {"Country" => row[3], "Allocation" => row[4], "Date" => row[5]}
      #puts "#{fname} => #{hash}"
      json = JSON.generate hash
      setkey = "FUND::ALLOCATION::GEOGRAPHY::#{fname}"
      score = row[4]
      $redisdb.zadd setkey, score, json
    end
  end
end