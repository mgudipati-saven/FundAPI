=begin
  Redis DB layout for fund holdings data is defined as follows:
  
  key => "fund:#{fname}:holdings:dates"
  val => sorted set of dates for which fund holdings information is available.
  e.g.=> "fund:#{fname}:holdings:dates" => ['20121212', '20111212', ...]
  
  key => "fund:#{fname}:holdings:#{date}"
  val => sorted set of json objects of holding information hashtables.
          [ {"HoldingCompany" => "Apple Inc", "HoldingValue" => "10000000"},
            {"HoldingCompany" => "Microsoft Inc", "HoldingValue" => "999999"},
            {"HoldingCompany" => "Google Inc", "HoldingValue" => "888888"},
            ...,
            ...
          ]

  key => "fund:#{fname}:asset.allocation:dates"
  val => sorted set of dates for which fund asset allocation information is available.
  e.g.=> "fund:#{fname}:asset.allocation:dates" => ['20121212', '20111212', ...]

  key => "fund:#{fname}:asset.allocation:#{date}"
  val => sorted set of json objects of asset allocation information hashtables.
          [ {"Asset" => row[3], "Allocation" => row[4]},
            {"Asset" => row[3], "Allocation" => row[4]},
            {"Asset" => row[3], "Allocation" => row[4]},
            ...,
            ...
          ]

  key => "fund:#{fname}:sector.allocation:dates"
  val => sorted set of dates for which fund sector allocation information is available.
  e.g.=> "fund:#{fname}:sector.allocation:dates" => ['20121212', '20111212', ...]

  key => "fund:#{fname}:sector.allocation:#{date}"
  val => sorted set of json objects of sector allocation information hashtables.
          [ {"Sector" => row[3], "Allocation" => row[4]},
            {"Sector" => row[3], "Allocation" => row[4]},
            {"Sector" => row[3], "Allocation" => row[4]},
            ...,
            ...
          ]

  key => "fund:#{fname}:geo.allocation:dates"
  val => sorted set of dates for which fund geography allocation information is available.
  e.g.=> "fund:#{fname}:geo.allocation:dates" => ['20121212', '20111212', ...]

  key => "fund:#{fname}:geo.allocation:#{date}"
  val => sorted set of json objects of geography allocation information hashtables.
          [ {"Country" => row[3], "Allocation" => row[4]},
            {"Country" => row[3], "Allocation" => row[4]},
            {"Country" => row[3], "Allocation" => row[4]},
            ...,
            ...
          ]
=end

#!/usr/bin/env ruby -wKU
require 'csv'
require 'redis'
require 'json'
require 'getoptlong'

# call using "ruby load-holding-data.rb -i<input file>"  
unless ARGV.length == 1
  puts "Usage: ruby load-holding-data.rb -i<input file>" 
  exit  
end  
  
$infile = ''
# specify the options we accept and initialize the option parser  
opts = GetoptLong.new(  
  [ "--infile", "-i", GetoptLong::REQUIRED_ARGUMENT ]
)  

# process the parsed options  
opts.each do |opt, arg|  
  case opt  
    when '--infile'  
      $infile = arg  
  end  
end

$redisdb = Redis.new
$redisdb.select 0

if $infile && File.exist?($infile)
  CSV.foreach($infile, :quote_char => '|', :col_sep =>'|', :row_sep =>:auto, :encoding => 'windows-1251:utf-8') do |row|
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
end # if File.exist?($infile)

=begin rdoc
 * Name: load-holdings-data.rb
 * Description: Loads fund holdings data file into redis db.
 * Call using "ruby load-holdings-data.rb -i, --infile=<fund holdings file>"  
 * Author: Murthy Gudipati
 * Date: 07-Feb-2011
 * License: Saven Technologies Inc.
=end
