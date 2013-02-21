=begin
  Redis DB layout for fund data is defined as follows:
  
  key => "MFTickers"
  val => sorted set of fund tickers.

  key => "MFNames"
  val => sorted set of fund names.
  e.g.=> "fund.names" => ['AC ONE China Fund, ...]

  key => "MFID:#{fundid}:Tickers".
  val => sorted set of fund tickers for the given fund.

  key => "MFSponsors"
  val => sorted set of fund sponsors.
  
  key => "MFSponsor:#{sponsorid}:Tickers".
  val => sorted set of fund tickers for the given fund sponsor.
  
  key => "MFSponsor:#{sponsorid}:FundNames".
  val => sorted set of fund names for the given sponsor.
    
  key => "MFPrimaryGroups".
  val => sorted set of fund primary groups.

  key => "MFPrimaryGroupID:#{groupid}:Tickers".
  val => sorted set of fund tickers that belong to the given primary group.
  
  key => "MFSecondaryGroups".
  val => sorted set of fund secondary groups.
  
  key => "MFSecondaryGroupID:#{groupid}:Tickers".
  val => sorted set of fund tickers that belong to the given secondary group.

  key => "MFBenchmarkIndices".
  val => sorted set of benchmark indices.
  
  key => "MFBenchmarkIndexID:#{indexid}:Tickers".
  val => sorted set of fund tickers that belong to the given benchmark index.

  key => "MFTicker:#{fticker}:Fees"
  val => hashtable of fund fee related data elements.
          "ManagementFees",
          "b12-1Fee",
          "RedemptionFee",
          "RedemptionFeeDuration",
          "SalesCharge",
          "LoadType",
          "DeferredLoad",
          "DeferredLoadDuration"
  
  key => "MFTicker:#{fticker}:Ratios"
  val => hashtable of fund expense related data elements.
          "TotalExpenseRatio",
          "NetExpenseRatio",
          "Turnover",
          "TurnoverDate"

  key => "MFTicker:#{fticker}:Managers"
  val => hashtable of fund management related data elements.
          "TeamManagement",
          "ManagerName1",
          "ManagerName2",
          "ManagerName3",
          "ManagerTenure1",
          "ManagerTenure2",
          "ManagerTenure3"

  key => "MFTicker:#{fticker}:Profile"
  val => hashtable of fund profile related data elements.
          "Name",
          "ShareClass",
          "InceptionDate",
          "PrimaryGroup",
          "SecondaryGroup",
          "Objective",
          "Strategy",
          "Status",
          "TotalNetAssets",
          "TotalNetAssetsDate",
          "InitialInvestment",
          "IncrementalInvestment",
          "IRAInitialInvestment",
          "IRAIncrementalInvestment",
          "InitialAutomaticInvestmentPlan",
          "ExpenseWaiverType",
          "ExpenseWaiverExpiryDate",
          "ExpenseWaiverOptionCode",
          "DividendFrequency"

  key => "MFTicker:#{fticker}:Sponsor"
  val => hashtable of fund sponsor related data elements.
          "Sponsor",
          "SponsorPhone",
          "SponsorWebsite",
          "SponsorStreet",
          "SponsorStreet2",
          "SponsorCity",
          "SponsorState",
          "SponsorZip"

  key => "MFTicker:#{fticker}:Basics"
  val => hashtable of fund basic data elements.
          "Symbol",
          "Name",
          "CUSIP",
          "ProspectusDate",
          "BenchmarkIndex",
          "FiscalYearEndDate"
                        
  key => "MFTicker:#{fticker}:Returns"
  val => hashtable of fund performance or returns related data elements.
          "Yr1TotalReturns",
          "Yr3TotalReturns",
          "Yr5TotalReturns",
          "Yr10TotalReturns",
          "LifeTotalReturns",
          "TotalReturnsDate",
          "BestQuarterReturns",
          "BestQuarterReturnsDate",
          "WorstQuarterReturns",
          "WorstQuarterReturnsDate",
          "Yr1AfterTaxReturns",
          "Yr3AfterTaxReturns",
          "Yr5AfterTaxReturns",
          "Yr10AfterTaxReturns",
          "LifeAfterTaxReturns",
          "Yr1AfterTaxAndSalesReturns",
          "Yr3AfterTaxAndSalesReturns",
          "Yr5AfterTaxAndSalesReturns",
          "Yr10AfterTaxAndSalesReturns",
          "LifeAfterTaxAndSalesReturns",
          "QuartileRanking",
          "PercentileRanking",
          "PeerGroupReturns",
          "PeerGroupCount",
          "Month12Yield",
          "YieldDate"

  key => "MFTicker:#{fticker}:TotalNetAssets"
  val => hashtable of dates and values for which total net assets are available.
    
  key => "MFTicker:#{fticker}:TotalReturns"
  val => hashtable of dates and values for which total returns are available.

  key => "MFTicker:#{fticker}:Turnover"
  val => hashtable of dates and values for which turnovers are available.
=end

require 'csv'
require 'redis'
require 'getoptlong'

# call using "ruby load-basic-data.rb -i<input file>"  
unless ARGV.length == 1
  puts "Usage: ruby load-basic-data.rb -i<input file>" 
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
  puts "Processing the fund basic data file: #{$infile}..."
	CSV.foreach($infile, :quote_char => '|', :col_sep =>'|', :row_sep =>:auto) do |row|
	  #print "#{row.size}=>"
	  #p row
	  if row[1] == "2"
      #MF|2|DWS Alternative Asset Allocation Fund|Deutsche Investment Management Americas Inc|AAAAX|233376763|A|07/30/2007|Alternative|Alternative Strategy|08/01/2012|The fund seeks capital appreciation.|MAIN INVESTMENTS. The fund is a fund-of-funds, which means its assets are invested in a combination of other DWS funds, certain other securities and derivative instruments (the use of derivatives by the fund and the underlying funds in which the fund invests is described below in Global Tactical Asset Allocation Strategy and Derivatives). The fund seeks to achieve its objective by investing in alternative (or nontraditional) asset categories and investment strategies. The fund may also invest in securities of Exchange Traded Funds (ETFs) or hedge funds when the desired economic exposure to a particular asset category or investment strategy is not available through a DWS fund (ETFs, hedge funds and DWS funds are collectively referred to as underlying funds). The fund's allocations among the underlying funds may vary over time. MANAGEMENT PROCESS. Portfolio management allocates the fund's assets among underlying funds that emphasize the following strategies and/or asset categories: market neutral, inflation-protection, commodities, real estate, floating rate loans, infrastructure, emerging markets and other alternative strategies.||Barclays Capital US Aggregate Bond|0.20|2.10|1.91|0.25||0|5.75|Y||0|542.557665|03/31/2010|32|03/31/2012|37.04|2.4|65.58|0.8||1000|50|500|50|Y|Contractual|07/31/2013||-9.01||||-0.48|2011-12-31|15.11|Q2 2009|-16.48|Q4 2008|-10.22||||-1.71|-5.80||||-1.10|||||Team Management|Robert Wang|Inna Okounkova|Thomas Picciochi|2007|2007|2007|3.1|7/31/2010|800-621-1048|www.dws-investments.com|345 Park Avenue||New York|NY|10154|Annually|10/31/2011
	    # record type 2 => fundamental data
	    fticker = row[4]
	    if fticker
        # throw into the MFTickers bucket...
        $redisdb.zadd :MFTickers, 0, fticker.strip

	      fname = row[2]
	      if fname
          # throw into the MFNames bucket...
          $redisdb.zadd :MFNames, 0, fname.strip
          fid = $redisdb.zrank :MFNames, fname.strip
          if fid
  	        # map of fund names and the associated tickers...
            $redisdb.zadd "MFID:#{fid}:Tickers", 0, fticker.strip
          end
  	      fsponsor = row[3]
  	      if fsponsor
  	        # throw into the MFSponsors bucket...
            $redisdb.zadd :MFSponsors, 0, fsponsor.strip
            sid = $redisdb.zrank :MFSponsors, fsponsor.strip
            if sid
    	        # map of fund sponsors and the associated tickers...
              $redisdb.zadd "MFSponsorID:#{sid}:Tickers", 0, fticker.strip

    	        # map of fund sponsors and the associated funds...
    	        $redisdb.zadd "MFSponsorID:#{sid}:FundNames", 0, fname.strip
            end
  	      end
	      end
	      pgroup = row[8]
	      if pgroup
	        # throw into the MFPrimaryGroups bucket...
          $redisdb.zadd :MFPrimaryGroups, 0, pgroup.strip
          gid = $redisdb.zrank :MFPrimaryGroups, pgroup.strip
          if gid
  	        # map of fund primary groups and the associated tickers...
            $redisdb.zadd "MFPrimaryGroupID:#{gid}:Tickers", 0, fticker.strip
          end
	      end
	      sgroup = row[9]
	      if sgroup
	        # throw into the MFSecondaryGroups bucket...
          $redisdb.zadd :MFSecondaryGroups, 0, sgroup.strip
          gid = $redisdb.zrank :MFSecondaryGroups, sgroup.strip
          if gid
  	        # map of fund secondary groups and the associated tickers...
            $redisdb.zadd "MFSecondaryGroupID:#{gid}:Tickers", 0, fticker.strip
          end
	      end
	      bindex = row[14]
	      if bindex
	        # throw into the MFBenchmarkIndices bucket...
          $redisdb.zadd :MFBenchmarkIndices, 0, bindex.strip
          bid = $redisdb.zrank :MFBenchmarkIndices, bindex.strip
          if bid
  	        # map of fund benchmark indices and the associated tickers...
            $redisdb.zadd "MFBenchmarkIndexID:#{bid}:Tickers", 0, fticker.strip
          end
	      end
	      # update fees data...
		    dbkey = "MFTicker:#{fticker}:Fees"
	      $redisdb.hmset dbkey, "ManagementFees", row[15],
                              "b12-1Fee", row[18],
                              "RedemptionFee", row[19],
                              "RedemptionFeeDuration", row[20],
                              "SalesCharge", row[21],
	                            "LoadType", row[22],
	                            "DeferredLoad", row[23],
	                            "DeferredLoadDuration", row[24]
	      
	      # update ratios data...
		    dbkey = "MFTicker:#{fticker}:Ratios"
	      $redisdb.hmset dbkey, "TotalExpenseRatio", row[16],
                              "NetExpenseRatio", row[17],
	                            "Turnover", row[27],
	                            "TurnoverDate", row[28]

	      # update managers data...
		    dbkey = "MFTicker:#{fticker}:Managers"
	      $redisdb.hmset dbkey, "TeamManagement", row[66],
	                            "ManagerName1", row[67],
	                            "ManagerName2", row[68],
	                            "ManagerName3", row[69],
	                            "ManagerTenure1", row[70],
	                            "ManagerTenure2", row[71],
	                            "ManagerTenure3", row[72]

	      # update profile data...
		    dbkey = "MFTicker:#{fticker}:Profile"
	      $redisdb.hmset dbkey, "Name", row[2],
	                            "ShareClass", row[6],
	                            "InceptionDate", row[7],
	                            "PrimaryGroup", row[8],
	                            "SecondaryGroup", row[9],
	                            "Objective", row[11],
	                            "Strategy", row[12],
	                            "Status", row[13],
	                            "TotalNetAssets", row[25],
	                            "TotalNetAssetsDate", row[26],
	                            "InitialInvestment", row[34],
	                            "IncrementalInvestment", row[35],
	                            "IRAInitialInvestment", row[36],
	                            "IRAIncrementalInvestment", row[37],
	                            "InitialAutomaticInvestmentPlan", row[38],
	                            "ExpenseWaiverType", row[39],
	                            "ExpenseWaiverExpiryDate", row[40],
	                            "ExpenseWaiverOptionCode", row[41],
	                            "DividendFrequency", row[82]

	      # update sponsor data...
		    dbkey = "MFTicker:#{fticker}:Sponsor"
	      $redisdb.hmset dbkey, "Sponsor", row[3],
                              "SponsorPhone", row[75],
                              "SponsorWebsite", row[76],
                              "SponsorStreet", row[77],
                              "SponsorStreet2", row[78],
                              "SponsorCity", row[79],
                              "SponsorState", row[80],
                              "SponsorZip", row[81]

	      # update basic data...
		    dbkey = "MFTicker:#{fticker}:Basics"
	      $redisdb.hmset dbkey, "Symbol", fticker,
                              "Name", row[2],
	                            "CUSIP", row[5],
	                            "ProspectusDate", row[10],
	                            "BenchmarkIndex", row[14],
	                            "FiscalYearEndDate", row[83]
	                            
		    # update performance data...
	      dbkey = "MFTicker:#{fticker}:Returns"
	      $redisdb.hmset dbkey, "Yr1TotalReturns", row[42],
	                            "Yr3TotalReturns", row[43],
	                            "Yr5TotalReturns", row[44],
	                            "Yr10TotalReturns", row[45],
	                            "LifeTotalReturns", row[46],
	                            "TotalReturnsDate", row[47],
	                            "BestQuarterReturns", row[48],
	                            "BestQuarterReturnsDate", row[49],
	                            "WorstQuarterReturns", row[50],
	                            "WorstQuarterReturnsDate", row[51],
	                            "Yr1AfterTaxReturns", row[52],
	                            "Yr3AfterTaxReturns", row[53],
	                            "Yr5AfterTaxReturns", row[54],
	                            "Yr10AfterTaxReturns", row[55],
	                            "LifeAfterTaxReturns", row[56],
	                            "Yr1AfterTaxAndSalesReturns", row[57],
	                            "Yr3AfterTaxAndSalesReturns", row[58],
	                            "Yr5AfterTaxAndSalesReturns", row[59],
	                            "Yr10AfterTaxAndSalesReturns", row[60],
	                            "LifeAfterTaxAndSalesReturns", row[61],
	                            "QuartileRanking", row[62],
	                            "PercentileRanking", row[63],
	                            "PeerGroupReturns", row[64],
	                            "PeerGroupCount", row[65],
	                            "Month12Yield", row[73],
	                            "YieldDate", row[74]
	    end # if fticker
	  elsif row[1] == "3"
	    # record type 3 => historical data
	    # "MF"|"3"|"CAAMX"|"2005-12-31"|"8489000"|"5"|"7.01"|""
	    fticker = row[2]
	    if fticker
        if row[3] and row[4]
          $redisdb.hset "MFTicker:#{fticker.strip}:TotalNetAssets", row[3], row[4].to_i
        end
        if row[3] and row[5]
          $redisdb.hset "MFTicker:#{fticker.strip}:Turnover", row[3], row[5].to_i
        end
        if row[3] and row[6]
          $redisdb.hset "MFTicker:#{fticker.strip}:TotalReturns", row[3], row[6].to_f
        end
	    end
=begin
	    if fticker
        hash = {:Date => row[3], :TotalNetAssets => row[4], :Turnover => row[5], :TotalReturns => row[6]}
        #puts "#{fticker} => #{hash}"
        json = JSON.generate hash
        setkey = "fund:#{fticker}:hist"
        $redisdb.zadd setkey, 0, json
	    end
=end
	  end
	end # CSV.foreach
end # if File.exist?($infile)

=begin rdoc
 * Name: load-basic-data.rb
 * Description: Loads fund basic data file into redis db.
 * Call using "ruby load-basic-data.rb -i, --infile=<fund basic file>"  
 * Author: Murthy Gudipati
 * Date: 07-Feb-2011
 * License: Saven Technologies Inc.
=end
