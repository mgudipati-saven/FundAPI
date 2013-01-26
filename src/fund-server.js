var http = require('http'),
    url = require('url'),
    redis = require('redis'),
    util = require('./util'),
    
    // redis connection
    redisdb = redis.createClient();

redisdb.on("error", function (err) {
  console.log("Redis Error " + err);
});
    
/*
 * sendFundHoldings(name, n):
 *  sends top <n> fund holdings data.
 *  
 * @param       res   response channel
 * @param       name  fund name
 * @param       n     number of holdings
 * @access      public
 */ 
function sendFundHoldings(res, name, n) {
  var dbkey = "fund:"+name+":holdings";
  redisdb.zrevrange(dbkey, 0, n, function(err, data) {
    //console.dir(data);
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.write(JSON.stringify(data));
    res.end();
  });
}

/*
 * http connection handlers
 */
http.createServer(function (req, res) {
  console.log("Request: " + req.url);
  var uri = url.parse(req.url, true);
  
  if (uri.pathname === "/funds.json") {
    var cmd = uri.query.cmd;

    switch (cmd) {
      case 'searchByExpenseRatio':
      	// funds?cmd=searchByExpenseRatio&gt=0.5&lt=1.0
      	var startr = (uri.query.gt == null) ? 0.0 : uri.query.gt;
      	var endr = (uri.query.lt == null) ? 2.0 : uri.query.lt;
      	
      	var dbkey = "fund:tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
            var arr = [];
            var multi = redisdb.multi();
            tickers.forEach(function(ticker, pos) {
              dbkey = "fund:"+ticker+":ratios";
              multi.hget(dbkey, "TotalExpenseRatio", function(err, ratio) {
                if (ratio > startr && ratio <= endr) {
                  console.log(startr+"<"+ratio+"<"+endr);
                  arr.push(ticker);
                }
              });
            });
            multi.exec(function (err, replies) {
              //console.dir(arr);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(arr));
  		        res.end();
        		});
					});
				});
      break;
      
      case 'searchByName':
      	// funds?cmd=searchByName&name=Fidelity Emerging Asia Fund
      	if (uri.query.name != null) {
    	    dbkey = "fund.name:"+uri.query.name+":tickers";
  				redisdb.select(0, function(reply) {				
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
  		        //console.dir(data);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(data));
  		        res.end();
  					});
  				});
        }
      break;
        
      case 'searchByPrimaryGroup':
    	  // funds?cmd=searchByPrimaryGroup&pgrp=US Equity
    	  if (uri.query.pgrp != null) {
  	      dbkey = "fund.primary.group:"+uri.query.pgrp+":tickers";
  				redisdb.select(0, function(reply) {				
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
  		        //console.dir(data);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(data));
  		        res.end();
  					});
  				});
        }
      break;

      case 'searchBySecondaryGroup':
    	  // funds?cmd=searchBySecondaryGroup&sgrp=Utilities
    	  if (uri.query.sgrp != null) {
  	      dbkey = "fund.secondary.group:"+uri.query.sgrp+":tickers";
  				redisdb.select(0, function(reply) {				
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
  		        //console.dir(data);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(data));
  		        res.end();
  					});
  				});
        }
      break;

      case 'searchByBenchmarkIndex':
      	// funds?cmd=searchByBenchmarkIndex&bindex=S&P 500
      	if (uri.query.bindex != null) {
    	    dbkey = "fund.benchmark.index:"+uri.query.bindex+":tickers";
  				redisdb.select(0, function(reply) {				
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
  		        //console.dir(data);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(data));
  		        res.end();
  					});
  				});
        }
      break;
      
      case 'searchByLoadType':
      	// funds?cmd=searchByLoadType&type=Y
        var type = (uri.query.type == null) ? "N" : uri.query.type;
        
      	var dbkey = "fund:tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
            var arr = [];
            var multi = redisdb.multi();
            tickers.forEach(function(ticker, pos) {
              dbkey = "fund:"+ticker+":fees";
              multi.hget(dbkey, "LoadType", function(err, data) {
                if (data == type) {
                  arr.push(ticker);
                }
              });
            });
            multi.exec(function (err, replies) {
              console.dir(arr);
              console.log(arr.length);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(arr));
  		        res.end();
        		});
					});
				});
      break;

      case 'searchByInitialInvestment':
      	// funds?cmd=searchByInitialInvestment&lt=2500
        var amt = (uri.query.lt == null) ? 2500 : uri.query.lt;
        
      	var dbkey = "fund:tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
            var arr = [];
            var multi = redisdb.multi();
            tickers.forEach(function(ticker, pos) {
              dbkey = "fund:"+ticker+":profile";
              multi.hget(dbkey, "InitialInvestment", function(err, data) {
                if (parseInt(data) <= amt) {
                  arr.push(ticker);
                }
              });
            });
            multi.exec(function (err, replies) {
              //console.dir(arr);
              //console.log(arr.length);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(arr));
  		        res.end();
        		});
					});
				});
      break;

      case 'advsearch':
      	// funds?cmd=advsearch&name=Fidelity Emerging Asia Fund&pgrp=US Equity&sgrp=Utilities
      	var key1, key2, key3 = null;
      		
				if (uri.query.name != null) { 
					key1 = "fund.name:"+uri.query.name+":tickers";
				}
			
				if (uri.query.pgrp != null) {
					key2 = "fund.primary.group:"+uri.query.pgrp+":tickers";					
				}
			
				if (uri.query.sgrp != null) {
					key3 = "fund.secondary.group:"+uri.query.sgrp+":tickers";
				}

				if (key1 != null && key2 != null && key3 != null) {
					redisdb.select(0, function(reply) {				
						redisdb.sinter(key1, key2, key3, function(err, data) {
  		        //console.dir(data);
  		        res.writeHead(200, {'Content-Type': 'text/plain'});
  		        res.write(JSON.stringify(data));
  		        res.end();
						});
					});
				} else if (key1 != null && key2 != null) {
					redisdb.select(0, function(reply) {				
						redisdb.sinter(key1, key2, function(err, data) {
			        //console.dir(data);
			        res.writeHead(200, {'Content-Type': 'text/plain'});
			        res.write(JSON.stringify(data));
			        res.end();
						});
					});
				} else if (key2 != null && key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.sinter(key2, key3, function(err, data) {
			        //console.dir(data);
			        res.writeHead(200, {'Content-Type': 'text/plain'});
			        res.write(JSON.stringify(data));
			        res.end();
						});
					});
				} else if (key1 != null && key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.sinter(key1, key3, function(err, data) {
			        //console.dir(data);
			        res.writeHead(200, {'Content-Type': 'text/plain'});
			        res.write(JSON.stringify(data));
			        res.end();
						});
					});
				} else if (key1 != null) {
					redisdb.select(0, function(reply) {
						redisdb.zrange(key1, 0, -1, function(err, data) {
			        //console.dir(data);
			        res.writeHead(200, {'Content-Type': 'text/plain'});
			        res.write(JSON.stringify(data));
			        res.end();
						});
					});
				} else if (key2 != null) {
					redisdb.select(0, function(reply) {
						redisdb.zrange(key2, 0, -1, function(err, data) {
			        //console.dir(data);
			        res.writeHead(200, {'Content-Type': 'text/plain'});
			        res.write(JSON.stringify(data));
			        res.end();
						});
					});
				} else if (key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.zrange(key3, 0, -1, function(err, data) {
			        //console.dir(data);
			        res.writeHead(200, {'Content-Type': 'text/plain'});
			        res.write(JSON.stringify(data));
			        res.end();
						});
					});
				}
      break;
      
    	case 'basics':
    		// funds?cmd=basics&ticker=FMAGX
    		var ticker = uri.query.ticker,
            dbkey = "fund:"+ticker+":basics";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
		    });
  	  break;

    	case 'perf':
    		// funds?cmd=perf&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":perf";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'sponsor':
    		// funds?cmd=sponsor&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":sponsor";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'profile':
    		// funds?cmd=profile&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":profile";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'managers':
    		// funds?cmd=managers&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":managers";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'ratios':
    		// funds?cmd=ratios&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":ratios";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'fees':
    		// funds?cmd=fees&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":fees";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'hist':
    		// funds?cmd=hist&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":hist";

		    redisdb.select(0, function(reply) {
	        redisdb.zrange(dbkey, 0, -1, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'holdings':
    		// funds?cmd=holdings&name=Fidelity Magellan Fund
    		// OR
    		// funds?cmd=holdings&ticker=FMAGX
    		var name = uri.query.name,
    		    ticker = uri.query.ticker,
    		    dbkey = null;
    		    
    		if (ticker != null) {
  		    redisdb.select(1, function(reply) {
  		      dbkey = "fund:"+ticker+":basics";
  		      redisdb.hget(dbkey, "Name", function(err, data) {
              sendFundHoldings(res, data, 9);
		        });
  			  });
    		} else if (name != null) {
  		    redisdb.select(1, function(reply) {
            sendFundHoldings(res, name, 9);
  			  });
    		}

	  	break;

    	case 'assetalloc':
    		// funds?cmd=assetalloc&name=FMAGX
    		var name = uri.query.name,
			      dbkey = "fund:"+name+":asset.allocation";

		    redisdb.select(1, function(reply) {
	        redisdb.zrange(dbkey, 0, -1, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'sectalloc':
    		// funds?cmd=sectalloc&name=FMAGX
    		var name = uri.query.name,
			      dbkey = "fund:"+name+":sector.allocation";

		    redisdb.select(1, function(reply) {
	        redisdb.zrange(dbkey, 0, -1, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'geoalloc':
    		// funds?cmd=geoalloc&name=FMAGX
    		var name = uri.query.name,
			      dbkey = "fund:"+name+":geo.allocation";

		    redisdb.select(1, function(reply) {
	        redisdb.zrange(dbkey, 0, -1, function(err, data) {
            //console.dir(data);
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(data));
            res.end();
	        });
			  });
	  	break;

    	case 'prices':
    		// funds?cmd=prices&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "338::"+ticker;

		    redisdb.select(1, function(reply) {
	        redisdb.get(dbkey, function(err, data) {
            json = JSON.parse(data);
            console.log("Prices ======>" + JSON.stringify(json));
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write(JSON.stringify(json));
            res.end();
	        });
			  });
	  	break;
	  	
	  	default:
        console.log("Command " + cmd + " Not Found");
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.write("Command Not Found");
        res.end();
	  	break;
    } // switch (cmd)
  } // if (uri.pathname === "/funds")
  else {
    util.loadStaticFile(uri.pathname, res);
  }
}).listen(8080, "127.0.0.1");