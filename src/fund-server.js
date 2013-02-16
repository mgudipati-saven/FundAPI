var http = require('http'),
    url = require('url'),
    redis = require('redis'),
    util = require('./util');

// error codes and messages
var errmsg = {};
errmsg['10'] = {"message":"Command not found","code":10};
errmsg['20'] = {"message":"Invalid parameter","code":20};
errmsg['30'] = {"message":"Missing parameter","code":30};

// redis connection
var redisdb = redis.createClient();
redisdb.on("error", function (err) {
  console.log("Redis Error " + err);
});
    
/*
 * sendJSONData(res, data)
 *    Sends JSON data to the client.
 */
function sendJSONData(res, data) {
  //console.dir(data);
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.write(JSON.stringify(data));
  res.end();
}

/*
 * sendFundHoldings(res, name, n):
 *  sends top <n> fund holdings data.
 *  
 * @param       res   response channel
 * @param       name  fund name
 * @param       n     number of holdings
 * @access      public
 */ 
function sendFundHoldings(res, name, n) {
  // select redis db instance no. 1
  redisdb.select(0, function(reply) {
    // obtain the latest holdings date
    var dbkey = "fund:"+name+":holdings:dates";
    if (redisdb.exists(dbkey)) {
      redisdb.zrevrange(dbkey, 0, n, function(err, dates) {
        if (dates.length != 0 && dates[0] != null) {
          dbkey = "fund:"+name+":holdings:"+dates[0];
          redisdb.zrevrange(dbkey, 0, n, function(err, data) {
            sendJSONData(res, data);
          });
        } else {
          sendJSONData(res, []);
        }
      });
    }
  });
}

/*
 * sendFundAllocation(res, name, type):
 *  sends fund allocation data - asset, sector, geography.
 *  
 * @param       res   response channel
 * @param       name  fund name
 * @param       type  type of allocation - asset or sector or geo
 * @access      public
 */ 
function sendFundAllocation(res, name, type) {
  var dbkey = null;
  
  switch (type) {
    case 'asset':
      dbkey = "fund:"+name+":asset.allocation:";
    break;

    case 'sector':
      dbkey = "fund:"+name+":sector.allocation:";
    break;

    default:
      dbkey = "fund:"+name+":geo.allocation:";
    break;
  }
  
  redisdb.select(0, function(reply) {
    // obtain the latest allocation date
    redisdb.zrevrange(dbkey+"dates", 0, -1, function(err, dates) {
      if (dates.length != 0 && dates[0] != null) {
        redisdb.zrevrange(dbkey+dates[0], 0, -1, function(err, data) {
          sendJSONData(res, data);
        });
      } else {
        sendJSONData(res, []);
      }
    });
  });
}


/*
 * sendGoogleSuggestionList(res, dbkey, prefix):
 *    Suggests auto completion list or also known as google suggestions
 * for the given 'prefix' words. Useful for fund tickers or names.
 *
 * @param       res     response channel
 * @param       dbkey   key to the redis db that has the completion list
 * @param       prefix  prefix word
 * @access      public
 */ 
