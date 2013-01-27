#!/usr/bin/env ruby -wKU
require 'csv'
require 'redis'
require 'json'

$redisdb = Redis.new
$redisdb.select 1

$datafile = ARGV[0]
if $datafile && File.exist?($datafile)
  CSV.foreach($datafile, :quote_char => '|', :col_sep =>'|', :row_sep =>:auto, :encoding => 'windows-1251:utf-8') do |row|
    if row[1] == "2"
      # holding information => "MFH"|"2"|"T Rowe Price Corporate Income Fund"|"WellPoint, 5.00%, 1/15/11"|"2010-05-31"|"373000"
      fname = row[2]
      if fname
        date = row[4]
        if date
          # throw the date into holdings:dates bucket for this fund
	        setkey = "fund:#{fname}:holdings:dates"
          $redisdb.zadd setkey, 0, date
          
          hash = {"HoldingCompany" => row[3], "HoldingValue" => row[5]}
          json = JSON.generate hash
          setkey = "fund:#{fname}:holdings:#{date}"
          score = row[5]
          $redisdb.zadd setkey, score, json
        end
      end
    elsif row[1] == "3"
      # asset allocation => "MFH"|"3"|"UBS Global Allocation Fund"|"Bond"|"9.77"|"2010-09-30"
      fname = row[2]
      if fname
        date = row[5]
        if date
          # throw the date into asset.allocation:dates bucket for this fund
	        setkey = "fund:#{fname}:asset.allocation:dates"
          $redisdb.zadd setkey, 0, date

          hash = {"Asset" => row[3], "Allocation" => row[4]}
          json = JSON.generate hash
          setkey = "fund:#{fname}:asset.allocation:#{date}"
          score = row[4]
          $redisdb.zadd setkey, score, json
        end
      end        
    elsif row[1] == "4"
      # sector allocation => "MFH"|"4"|"UBS Global Allocation Fund"|"Commercial Banks"|"2010-06-30"|"2.94"
      fname = row[2]
      if fname
        date = row[4]
        if date
          # throw the date into sector.allocation:dates bucket for this fund
	        setkey = "fund:#{fname}:sector.allocation:dates"
          $redisdb.zadd setkey, 0, date

          hash = {"Sector" => row[3], "Allocation" => row[5]}
          json = JSON.generate hash
          setkey = "fund:#{fname}:sector.allocation:#{date}"
          score = row[5]
          $redisdb.zadd setkey, score, json
        end
      end    
    elsif row[1] == "5"
      # geography allocation => "MFH"|"5"|"Aquila Three Peaks Opportunity Growth Fund"|"United States of America"|"6.9"|"2010-09-30"
      fname = row[2]
      if fname
        date = row[5]
        if date
          # throw the date into geo.allocation:dates bucket for this fund
	        setkey = "fund:#{fname}:geo.allocation:dates"
          $redisdb.zadd setkey, 0, date

          hash = {"Country" => row[3], "Allocation" => row[4]}
          json = JSON.generate hash
          setkey = "fund:#{fname}:geo.allocation:#{date}"
          score = row[4]
          $redisdb.zadd setkey, score, json
        end
      end
    end
	end # CSV.foreach
end # if File.exist?($datafile)