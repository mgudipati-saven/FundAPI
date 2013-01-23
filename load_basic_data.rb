require 'csv'
require 'redis'

$redisdb = Redis.new

# reset the next.fund.id counter. this keeps track of the fund id's
$redisdb.set "next.fund.id", 1

# parse the basic data csv file
CSV.foreach(ARGV[0], :quote_char => '|', :col_sep =>'|', :row_sep =>:auto) do |row|
  #p row
  if row[1] == "2"
    # record type 2 => fundamental data
    fticker = row[4]
    if fticker
      #p fticker
      # update basic data...
      dbkey = "fund:#{$redisdb.get "next.fund.id"}"
      $redisdb.hmset dbkey, "Symbol", fticker,
                            "Name", row[2],
                            "Sponsor", row[3],
                            "CUSIP", row[5],
                            "ShareClass", row[6],
                            "InceptionDate", row[7],
                            "PrimaryGroup", row[8],
                            "SecondaryGroup", row[9],
                            "ProspectusDate", row[10],
                            "Objective", row[11],
                            "Strategy", row[12],
                            "Status", row[13],
                            "BenchmarkIndex", row[14],
                            "ManagementFees", row[15],
                            "TotalExpenseRatio", row[16],
                            "NetExpenseRatio", row[17],
                            "b12-1Fee", row[18],
                            "RedemptionFee", row[19],
                            "RedemptionFeeDuration", row[20],
                            "SalesCharge", row[21],
                            "LoadType", row[22],
                            "DeferredLoad", row[23],
                            "DeferredLoadDuration", row[24],
                            "TotalNetAssets", row[25],
                            "TotalNetAssetsDate", row[26],
                            "Turnover", row[27],
                            "TurnoverDate", row[28],
                            "InitialInvestment", row[34],
                            "IncrementalInvestment", row[35],
                            "IRAInitialInvestment", row[36],
                            "IRAIncrementalInvestment", row[37],
                            "InitialAutomaticInvestmentPlan", row[38],
                            "ExpenseWaiverType", row[39],
                            "ExpenseWaiverExpiryDate", row[40],
                            "ExpenseWaiverOptionCode", row[41],
                    	      "Yr1TotalReturns", row[42],
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
                            "TeamManagement", row[66],
                            "ManagerName1", row[67],
                            "ManagerName2", row[68],
                            "ManagerName3", row[69],
                            "ManagerTenure1", row[70],
                            "ManagerTenure2", row[71],
                            "ManagerTenure3", row[72],
                            "Month12Yield", row[73],
                            "YieldDate", row[74],
                            "SponsorPhone", row[75],
                            "SponsorWebsite", row[76],
                            "SponsorStreet", row[77],
                            "SponsorStreet2", row[78],
                            "SponsorCity", row[79],
                            "SponsorState", row[80],
                            "SponsorZip", row[81],
                            "DividendFrequency", row[82],
                            "FiscalYearEndDate", row[83]
      $redisdb.incr "next.fund.id"
    end
  end # record type 2 => fundamental data 
end # CSV.foreach
