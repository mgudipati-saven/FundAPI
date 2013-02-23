=begin
  Redis DB layout for fund data is defined as follows:

  key => "next.mf.id"
  val => a counter for mutual funds.

  key => "mf:#{id}:ticker"
  val => mutual fund ticker symbol for the given fund id.

  key => "mf:#{ticker}:id"
  val => mutual fund id for the given ticker symbol.
  
  key => "fund.tickers"
  val => sorted set of fund tickers.

  key => "mf:#{id}:basics"
  val => hashtable of basic fund data elements.
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

# redis db connection
$redisdb = Redis.new
$redisdb.select 0

if $infile && File.exist?($infile)
  puts "Processing the fund basic data file: #{$infile}..."
	CSV.foreach($infile, :quote_char => '|', :col_sep =>'|', :row_sep =>:auto) do |row|
	  #p row
	  if row[1] == "2"
	    # record type 2 => basic data
	    fticker = row[4]
	    if fticker
        # check if the fund exists in the db...
        id = $redisdb.get "mf:#{fticker}:id"
        if !id
          # create using next.mf.id counter...
          id = $redisdb.incr "next.mf.id"

          # set the two way id <=> ticker references...
          $redisdb.set "mf:#{fticker}:id", id
          $redisdb.set "mf:#{id}:ticker", fticker

          # throw the ticker into the fund:tickers set...
          $redisdb.zadd "fund.tickers", 0, fticker
        end

	      # update basic data...
		    dbkey = "mf:#{id}:basics"
	      $redisdb.hmset dbkey, 
          :TickerSymbol, fticker,
  	      :SeriesName, row[2],
  	      :Sponsor, row[3],
          :CUSIP, row[5],
          :ShareClass, row[6],
          :InceptionDate, row[7],
  	      :PrimaryGroup, row[8],
  	      :SecondaryGroup, row[9],
          :ProspectusDate, row[10],
          :Objective, row[11],
          :Strategy, row[12],
          :Status, row[13],
  	      :BenchmarkIndex, row[14],
          :ManagementFees, row[15],
          :TotalExpenseRatio, row[16],
          :NetExpenseRatio, row[17],
          :DistributionFee, row[18],
          :RedemptionFee, row[19],
          :RedemptionFeeDuration, row[20],
          :SalesCharge, row[21],
          :LoadType, row[22],
          :DeferredLoad, row[23],
          :DeferredLoadDuration, row[24],
          :TotalNetAssets, row[25],
          :TotalNetAssetsDate, row[26],
          :Turnover, row[27],
          :TurnoverDate, row[28],
          :InitialInvestment, row[34],
          :IncrementalInvestment, row[35],
          :IRAInitialInvestment, row[36],
          :IRAIncrementalInvestment, row[37],
          :InitialAutomaticInvestmentPlan, row[38],
          :ExpenseWaiverType, row[39],
          :ExpenseWaiverExpiryDate, row[40],
          :ExpenseWaiverOptionCode, row[41],
          :Yr1TotalReturns, row[42],
          :Yr3TotalReturns, row[43],
          :Yr5TotalReturns, row[44],
          :Yr10TotalReturns, row[45],
          :LifeTotalReturns, row[46],
          :TotalReturnsDate, row[47],
          :BestQuarterReturns, row[48],
          :BestQuarterReturnsDate, row[49],
          :WorstQuarterReturns, row[50],
          :WorstQuarterReturnsDate, row[51],
          :Yr1AfterTaxReturns, row[52],
          :Yr3AfterTaxReturns, row[53],
          :Yr5AfterTaxReturns, row[54],
          :Yr10AfterTaxReturns, row[55],
          :LifeAfterTaxReturns, row[56],
          :Yr1AfterTaxAndSalesReturns, row[57],
          :Yr3AfterTaxAndSalesReturns, row[58],
          :Yr5AfterTaxAndSalesReturns, row[59],
          :Yr10AfterTaxAndSalesReturns, row[60],
          :LifeAfterTaxAndSalesReturns, row[61],
          :QuartileRanking, row[62],
          :PercentileRanking, row[63],
          :PeerGroupReturns, row[64],
          :PeerGroupCount, row[65],
          :TeamManagement, row[66],
          :ManagerName1, row[67],
          :ManagerName2, row[68],
          :ManagerName3, row[69],
          :ManagerTenure1, row[70],
          :ManagerTenure2, row[71],
          :ManagerTenure3, row[72],
          :Month12Yield, row[73],
          :YieldDate, row[74],
          :SponsorPhone, row[75],
          :SponsorWebsite, row[76],
          :SponsorStreet, row[77],
          :SponsorStreet2, row[78],
          :SponsorCity, row[79],
          :SponsorState, row[80],
          :SponsorZip, row[81],
          :DividendFrequency, row[82],
          :FiscalYearEndDate, row[83]
	    end # if fticker
	  elsif row[1] == "3"
=begin
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
