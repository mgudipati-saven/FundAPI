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
 * http connection handlers
 */
http.createServer(function (req, res) {
    console.log("Received web client request: -------------------->" + req.url);
    var uri = url.parse(req.url, true);
    
    if (uri.pathname === "/funds") {
        var cmd = uri.query.cmd;
        
        switch (cmd) {
        	case 'search':
        		// funds?cmd=search&name=Fidelity Emerging Asia Fund&pgrp=US Equity&sgrp=Utilities
        		var key1, key2, key3 = null;
        		
				if (uri.query.name != null) { 
					key1 = "FUND::NAME::"+uri.query.name;
				}
				
				if (uri.query.pgrp != null) {
					key2 = "FUND::GROUP::PRIMARY::"+uri.query.pgrp;					
				}
				
				if (uri.query.sgrp != null) {
					key3 = "FUND::GROUP::SECONDARY::"+uri.query.sgrp;
				}

				if (key1 != null && key2 != null && key3 != null) {
					redisdb.select(0, function(reply) {				
						redisdb.sinter(key1, key2, key3, function(err, data) {
					        console.log(data);
					        res.writeHead(200, {'Content-Type': 'text/plain'});
					        res.write(JSON.stringify(data));
					        res.end();
						});
					});
				} else if (key1 != null && key2 != null) {
					redisdb.select(0, function(reply) {				
						redisdb.sinter(key1, key2, function(err, data) {
					        console.log(data);
					        res.writeHead(200, {'Content-Type': 'text/plain'});
					        res.write(JSON.stringify(data));
					        res.end();
						});
					});
				} else if (key2 != null && key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.sinter(key2, key3, function(err, data) {
					        console.log(data);
					        res.writeHead(200, {'Content-Type': 'text/plain'});
					        res.write(JSON.stringify(data));
					        res.end();
						});
					});
				} else if (key1 != null && key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.sinter(key1, key3, function(err, data) {
					        console.log(data);
					        res.writeHead(200, {'Content-Type': 'text/plain'});
					        res.write(JSON.stringify(data));
					        res.end();
						});
					});
				} else if (key1 != null) {
					redisdb.select(0, function(reply) {
						redisdb.smembers(key1, function(err, data) {
					        console.log(data);
					        res.writeHead(200, {'Content-Type': 'text/plain'});
					        res.write(JSON.stringify(data));
					        res.end();
						});
					});
				} else if (key2 != null) {
					redisdb.select(0, function(reply) {
						redisdb.smembers(key2, function(err, data) {
					        console.log(data);
					        res.writeHead(200, {'Content-Type': 'text/plain'});
					        res.write(JSON.stringify(data));
					        res.end();
						});
					});
				} else if (key3 != null) {
					redisdb.select(0, function(reply) {
						redisdb.smembers(key3, function(err, data) {
					        console.log(data);
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
					dbkey = "FUND::BASIC::"+ticker;
				redisdb.select(0, function(reply) {
			        redisdb.hgetall(dbkey, function(err, data) {
			            console.log("Basics ==========>" + JSON.stringify(data));
			            res.writeHead(200, {'Content-Type': 'text/plain'});
			            res.write(JSON.stringify(data));
			            res.end();
			        });
				});
		  	break;

        	case 'perf':
        		// funds?cmd=perf&ticker=FMAGX
        		var ticker = uri.query.ticker,
					dbkey = "FUND::PERFORMANCE::"+ticker;
				redisdb.select(0, function(reply) {
			        redisdb.hgetall(dbkey, function(err, data) {
			            console.log("Performance =======>" + JSON.stringify(data));
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
        }
    }
    else {
        util.loadStaticFile(uri.pathname, res);
    }
}).listen(8080, "127.0.0.1");