function sendGoogleSuggestionList(res, dbkey, prefix) {
  var results = [];

  redisdb.select(0, function(reply) {				
    redisdb.zrank(dbkey, prefix, function(err, start) {
      if (start != null) {
        redisdb.zrange(dbkey, start, -1, function(err, range) {
          for (var i=0; i<=range.length-1; i++) {
            var entry = range[i];
            var minlen = (entry.length < prefix.length) ? entry.length : prefix.length; 
            if (entry.substr(0, minlen) != prefix.substr(0, minlen)) {
              break;
            }
            if (entry.charAt(entry.length-1) == '*') {
              results.push(entry.substr(0, entry.length-1));
            }
          }
          sendJSONData(res, results);
        });
      } else {
        sendJSONData(res, []);
      }
    });
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
      case 'tickers':
    	  //funds.json?cmd=tickers
  	    dbkey = "fund.tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
					});
				});
      break;

      case 'names':
    	  //funds.json?cmd=names
  	    dbkey = "fund.names";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
					});
				});
      break;

      case 'sponsors':
    	  //funds.json?cmd=sponsors
  	    dbkey = "fund.sponsors";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
					});
				});
      break;
      
      case 'pgroups':
    	  //funds.json?cmd=pgroups
  	    dbkey = "fund.primary.groups";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
					});
				});
      break;

      case 'sgroups':
    	  //funds.json?cmd=sgroups
  	    dbkey = "fund.secondary.groups";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
					});
				});
      break;

      case 'benchmarks':
    	  //funds.json?cmd=benchmarks
  	    dbkey = "fund.benchmark.indices";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
					});
				});
      break;

      case 'complete':
      	//funds.json?cmd=complete&ticker=FM
      	//OR
      	//funds.json?cmd=complete&name=Fidelity
      	var ticker = uri.query.ticker;
      	var name = uri.query.name;
    	
      	if (ticker != null) {
          sendGoogleSuggestionList(res, "fund.tickers.auto.complete", ticker);
        } else if (name != null) {
          sendGoogleSuggestionList(res, "fund.names.auto.complete", name);
        }
      break;

      case 'searchByName':
      	// funds?cmd=searchByName&name=Fidelity Emerging Asia Fund
      	if (uri.query.name != null) {
    	    dbkey = "fund.name:"+uri.query.name+":tickers";
  				redisdb.select(0, function(reply) {				
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
              sendJSONData(res, data);
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
              sendJSONData(res, data);
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
              sendJSONData(res, data);
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
              sendJSONData(res, data);
  					});
  				});
        }
      break;
      
      case 'searchByLoadType':
      	// funds?cmd=searchByLoadType&type=Y
        var type = (uri.query.type == null) ? "N" : uri.query.type;
        
      	var dbkey = "fund.tickers";
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
              sendJSONData(res, arr);
        		});
					});
				});
      break;

      case 'searchByInitialInvestment':
      	// funds?cmd=searchByInitialInvestment&lt=2500
      	var startr = (uri.query.gt == null) ? 0 : uri.query.gt;
      	var endr = (uri.query.lt == null) ? Infinity : uri.query.lt;
        
      	var dbkey = "fund.tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
            var arr = [];
            var multi = redisdb.multi();
            tickers.forEach(function(ticker, pos) {
              dbkey = "fund:"+ticker+":profile";
              multi.hget(dbkey, "InitialInvestment", function(err, data) {
                var amt = parseInt(data);
                if (amt > startr && amt <= endr) {
                  arr.push(ticker);
                }
              });
            });
            multi.exec(function (err, replies) {
              sendJSONData(res, arr);
        		});
					});
				});
      break;

      case 'searchByReturns':
      	// funds?cmd=searchByReturns&param=Yr1&lt=25
      	var startr = (uri.query.gt == null) ? -Infinity : uri.query.gt;
      	var endr = (uri.query.lt == null) ? Infinity : uri.query.lt;
        var metric = "Yr1TotalReturns";
        
        switch (uri.query.param) {
          default:
          case 'Yr1':
            metric = "Yr1TotalReturns";
          break;
          
          case 'Yr3':
            metric = "Yr3TotalReturns";
          break;
          
          case 'Yr5':
            metric = "Yr5TotalReturns";
          break;
          
          case 'Yr10':
            metric = "Yr10TotalReturns";
          break;
          
          case 'Life':
            metric = "LifeTotalReturns";
          break;
        }
        
      	var dbkey = "fund.tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
            var arr = [];
            var multi = redisdb.multi();
            tickers.forEach(function(ticker, pos) {
              dbkey = "fund:"+ticker+":returns";
              multi.hget(dbkey, metric, function(err, data) {
                var amt = parseFloat(data);
                if (amt > startr && amt <= endr) {
                  arr.push(ticker);
                }
              });
            });
            multi.exec(function (err, replies) {
              sendJSONData(res, arr);
        		});
					});
				});
      break;

      case 'searchByRatios':
      	// funds?cmd=searchByRatios&param=Turnover&lt=25
      	var startr = (uri.query.gt == null) ? 0.0 : uri.query.gt;
      	var endr = (uri.query.lt == null) ? 100.0 : uri.query.lt;
        var metric = "Turnover";
        
        switch (uri.query.param) {
          case 'Turnover':
            metric = "Turnover";
            break;
            
          case 'ExpenseRatio':
          default:
            metric = "TotalExpenseRatio";
            break;
        }
        
      	var dbkey = "fund.tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
            var arr = [];
            var multi = redisdb.multi();
            tickers.forEach(function(ticker, pos) {
              dbkey = "fund:"+ticker+":ratios";
              multi.hget(dbkey, metric, function(err, ratio) {
                if (ratio > startr && ratio <= endr) {
                  arr.push(ticker);
                }
              });
            });
            multi.exec(function (err, replies) {
              sendJSONData(res, arr);
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
              sendJSONData(res, data);
						});
					});
				} else if (key1 != null && key2 != null) {
					redisdb.select(0, function(reply) {				
						redisdb.sinter(key1, key2, function(err, data) {
              sendJSONData(res, data);
						});
					});
				} else if (key2 != null && key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.sinter(key2, key3, function(err, data) {
              sendJSONData(res, data);
						});
					});
				} else if (key1 != null && key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.sinter(key1, key3, function(err, data) {
              sendJSONData(res, data);
						});
					});
				} else if (key1 != null) {
					redisdb.select(0, function(reply) {
						redisdb.zrange(key1, 0, -1, function(err, data) {
              sendJSONData(res, data);
						});
					});
				} else if (key2 != null) {
					redisdb.select(0, function(reply) {
						redisdb.zrange(key2, 0, -1, function(err, data) {
              sendJSONData(res, data);
						});
					});
				} else if (key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.zrange(key3, 0, -1, function(err, data) {
              sendJSONData(res, data);
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
            sendJSONData(res, data);
	        });
		    });
  	  break;

    	case 'returns':
    		// funds?cmd=returns&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":returns";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;

    	case 'sponsor':
    		// funds?cmd=sponsor&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":sponsor";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;

    	case 'profile':
    		// funds?cmd=profile&ticker=FMAGX
			  var dbkey = "fund:"+uri.query.ticker+":profile";

		    redisdb.select(0, function(reply) {
		      // try mutual fund ticker
	        redisdb.hgetall(dbkey, function(err, data) {
	          if (data == null || data.length == 0) {
	            // try etf ticker
	            dbkey = "etf:"+uri.query.ticker+":profile";
    	        redisdb.hgetall(dbkey, function(err, data) {
                sendJSONData(res, data);
              });
	          } else {
              sendJSONData(res, data);
	          }
	        });
			  });
	  	break;

    	case 'managers':
    		// funds?cmd=managers&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":managers";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;

    	case 'ratios':
    		// funds?cmd=ratios&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":ratios";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;

    	case 'fees':
    		// funds?cmd=fees&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":fees";

		    redisdb.select(0, function(reply) {
	        redisdb.hgetall(dbkey, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;

    	case 'hist':
    		// funds?cmd=hist&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "fund:"+ticker+":hist";

		    redisdb.select(0, function(reply) {
	        redisdb.zrange(dbkey, 0, -1, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;

    	case 'holdings':
    		// funds?cmd=holdings&name=Fidelity Magellan Fund
    		// OR
    		// funds?cmd=holdings&ticker=FMAGX
    		var name = uri.query.name,
    		    ticker = uri.query.ticker;
    		    
    		if (ticker != null) {
  		    redisdb.select(0, function(reply) {
  		      var dbkey = "fund:"+ticker+":basics";
  		      redisdb.hget(dbkey, "Name", function(err, data) {
              sendFundHoldings(res, data, 9);
		        });
  			  });
    		} else if (name != null) {
          sendFundHoldings(res, name, 9);
    		}
	  	break;

    	case 'alloc':
    		// funds?cmd=alloc&type=asset&name=Fidelity Magellan Fund
    		// OR
    		// funds?cmd=alloc&type=asset&ticker=FMAGX
    		var name = uri.query.name,
		        ticker = uri.query.ticker,
		        type = uri.query.type;
		        
    		if (ticker != null) {
  		    redisdb.select(0, function(reply) {
  		      var dbkey = "fund:"+ticker+":basics";
  		      redisdb.hget(dbkey, "Name", function(err, data) {
              sendFundAllocation(res, data, type);
		        });
  			  });
    		} else if (name != null) {
          sendFundAllocation(res, name, type);
    		}
	  	break;

    	case 'prices':
    		// funds?cmd=prices&ticker=FMAGX
    		var ticker = uri.query.ticker,
			      dbkey = "338::"+ticker;

		    redisdb.select(0, function(reply) {
	        redisdb.get(dbkey, function(err, data) {
            sendJSONData(res, data);
	        });
			  });
	  	break;
	  	
	  	default:
        data = {"errors":[{"message":"Sorry, that page does not exist","code":34}]};
        sendJSONData(res, data);
	  	break;
    } // switch (cmd)
  } else if (uri.pathname === "/etfs.json") {
      var cmd = uri.query.cmd;

      switch (cmd) {
      	case 'profile':
      		// etfs.json?cmd=profile&ticker=SPY
  			  var dbkey = "etf:"+uri.query.ticker+":profile";

  		    redisdb.select(0, function(reply) {
  	        redisdb.hgetall(dbkey, function(err, data) {
              sendJSONData(res, data);
  	        });
  			  });
  	  	break;

      	case 'components':
      		// etfs.json?cmd=components&ticker=SPY
      		var ticker = uri.query.ticker;
		      var dbkey = "etf:"+ticker+":components";

          redisdb.zrevrange(dbkey, 0, 9, function(err, data) {
            var json = {'components': data};
            sendJSONData(res, json);
          });
  	  	break;

      	case 'searchByComponent':
      		// etfs.json?cmd=searchByComponent&ticker=IBM
      		var ticker = uri.query.ticker;

          if (ticker == null) {
            data = {"errors":[errmsg['30']]};
            sendJSONData(res, data);
          } else {
  		      var dbkey = ticker+":etf.tickers";

            redisdb.zrange(dbkey, 0, -1, function(err, data) {
              var json = {'tickers': data};
              sendJSONData(res, json);
            });
          }
  	  	break;

  	  	default:
          data = {"errors":[errmsg['10']]};
          sendJSONData(res, data);
  	  	break;
      }
  }
  else {
    util.loadStaticFile(uri.pathname, res);
  }
}).listen(8080, "127.0.0.1");