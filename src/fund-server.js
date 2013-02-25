var http = require('http'),
    url = require('url'),
    redis = require('redis'),
    util = require('./util');

// error codes and messages
var errmsg = {};
errmsg['InvalidCommand'] = {"message":"Invalid command","code":10};
errmsg['InvalidParam'] = {"message":"Invalid parameter","code":20};
errmsg['MissingParam'] = {"message":"Missing parameter","code":30};

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
 *  {
      'holdings': [
          {
            'HoldingCompany':'Applied Materials, Inc.',
            'HoldingValue':1098001000
          },
          {
            'HoldingCompany':'Nokia Corp. sponsored ADR',
            'HoldingValue':1078759000
          },
          ...
          ...
        ]
    }
 * @param       res   response channel
 * @param       name  fund name
 * @param       n     number of holdings
 * @access      public
 */ 
function sendFundHoldings(res, name, n) {
  var json = {'holdings':[]};
  
  redisdb.select(0, function(reply) {
    // obtain the latest holdings date
    var dbkey = "fund.name:"+name+":holding.dates";
    if (redisdb.exists(dbkey)) {
      redisdb.zrevrange(dbkey, 0, n, function(err, dates) {
        if (dates.length != 0 && dates[0] != null) {
          dbkey = "fund.name:"+name+":holdings:"+dates[0];
          redisdb.zrevrange(dbkey, 0, n, function(err, data) {
            json['holdings'] = data;
            sendJSONData(res, json);
          });
        } else {
          sendJSONData(res, json);
        }
      });
    }
  });
}

/*
 * sendFundAllocation(res, name, type):
 *  sends fund allocation data - asset, sector, geography.
 *  {
      'alloc': {
        'asset': [
          {
            'Asset':'Common Stocks',
            'Allocation':94.2
          },
          {
            'Asset':'Money Market Funds',
            'Allocation':3.2
          },
          ...
          ...
        ],
        'sector': [
          {
            'Sector':'Telecommunications',
            'Allocation':4.2
          },
          {
            'Sector':'Utilities',
            'Allocation':3.2
          },
          ...
          ...
        ],
        'geo': [
          {
            'Country':'United States of America',
            'Allocation':94.2
          },
          {
            'Country':'Switzerland',
            'Allocation':3.2
          },
          ...
          ...
        ]
      }
    }
 *  
 * @param       res   response channel
 * @param       name  fund name
 * @param       type  type of allocation - asset or sector or geo
 * @access      public
 */ 
