=begin
  Redis DB layout for fund holdings data is defined as follows:
  
  key => "fund.name:#{fname}:holding.dates"
  val => sorted set of dates for which fund holdings information is available.
  
  key => "fund.name:#{fname}:holdings:#{date}"
  val => sorted set of json objects of holding information hashtables.
=end

#!/usr/bin/env ruby -wKU
require 'csv'
require 'redis'
require 'json'
require 'getoptlong'

# call using "ruby load-mf-holdings.rb -i<input file>"  
unless ARGV.length == 1
  puts "Usage: ruby load-mf-holdings.rb -i<input file>" 
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

# redis db connection
$redisdb = Redis.new
$redisdb.select 0

if $infile && File.exist?($infile)
  dbkey = nil
  CSV.foreach($infile, :col_sep =>',', :encoding => 'windows-1251:utf-8') do |row|
    if row[1] == "1" # Header
    #As of Date,Filing Date,CIK Number,Series Number,Series Name,Total Stocks Value,Total Assets,Total Net Assets,Series Ticker 1,Series Ticker 2,Series Ticker 3,Series Ticker 4
    #30/04/2012,05/07/2012,1469192,28539,MainStay 130/30 Core Fund,"62,75,33,559","46,86,38,667","46,87,69,933",MYCTX,MYCCX,MYCIX,MYCNX    if row[1] == "2"
      fname = row[6]
      if fname
        date = row[2]
        if date
          # throw the date into holding dates bucket for this fund
          $redisdb.zadd "fund.name:#{fname}:holding.dates", 0, date
          
          # create the dbkey to store holding information
          dbkey = "fund.name:#{fname}:holdings:#{date}"
        end
      end
    elsif row[1] == "2" # Holding Data
      #Holding Type,Holding Name,Share,Value,Holding Face Amount,Holdings num of contracts,Futures Unrealized gain or loss,,,,,
      #Stock,"Alliant Techsystems, Inc.","2,691","1,43,430",,,,,,,,
      hname = row[3]
      if hname
        if dbkey
          hash = {
            :HoldingType => row[2],
            :HoldingName => row[3],
            :HoldingShares => row[4],
            :HoldingValue => row[5]
          }
          json = JSON.generate hash
          score = hash['HoldingValue'].to_i
          puts score
          $redisdb.zadd dbkey, score, json
        end
      end        
    end
	end # CSV.foreach
end # if File.exist?($infile)

=begin rdoc
 * Name: load-mf-holdings.rb
 * Description: Loads fund holdings data file into redis db.
 * Call using "ruby load-mf-holdings.rb -i, --infile=<fund holdings file>"  
 * Author: Murthy Gudipati
 * Date:25-Feb-2013
 * License: Saven Technologies Inc.
=end
