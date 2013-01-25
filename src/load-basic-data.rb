require 'csv'
require 'redis'
require 'json'

$redisdb = Redis.new

$datafile = ARGV[0]
if $datafile && File.exist?($datafile)
	# clean up current database...
=begin
	keys = $redisdb.keys "FUND::NAME::*"
	keys.each do |key|
		$redisdb.del key
	end
		  	
	keys = $redisdb.keys "FUND::SPONSOR::*"
	keys.each do |key|
		$redisdb.del key
	end

	keys = $redisdb.keys "FUND::GROUP::PRIMARY::*"
	keys.each do |key|
		$redisdb.del key
	end

	keys = $redisdb.keys "FUND::GROUP::SECONDARY::*"
	keys.each do |key|
		$redisdb.del key
	end

	keys = $redisdb.keys "FUND::BENCHMARKINDEX::*"
	keys.each do |key|
		$redisdb.del key
	end

	keys = $redisdb.keys "FUND::BASIC::*"
	keys.each do |key|
		$redisdb.del key
	end

	keys = $redisdb.keys "FUND::PERFORMANCE::*"
	keys.each do |key|
		$redisdb.del key
	end

	keys = $redisdb.keys "FUND::HISTORY::*"
	keys.each do |key|
		$redisdb.del key
	end
=end
	CSV.foreach($datafile, :quote_char => '|', :col_sep =>'|', :row_sep =>:auto) do |row|
	  #print "#{row.size}=>"
	  #p row
	  if row[1] == "2"
	    # record type 2 => fundamental data
	    fticker = row[4]
	    if fticker
	      #puts "#{fticker} => #{row[2]}
	      fseries = row[2]
	      if fseries
	        # throw into the appropripate fund.series:<fund series name>:tickers bucket...
	        dbkey = "fund.series:#{fseries}:tickers"
	        $redisdb.sadd dbkey, fticker
	      end
	      fsponsor = row[3]
	      if fsponsor
	        # throw into the appropripate fund.sponsor:<fund sponsor name>:tickers bucket...
	        dbkey = "fund.sponsor:#{fsponsor}:tickers"
	        $redisdb.sadd dbkey, fticker

	        # throw into the appropripate fund.sponsor:<fund sponsor name>:series bucket...
	        dbkey = "fund.sponsor:#{fsponsor}:series"
	        $redisdb.sadd dbkey, fseries
	      end
	      pgroup = row[8]
	      if pgroup
	        # throw into the appropripate fund.primary.group:<primary group>:tickers bucket...
	        dbkey = "fund.primary.group:#{pgroup}:tickers"
	        $redisdb.sadd dbkey, fticker
	      end
	      sgroup = row[9]
	      if sgroup
	        # throw into the appropripate fund.secondary.group:<secondary group>:tickers bucket...
	        dbkey = "fund.secondary.group:#{sgroup}:tickers"
	        $redisdb.sadd dbkey, fticker
	      end
	      bindex = row[9]
	      if bindex
	        # throw into the appropripate fund.benchmark.index:<benchmark index>:tickers bucket...
	        dbkey = "fund.benchmark.index:#{bindex}:tickers"
	        $redisdb.sadd dbkey, fticker
	      end

	      # update fees data...
		    dbkey = "fund:#{fticker}:fees"
	      $redisdb.hmset dbkey, "ManagementFees", row[15],
                              "b12-1Fee", row[18],
                              "RedemptionFee", row[19],
                              "RedemptionFeeDuration", row[20],
                              "SalesCharge", row[21],
	                            "LoadType", row[22],
	                            "DeferredLoad", row[23],
	                            "DeferredLoadDuration", row[24]
	      
	      # update ratios data...
		    dbkey = "fund:#{fticker}:ratios"
	      $redisdb.hmset dbkey, "TotalExpenseRatio", row[16],
                              "NetExpenseRatio", row[17],
	                            "Turnover", row[27],
	                            "TurnoverDate", row[28]

	      # update managers data...
		    dbkey = "fund:#{fticker}:managers"
	      $redisdb.hmset dbkey, "TeamManagement", row[66],
	                            "ManagerName1", row[67],
	                            "ManagerName2", row[68],
	                            "ManagerName3", row[69],
	                            "ManagerTenure1", row[70],
	                            "ManagerTenure2", row[71],
	                            "ManagerTenure3", row[72]

	      # update profile data...
		    dbkey = "fund:#{fticker}:profile"
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
		    dbkey = "fund:#{fticker}:sponsor"
	      $redisdb.hmset dbkey, "Sponsor", row[3],
                              "SponsorPhone", row[75],
                              "SponsorWebsite", row[76],
                              "SponsorStreet", row[77],
                              "SponsorStreet2", row[78],
                              "SponsorCity", row[79],
                              "SponsorState", row[80],
                              "SponsorZip", row[81]

	      # update basic data...
		    dbkey = "fund:#{fticker}:basics"
	      $redisdb.hmset dbkey, "Symbol", fticker,
                              "Name", row[2],
	                            "CUSIP", row[5],
	                            "ProspectusDate", row[10],
	                            "BenchmarkIndex", row[14],
	                            "FiscalYearEndDate", row[83]
	                            
		    # update performance data...
	      dbkey = "fund:#{fticker}:perf"
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
	    end
	  elsif row[1] == "3"
	    # record type 3 => historical data
	    # "MF"|"3"|"CAAMX"|"2005-12-31"|"8489000"|"5"|"7.01"|""
	    fticker = row[2]
	    if fticker
        hash = {:Date => row[3], :TotalNetAssets => row[4], :Turnover => row[5], :TotalReturns => row[6]}
        #puts "#{fticker} => #{hash}"
        json = JSON.generate hash
        setkey = "fund:#{fticker}:hist"
        $redisdb.zadd setkey, 0, json
	    end
	  end
	end # CSV.foreach
end # if File.exist?($datafile)