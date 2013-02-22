=begin
  Redis DB layout for fund data is defined as follows:

  key => "next.mf.id"
  val => a counter for mutual funds.
  
  key => "fund.tickers"
  val => sorted set of fund tickers.
  e.g.=> "fund.tickers" => ['AAAAX', 'AAABX', ...]

  key => "fund.names"
  val => sorted set of fund names.
  e.g.=> "fund.names" => ['AC ONE China Fund, ...]

  key => "fund.name:#{fname}:tickers".
  val => sorted set of fund tickers for the given fund name.
  e.g.=> "fund.name:Fidelity Magellan:tickers" => ['FMAGX']
  
  key => "fund.sponsors"
  val => sorted set of fund sponsors.
  e.g.=> "fund.sponsors" => ['Brinton Eaton', ...]
  
  key => "fund.sponsor:#{fsponsor}:tickers".
  val => sorted set of fund tickers for the given fund sponsor.
  e.g.=> "fund.sponsor:Brinton Eaton:tickers" => ['GDAAX', 'GDAIX', 'GDAMX']
  
  key => "fund.sponsor:#{fsponsor}:names".
  val => sorted set of fund names for the given sponsor.
  e.g.=> "fund.sponsor:Brinton Eaton:names" => ['The Giralda Fund']
  
  key => "fund.primary.groups".
  val => sorted set of fund primary groups.
  e.g.=> "fund.primary.groups" => ["US Equity", ...]
  
  key => "fund.primary.group:#{pgroup}:tickers".
  val => sorted set of fund tickers that belong to the given primary group.
  e.g.=> "fund.primary.group:US Equity:tickers" => ["FMAGX", ...]
  
  key => "fund.secondary.groups".
  val => sorted set of fund secondary groups.
  e.g.=> "fund.secondary.groups" => ["Small Cap Growth", ...]
  
  key => "fund.secondary.group:#{sgroup}:tickers".
  val => sorted set of fund tickers that belong to the given secondary group.
  e.g.=> "fund.secondary.group:Small Cap Growth:tickers" => ["WSMGX", ...]

  key => "fund.benchmark.indices".
  val => sorted set of benchmark indices.
  e.g.=> "fund.benchmark.indices" => ["S&P 500", ...]
  
  key => "fund.benchmark.index:#{bindex}:tickers".
  val => sorted set of fund tickers that belong to the given benchmark index.
  e.g.=> "fund.benchmark.index:S & P 500:tickers" => ["WRESX", ...]

  key => "fund:#{fticker}:fees"
  val => hashtable of fund fee related data elements.
          "ManagementFees",
          "b12-1Fee",
          "RedemptionFee",
          "RedemptionFeeDuration",
          "SalesCharge",
          "LoadType",
          "DeferredLoad",
          "DeferredLoadDuration"
  
  key => "fund:#{fticker}:ratios"
  val => hashtable of fund expense related data elements.
          "TotalExpenseRatio",
          "NetExpenseRatio",
          "Turnover",
          "TurnoverDate"

  key => "fund:#{fticker}:managers"
  val => hashtable of fund management related data elements.
          "TeamManagement",
          "ManagerName1",
          "ManagerName2",
          "ManagerName3",
          "ManagerTenure1",
          "ManagerTenure2",
          "ManagerTenure3"

  key => "fund:#{fticker}:profile"
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

  key => "fund:#{fticker}:sponsor"
  val => hashtable of fund sponsor related data elements.
          "Sponsor",
          "SponsorPhone",
          "SponsorWebsite",
          "SponsorStreet",
          "SponsorStreet2",
          "SponsorCity",
          "SponsorState",
          "SponsorZip"

  key => "fund:#{fticker}:basics"
  val => hashtable of fund basic data elements.
          "Symbol",
          "Name",
          "CUSIP",
          "ProspectusDate",
          "BenchmarkIndex",
          "FiscalYearEndDate"
                        
  key => "fund:#{fticker}:returns"
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

  key => "fund:#{fticker}:hist"
  val => json object of fund historical data.
          {:Date =>, :TotalNetAssets =>, :Turnover =>, :TotalReturns =>}
    
  key => "fund.tickers.auto.complete"
  val => sorted set of fund tickers auto completion list
  e.g => ["A", "AA", "AAA", "AAAA", "AAAAX", ...]
  
  key => "fund.names.auto.complete"
  val => sorted set of fund names auto completion list
  e.g => ["A", "AC", "AC ", "AC O", "AC ON", ...]          
=end

require 'csv'
require 'redis'
require 'json'
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
	    # record type 2 => fundamental data
	    fticker = row[4]
	    if fticker
	      #puts "#{fticker} => #{row[2]}

        # throw into the fund:tickers bucket...
        dbkey = "fund.tickers"
        $redisdb.zadd dbkey, 0, fticker

	      fname = row[2]
	      if fname
          # throw into the fund:names bucket...
          dbkey = "fund.names"
          $redisdb.zadd dbkey, 0, fname

	        # throw into the appropripate fund.name:<fund name>:tickers bucket...
	        dbkey = "fund.name:#{fname}:tickers"
          $redisdb.zadd dbkey, 0, fticker
	      end
	      fsponsor = row[3]
	      if fsponsor
	        # throw into the fund.sponsors bucket...
	        dbkey = "fund.sponsors"
          $redisdb.zadd dbkey, 0, fsponsor

	        # throw into the appropripate fund.sponsor:<fund sponsor name>:tickers bucket...
	        dbkey = "fund.sponsor:#{fsponsor}:tickers"
          $redisdb.zadd dbkey, 0, fticker

	        # throw into the appropripate fund.sponsor:<fund sponsor name>:names bucket...
	        dbkey = "fund.sponsor:#{fsponsor}:names"
	        $redisdb.zadd dbkey, 0, fname
	      end
	      pgroup = row[8]
	      if pgroup
	        # throw into the fund.primary.groups bucket...
	        dbkey = "fund.primary.groups"
          $redisdb.zadd dbkey, 0, pgroup
	        
	        # throw into the appropripate fund.primary.group:<primary group>:tickers bucket...
	        dbkey = "fund.primary.group:#{pgroup}:tickers"
          $redisdb.zadd dbkey, 0, fticker
	      end
	      sgroup = row[9]
	      if sgroup
	        # throw into the fund.secondary.groups bucket...
	        dbkey = "fund.secondary.groups"
          $redisdb.zadd dbkey, 0, sgroup

	        # throw into the appropripate fund.secondary.group:<secondary group>:tickers bucket...
	        dbkey = "fund.secondary.group:#{sgroup}:tickers"
          $redisdb.zadd dbkey, 0, fticker
	      end
	      bindex = row[14]
	      if bindex
	        # throw into the fund.benchmark.indices bucket...
	        dbkey = "fund.benchmark.indices"
          $redisdb.zadd dbkey, 0, bindex
	        
	        # throw into the appropripate fund.benchmark.index:<benchmark index>:tickers bucket...
	        dbkey = "fund.benchmark.index:#{bindex}:tickers"
          $redisdb.zadd dbkey, 0, fticker
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
	      dbkey = "fund:#{fticker}:returns"
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
        hash = {:Date => row[3], :TotalNetAssets => row[4], :Turnover => row[5], :TotalReturns => row[6]}
        #puts "#{fticker} => #{hash}"
        json = JSON.generate hash
        setkey = "fund:#{fticker}:hist"
        $redisdb.zadd setkey, 0, json
	    end
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
