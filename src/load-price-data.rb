require 'socket'
require 'redis'
require 'json'

# Redis database connection
$redisdb = Redis.new
$redisdb.select 0

# Open TCP socket connection to plusfeed server
#ctfSocket = TCPSocket::new( "127.0.0.1", 8888 )
#ctfSocket = TCPSocket::new( "198.190.11.24", 4002 )
#ctfSocket = TCPSocket::new( "198.190.11.26", 4001 )
ctfSocket = TCPSocket::new( "198.190.11.31", 4001 )

# List of CTF commands
ctfCommandList = 
	[ 
	#"5022=LoginUser|5028=pfcanned|5029=cypress|5026=1",
	"5022=LoginUser|5028=tamsupport|5029=bgood2me|5026=1",
	#"5022=LoginUser|5028=plusserver|5029=plusserver|5026=1",
	"5022=SelectAvailableTokens|5026=2",
	"5022=QuerySnap|4=338|5026=3"
	]

# Update redis database
def update_db data
  if $redisdb
    #p data
    json = JSON.generate data
    dbkey = data["ENUM.SRC.ID"]+"::"+data["SYMBOL.TICKER"]
    $redisdb.set dbkey, json
  end
end

# Parse CTF message into a hash object
def parse_ctf ctfmsg
  data = Hash.new
	ctfmsg.split('|').each do |token|
			tvpair = token.split('=')
      tokname = $redisdb.hget "CTF::TOKENS", tvpair[0]
      if tokname != nil
        data[tokname] = tvpair[1] # SYMBOL.TICKER => IBM
      end
	end
	data
end

# Send CTF commands to ctf server 
ctfCommandList.each do |cmd|
	# Format a CTF Message
	ctfRequest = [ 0x04, 0x20, cmd.length, cmd, 0x03].pack("ccNA*c")
	puts ctfRequest

	# Send the CTF request
	ctfSocket.send( ctfRequest, 0 )
end

# Read CTF responses from ctf server...
ctfMessage = nil
ctfState = :ExpectingFrameStart
payloadSizeBytes = 0
done = false
while !done
	# Read the CTF messages
	ctfResponse = ctfSocket.recv( 4*1024 )
	#puts ctfResponse
	i = 0
	until i == ctfResponse.bytesize
		case ctfState
			when :ExpectingFrameStart
				if ctfResponse.getbyte(i) == 4
					#puts "CTF Message Begin"
					ctfMessage = String.new
					ctfState = :ExpectingProtocolSignature
				else
					puts "Error: CTF protocol violated. Expecting frame start, received " + ctfResponse[i]
					break
				end
		
			when :ExpectingProtocolSignature
				if ctfResponse.getbyte(i) == 32
					payloadSizeBytes = 0
					ctfState = :ExpectingPayloadSize
				else
					puts "Error: CTF protocol violated. Expecting protocol signature, received " + ctfResponse[i]
					break
				end
		
			when :ExpectingPayloadSize
				payloadSizeBytes += 1
				if payloadSizeBytes == 4
					ctfState = :ExpectingFrameEnd
				end
			
			when :ExpectingFrameEnd
				if ctfResponse.getbyte(i) == 3
					#puts "CTF Message End"
					payload = ctfMessage.unpack("ccNA*")[3]
					#puts payload
		            data = parse_ctf payload
		            p data
		            src = data["ENUM.SRC.ID"]
		            sym = data["SYMBOL.TICKER"]
		            if src != nil && sym != nil
		            	#update db
		            	update_db data
					end
					if "5026=3|5001=0" == payload
					  done = true
				  	end
					ctfState = :ExpectingFrameStart
				end
		end
		ctfMessage += ctfResponse[i]
		i += 1
	end
end

# Close the socket
ctfSocket.close