=begin
  Redis DB layout for fund holdings and allocations data is defined as follows:

  key => "MFNames"
  val => sorted set of mutual fund names.
  
  key => "AssetNames"
  val => sorted set of asset names.

  key => "SectorNames"
  val => sorted set of sector names.

  key => "CountryNames"
  val => sorted set of country names.

  key => "HoldingNames"
  val => sorted set of holding company names.

  key => "MFID:#{fundid}:HoldingID:#{holdingid}"
  val => hashtable of holding dates and holding values.
  
  key => "MFID:#{fundid}:AssetID:#{assetid}"
  val => hashtable of asset allocation dates and values.

  key => "MFID:#{fundid}:SectorID:#{sectorid}"
  val => hashtable of sector allocation dates and values.

  key => "MFID:#{fundid}:CountryID:#{countryid}"
  val => hashtable of country allocation dates and values.
=end

#!/usr/bin/env ruby -wKU
require 'csv'
require 'redis'
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
  CSV.foreach($infile, :quote_char => '|', :col_sep =>'|', :encoding => 'windows-1251:utf-8') do |row|
    if row[1] == "2"
      # holding information => "MFH"|"2"|"T Rowe Price Corporate Income Fund"|"WellPoint, 5.00%, 1/15/11"|"2010-05-31"|"373000"
      fund = row[2].strip
      if fund
        # obtain the fund id
        fid = $redisdb.zrank "MFNames", fund
        if !fid
          # add the fund
          $redisdb.zadd "MFNames", 0, fund
          fid = $redisdb.zrank "MFNames", fund
        end
        holding = row[3].strip
        if holding
          # obtain the holding id
          hid = $redisdb.zrank "HoldingNames", holding
          if !hid
            # add the holding
            $redisdb.zadd "HoldingNames", 0, holding
            hid = $redisdb.zrank "HoldingNames", holding
          end          
          if row[4] and row[5]
            $redisdb.hset "MFID:#{fid}:HoldingID:#{hid}", row[4], row[5].to_i
          end
        end
      end
    elsif row[1] == "3"
      # asset allocation => "MFH"|"3"|"UBS Global Allocation Fund"|"Bond"|"9.77"|"2010-09-30"
      fund = row[2].strip
      if fund
        # obtain the fund id
        fid = $redisdb.zrank "MFNames", fund
        if !fid
          # add the fund
          $redisdb.zadd "MFNames", 0, fund
          fid = $redisdb.zrank "MFNames", fund
        end
        asset = row[3].strip
        if asset
          # obtain the asset id
          aid = $redisdb.zrank "AssetNames", asset
          if !aid
            # add the asset
            $redisdb.zadd "AssetNames", 0, asset
            aid = $redisdb.zrank "AssetNames", asset
          end          
          if row[4] and row[5]
            $redisdb.hset "MFID:#{fid}:AssetID:#{aid}", row[5], row[4].to_f
          end
        end
      end
    elsif row[1] == "4"
      # sector allocation => "MFH"|"4"|"UBS Global Allocation Fund"|"Commercial Banks"|"2010-06-30"|"2.94"
      fund = row[2].strip
      if fund
        # obtain the fund id
        fid = $redisdb.zrank "MFNames", fund
        if !fid
          # add the fund
          $redisdb.zadd "MFNames", 0, fund
          fid = $redisdb.zrank "MFNames", fund
        end
        sector = row[3].strip
        if sector
          # obtain the sector id
          sid = $redisdb.zrank "SectorNames", sector
          if !sid
            # add the sector
            $redisdb.zadd "SectorNames", 0, sector
            sid = $redisdb.zrank "SectorNames", sector
          end          
          if row[4] and row[5]
            $redisdb.hset "MFID:#{fid}:SectorID:#{sid}", row[4], row[5].to_f
          end
        end
      end
    elsif row[1] == "5"
      # geography allocation => "MFH"|"5"|"Aquila Three Peaks Opportunity Growth Fund"|"United States of America"|"6.9"|"2010-09-30"
      fund = row[2].strip
      if fund
        # obtain the fund id
        fid = $redisdb.zrank "MFNames", fund
        if !fid
          # add the fund
          $redisdb.zadd "MFNames", 0, fund
          fid = $redisdb.zrank "MFNames", fund
        end
        country = row[3].strip
        if country
          # obtain the country id
          cid = $redisdb.zrank "CountryNames", country
          if !cid
            # add the county
            $redisdb.zadd "CountryNames", 0, country
            cid = $redisdb.zrank "CountryNames", country
          end          
          if row[4] and row[5]
            $redisdb.hset "MFID:#{fid}:CountryID:#{cid}", row[5], row[4].to_f
          end
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
