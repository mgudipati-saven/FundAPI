=begin
  Redis DB layout for etf data is defined as follows:

  key => "fund.tickers"
  val => sorted set of fund tickers.
  e.g.=> "fund.tickers" => ['AAAAX', 'AAABX', ...]
  # Key => DTCC:BASKET:#{Index Receipt CUSIP}
  # Value => Hashtable {"IndexReceiptSymbol" => "SPY", "CreationUnit" => "50000", "Components" => json object of components hash}
  #
  # Key => DTCC:COMPONENT:#{CUSIP}
  # Value => Hashtable {"CUSIP" => "123456789", "Baskets" => json object of baskets hash}
  #
  # Key => SECURITIES:XREF:#{CUSIP}
  # Value => Hashtable {"CUSIP" => "123456789", "DTCC" => "IBM"}
=end

require 'redis'
require 'getoptlong'
require 'json'

# call using "ruby load-dtcc-file.rb -i<input file>"  
unless ARGV.length == 1
  puts "Usage: ruby load-dtcc-file.rb -i<input file>" 
  exit  
end  
  
infile = ''
# specify the options we accept and initialize the option parser  
opts = GetoptLong.new(  
  [ "--infile", "-i", GetoptLong::REQUIRED_ARGUMENT ]
)  

# process the parsed options  
opts.each do |opt, arg|  
  case opt  
    when '--infile'  
      infile = arg  
  end  
end

$redisdb = Redis.new
$redisdb.select 1

=begin
  Process the DTCC basket composition file. DTCC file layout is defined as follows:

  Header record describing the basket information
  01WREI           18383M47200220110624000000950005000000000000000291+0000000000000+0000162471058+0000000003249+0000000004503+0000005000000000000000000+
  Basket component records
  02AKR            0042391090002011062400000193WREI           18383M472002
  02ALX            0147521090002011062400000013WREI           18383M472002
  ...
=end
fticker = ''
numrec = 0
IO.foreach(infile) do |line|  
  line.chomp!
  case line[0..1]
    when '01' #Basket Header
      numrec += 1

      #Index Receipt Symbol...Trading Symbol
      fticker = line[2..16].strip
      if fticker
        # update profile data...
  	    dbkey = "etf:#{fticker}:profile"
        $redisdb.hmset dbkey, "TickerSymbol", fticker,

                              #Index Receipt CUSIP...S&P assigned CUSIP
                              "CUSIP", line[17..25].strip,

                              #When Issued Indicator...0 = Regular Way 1 = When Issued
                              "WhenIssuedIndicator", line[26],

                              #Foreign Indicator...0 = Domestic 1 = Foreign
                              "ForeignIndicator", line[27],

                              #Exchange Indicator...0 = NYSE 1 = AMEX 2 = Other
                              "ExchangeIndicator", line[28],

                              #Portfolio Trade Date...CCYYMMDD
                              "TradeDate", line[29..36],

                              #Component Count...99,999,999
                              "ComponentCount", line[37..44].to_i,

                              #Create/Redeem Units per Trade...99,999,999
                              "CreationUnitsPerTrade", line[45..52].to_i,

                              #Estimated T-1 Cash Amount Per Creation Unit...999,999,999,999.99-
                              "EstimatedT1CashAmountPerCreationUnit", "#{line[67]}#{line[53..64]}.#{line[65..66]}".to_f,

                              #Estimated T-1 Cash Per Index Receipt...99,999,999,999.99
                              "EstimatedT1CashPerIndexReceipt", "#{line[81]}#{line[68..78]}.#{line[79..80]}".to_f,

                              #Net Asset Value Per Creation Unit...99,999,999,999.99
                              "NavPerCreationUnit", "#{line[95]}#{line[82..92]}.#{line[93..94]}".to_f,

                              #Net Asset Value Per Index Receipt...99,999,999,999.99
                              "NavPerIndexReceipt", "#{line[109]}#{line[96..106]}.#{line[107..108]}".to_f,

                              #Total Cash Amount Per Creation Unit...99,999,999,999.99-
                              "TotalCashAmount", "#{line[123]}#{line[110..120]}.#{line[121..122]}".to_f,

                              #Total Shares Outstanding Per ETF...999,999,999,999
                              "TotalSharesOutstanding", line[124..135].to_i,

                              #Dividend Amount Per Index Receipt...99,999,999,999.99
                              "DividendAmount", "#{line[149]}#{line[136..146]}.#{line[147..148]}".to_f,

                              #Cash/Security Indicator...  1 = Cash only 2 = Cash or components other – components only
                              "CashIndicator", line[150]
      end
    when '02' #Basket Component Detail
      numrec += 1
     
      hash = {
        #Component CUSIP...S&P assigned CUSIP
        "CUSIP" => line[17..25].strip,

        #Component Symbol...Trading Symbol
        "TickerSymbol" => line[2..16].strip,

        #When Issued Indicator...0 = Regular Way 1 = When Issued
        "WhenIssuedIndicator" => line[26],

        #Foreign Indicator...0 = Domestic 1 = Foreign
        "ForeignIndicator" => line[27],

        #Exchange Indicator...0 = NYSE 1 = AMEX 2 = Other
        "ExchangeIndicator" => line[28],

        #Portfolio Trade Date...CCYYMMDD
        "TradeDate" => line[29..36],

        #Component Share Qty...99,999,999
        "ShareQuantity" => line[37..44].to_i,

        #New Security Indicator...N = New CUSIP Space = Old CUSIP
        "NewSecurityIndicator" => line[72]
        }

      if fticker
        json = JSON.generate hash
        setkey = "etf:#{fticker}:components"
        score = line[37..44]
        $redisdb.zadd setkey, score, json
      end
    when '09' #File Trailer
      numrec += 1
      # Record Count...99,999,999 Includes Records 01, 02, 09
      reccnt = line[37..44].to_i
      if numrec != reccnt
        puts "Error in DTCC File: records found:#{numrec} != records reported:#{reccnt}"
      end
  end
end
  