function sendFundAllocation(res, name, type) {
  var dbkey = null;
  var json = {'alloc':{}};
  
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
          json['alloc'][type] = data;
          sendJSONData(res, json);
        });
      } else {
        json['alloc'][type] = [];
        sendJSONData(res, json);
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
          sendJSONData(res, {'results':results});
        });
      } else {
        sendJSONData(res, {'results':[]});
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
    	  // funds.json?cmd=tickers
    	  // {"tickers":["AAAAX", "AAABX", ...]}
  	    dbkey = "fund.tickers";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            var json = {'tickers': data};
            sendJSONData(res, json);
					});
				});
      break;

      case 'names':
    	  // funds.json?cmd=names
    	  // {"names":["Fidelity Magellan Fund", "Blackrock Fund", ...]}
  	    dbkey = "fund.names";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            var json = {'names': data};
            sendJSONData(res, json);
					});
				});
      break;

      case 'sponsors':
    	  // funds.json?cmd=sponsors
  	    // {"sponsors":["Fidelity Magellan", "Blackrock", ...]}
  	    dbkey = "fund.sponsors";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            var json = {'sponsors': data};
            sendJSONData(res, json);
					});
				});
      break;
      
      case 'pgroups':
    	  // funds.json?cmd=pgroups
    	  // {"pgroups":["US Equity", "Global Equity", ...]}
  	    dbkey = "fund.primary.groups";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            var json = {'pgroups': data};
            sendJSONData(res, json);
					});
				});
      break;

      case 'sgroups':
    	  // funds.json?cmd=sgroups
        // {"sgroups":["Midcap", "Smallcap", ...]}
  	    dbkey = "fund.secondary.groups";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            var json = {'sgroups': data};
            sendJSONData(res, json);
					});
				});
      break;

      case 'benchmarks':
    	  // funds.json?cmd=benchmarks
        // {"benchmarks":["S&P 500", "NASDAQ 100", ...]}
  	    dbkey = "fund.benchmark.indices";
				redisdb.select(0, function(reply) {				
					redisdb.zrange(dbkey, 0, -1, function(err, data) {
            var json = {'benchmarks': data};
            sendJSONData(res, json);
					});
				});
      break;

      case 'complete':
      	// funds.json?cmd=complete&ticker=FM OR funds.json?cmd=complete&name=Fidelity
      	// {"results":["FMAGX", "FMBGX", ...]}
      	// {"results":["Fidelity Magellan", "Fidelity Capital", ...]}
      	var ticker = uri.query.ticker;
      	var name = uri.query.name;
    	
      	if (ticker != null) {
          sendGoogleSuggestionList(res, "fund.tickers.auto.complete", ticker);
        } else if (name != null) {
          sendGoogleSuggestionList(res, "fund.names.auto.complete", name);
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
      break;

      case 'searchByName':
      	// funds?cmd=searchByName&name=Fidelity Emerging Asia Fund
      	// {"tickers":["AAAAX", "AAABX", ...]}
      	var name = uri.query.name;

      	if (name != null) {
  				redisdb.select(0, function(reply) {				
      	    var dbkey = "fund.name:"+name+":tickers";
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
              sendJSONData(res, {'tickers': data});
  					});
  				});
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
      break;
        
      case 'searchByPrimaryGroup':
    	  // funds?cmd=searchByPrimaryGroup&pgrp=US Equity
        var pgrp = uri.query.pgrp;
        
    	  if (pgrp != null) {
  				redisdb.select(0, function(reply) {				
    	      var dbkey = "fund.primary.group:"+pgrp+":tickers";
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
              sendJSONData(res, {'tickers': data});
  					});
  				});
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
      break;

      case 'searchBySecondaryGroup':
    	  // funds?cmd=searchBySecondaryGroup&sgrp=Utilities
        var sgrp = uri.query.sgrp;

    	  if (sgrp != null) {
  				redisdb.select(0, function(reply) {				
    	      var dbkey = "fund.secondary.group:"+sgrp+":tickers";
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
              sendJSONData(res, {'tickers': data});
  					});
  				});
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
      break;

      case 'searchByBenchmarkIndex':
      	// funds?cmd=searchByBenchmarkIndex&bindex=S&P 500
        var bindex = uri.query.bindex;

      	if (bindex != null) {
  				redisdb.select(0, function(reply) {				
      	    var dbkey = "fund.benchmark.index:"+uri.query.bindex+":tickers";
  					redisdb.zrange(dbkey, 0, -1, function(err, data) {
              sendJSONData(res, {'tickers': data});
  					});
  				});
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
      break;
      
      case 'searchByLoadType':
      	// funds?cmd=searchByLoadType&type=Y
        var type = (uri.query.type == null) ? "N" : uri.query.type;
        
				redisdb.select(0, function(reply) {				
        	var dbkey = "fund.tickers";
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
              sendJSONData(res, {'tickers': arr});
        		});
					});
				});
      break;

      case 'searchByInitialInvestment':
      	// funds?cmd=searchByInitialInvestment&lt=2500
      	var startr = (uri.query.gt == null) ? 0 : parseInt(uri.query.gt);
      	var endr = (uri.query.lt == null) ? 1000000000 : parseInt(uri.query.lt);
        
        if (isNaN(startr) || isNaN(endr)) {
          data = {"errors":[errmsg['InvalidParam']]};
          sendJSONData(res, data);
        } else {
  				redisdb.select(0, function(reply) {				
          	var dbkey = "fund.tickers";
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
                sendJSONData(res, {'tickers': arr});
          		});
  					});
  				});
        }
      break;

      case 'searchByReturns':
      	// funds?cmd=searchByReturns&param=Yr1&lt=25
      	var startr = (uri.query.gt == null) ? -1000 : parseFloat(uri.query.gt);
      	var endr = (uri.query.lt == null) ? 1000 : parseFloat(uri.query.lt);
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
        
        if (isNaN(startr) || isNaN(endr)) {
          data = {"errors":[errmsg['InvalidParam']]};
          sendJSONData(res, data);
        } else {
  				redisdb.select(0, function(reply) {				
          	var dbkey = "fund.tickers";
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
                sendJSONData(res, {'tickers': arr});
          		});
  					});
  				});
        }
      break;

      case 'searchByRatios':
      	// funds?cmd=searchByRatios&param=Turnover&lt=25
      	var startr = (uri.query.gt == null) ? 0.0 : parseFloat(uri.query.gt);
      	var endr = (uri.query.lt == null) ? 100.0 : parseFloat(uri.query.lt);
        var metric = null;
        
        switch (uri.query.param) {
          case 'Turnover':
            metric = "Turnover";
            break;
            
          case 'ExpenseRatio':
            metric = "TotalExpenseRatio";
            break;
        }
        
        if (uri.query.param == null) {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        } else if (isNaN(startr) || isNaN(endr) || metric == null) {
          data = {"errors":[errmsg['InvalidParam']]};
          sendJSONData(res, data);
        } else {
  				redisdb.select(0, function(reply) {				
          	var dbkey = "fund.tickers";
  					redisdb.zrange(dbkey, 0, -1, function(err, tickers) {
              var arr = [];
              var multi = redisdb.multi();
              tickers.forEach(function(ticker, pos) {
                dbkey = "fund:"+ticker+":ratios";
                multi.hget(dbkey, metric, function(err, data) {
                  var ratio = parseFloat(data);
                  if (ratio > startr && ratio <= endr) {
                    arr.push(ticker);
                  }
                });
              });
              multi.exec(function (err, replies) {
                sendJSONData(res, {'tickers': arr});
          		});
  					});
  				});
        }
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
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
            var dbkey = "fund:"+ticker+":basics";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'basics':{}};
  	          if (data != null) {
  	            json['basics'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  		    });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
  	  break;

    	case 'returns':
    		// funds?cmd=returns&ticker=FMAGX
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
			      var dbkey = "fund:"+ticker+":returns";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'returns':{}};
  	          if (data != null) {
  	            json['returns'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
	  	break;

    	case 'sponsor':
    		// funds?cmd=sponsor&ticker=FMAGX
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
			      var dbkey = "fund:"+ticker+":sponsor";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'sponsor':{}};
  	          if (data != null) {
  	            json['sponsor'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
	  	break;

    	case 'profile':
    		// funds?cmd=profile&ticker=FMAGX
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
    			  var dbkey = "fund:"+ticker+":profile";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'profile':{}};
  	          if (data != null) {
  	            json['profile'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
	  	break;

    	case 'managers':
    		// funds?cmd=managers&ticker=FMAGX
    		// {'managers':{'ManagerName1':'Jeffrey Feingold', 'ManagerTenure1':'September 2011', ...}}
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
  		      var dbkey = "fund:"+ticker+":managers";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'managers':{}};
  	          if (data != null) {
  	            json['managers'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
	  	break;

    	case 'ratios':
    		// funds?cmd=ratios&ticker=FMAGX
    		// {'ratios':{'TotalExpenseRatio':0.5, ...}}
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
  		      var dbkey = "fund:"+ticker+":ratios";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'ratios':{}};
  	          if (data != null) {
  	            json['ratios'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
	  	break;

    	case 'fees':
    		// funds?cmd=fees&ticker=FMAGX
    		// {'fees': {'ManagementFees':0.35, 'b12-1Fee':0.1, ...}}
    		var ticker = uri.query.ticker;

        if (ticker != null) {
  		    redisdb.select(0, function(reply) {
  		      var dbkey = "fund:"+ticker+":fees";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          var json = {'fees':{}};
  	          if (data != null) {
  	            json['fees'] = data;
  	          }
              sendJSONData(res, json);
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
	  	break;

    	case 'hist':
    		// funds?cmd=hist&ticker=FMAGX
        /*
        {
          "history": {
            "TotalNetAssets": {
              "2008-03-31": "38322000000",
              "2009-03-31": "17225000000",
              "2010-03-31": "22628000000",
              "2011-03-31": "19398000000",
              "2012-03-31": "13665000",
              "2007-03-31": "43155000000"
            },
            "Turnover": {
              "2008-03-31": "57",
              "2009-03-31": "67",
              "2010-03-31": "39",
              "2011-03-31": "42",
              "2012-03-31": "99",
              "2007-03-31": "41"
            },
            "TotalReturns": {
              "2008-03-31": "2.08",
              "2009-03-31": "-43.81",
              "2010-03-31": "52.33",
              "2011-03-31": "12.82",
              "2012-03-31": "-2.36",
              "2007-03-31": "3.21"
            }
          }
        }
        */
    		var ticker = uri.query.ticker;

        if (ticker != null) {
          var json = {'history':{}};
  		    redisdb.select(0, function(reply) {
			      var dbkey = "fund:"+ticker+":TotalNetAssets";
  	        redisdb.hgetall(dbkey, function(err, data) {
  	          json['history']['TotalNetAssets'] = data;
  			      var dbkey = "fund:"+ticker+":Turnover";
    	        redisdb.hgetall(dbkey, function(err, data) {
    	          json['history']['Turnover'] = data;
    			      var dbkey = "fund:"+ticker+":TotalReturns";
      	        redisdb.hgetall(dbkey, function(err, data) {
      	          json['history']['TotalReturns'] = data;
                  sendJSONData(res, json);
    	          });
  	          });
  	        });
  			  });
        } else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
        }
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
  		      redisdb.hget(dbkey, "SeriesName", function(err, data) {
              sendFundHoldings(res, data, 9);
		        });
  			  });
    		} else if (name != null) {
          sendFundHoldings(res, name, 9);
    		} else {
    		  data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);		      
    		}
	  	break;

    	case 'alloc':
    		// funds?cmd=alloc&type=asset&name=Fidelity Magellan Fund
    		// OR
    		// funds?cmd=alloc&type=asset&ticker=FMAGX
    		var name = uri.query.name,
		        ticker = uri.query.ticker,
		        type = uri.query.type;

		    if ((ticker == null && name == null) || type == null) {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);		      
		    } else if (ticker != null) {
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
    		// {"prices":{"TickerSymbol":"IBM", "LastPrice":100.10, "BidPrice:99.00, ..."}}
    		var ticker = uri.query.ticker;
    		
    		if (ticker != null) {
  			  var dbkey = "338::"+ticker;
  		    redisdb.select(0, function(reply) {
  	        redisdb.get(dbkey, function(err, data) {
              var json = {'prices': {}};
              if (data != null) {
                json = {'prices':data};
              }
              sendJSONData(res, json);
  	        });
  			  });
    		} else {
          data = {"errors":[errmsg['MissingParam']]};
          sendJSONData(res, data);
    		}
    		
	  	break;

	  	default:
        data = {"errors":[errmsg['InvalidCommand']]};
        sendJSONData(res, data);
	  	break;
    } // switch (cmd)
  } else if (uri.pathname === "/etfs.json") {
      var cmd = uri.query.cmd;

      switch (cmd) {
      	case 'profile':
      		// etfs.json?cmd=profile&ticker=SPY
      		// {"profile":{"CUSIP":123456789, ...}}
      		var ticker = uri.query.ticker;

          if (ticker != null) {
    			  var dbkey = "etf:"+ticker+":profile";
    		    redisdb.select(0, function(reply) {
    	        redisdb.hgetall(dbkey, function(err, data) {
    	          var json = {'profile':{}};
    	          if (data != null) {
    	            json['profile'] = data;
    	          }
                sendJSONData(res, json);
    	        });
    			  });
          } else {
            data = {"errors":[errmsg['MissingParam']]};
            sendJSONData(res, data);
  			  }
  	  	break;

      	case 'components':
      		// etfs.json?cmd=components&ticker=SPY
      		// {"components":[{"TickerSymbol":"IBM"}, {"ShareQuantity":10000}, ...]}
      		var ticker = uri.query.ticker;
          
          if (ticker != null) {
  		      var dbkey = "etf:"+ticker+":components";
    		    redisdb.select(0, function(reply) {
              redisdb.zrevrange(dbkey, 0, 9, function(err, data) {
                var json = {'components': data};
                sendJSONData(res, json);
              });
    			  });
          } else {
            data = {"errors":[errmsg['MissingParam']]};
            sendJSONData(res, data);
          }
  	  	break;

      	case 'searchByComponent':
      		// etfs.json?cmd=searchByComponent&ticker=IBM
      		// {"tickers":["SPY", "AAA", ...]}
      		var ticker = uri.query.ticker;

          if (ticker != null) {
    		    redisdb.select(0, function(reply) {
  		      var dbkey = ticker+":etf.tickers";
              redisdb.zrange(dbkey, 0, -1, function(err, data) {
                var json = {'tickers': data};
                sendJSONData(res, json);
              });
    			  });
          } else {
            data = {"errors":[errmsg['MissingParam']]};
            sendJSONData(res, data);
          }
  	  	break;

  	  	default:
          data = {"errors":[errmsg['InvalidCommand']]};
          sendJSONData(res, data);
  	  	break;
      }
  }
  else {
    util.loadStaticFile(uri.pathname, res);
  }
}).listen(8080, "127.0.0.1");