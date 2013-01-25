    url = require('url'),
    redis = require('redis'),
    util = require('./util'),
    
    // redis connection
    redisdb = redis.createClient();

redisdb.on("error", function (err) {
    console.log("Redis Error " + err);
});

var dbkey = "fund.primary.group:US Equity:tickers";
redisdb.select(0, function(reply) {
  redisdb.smembers(dbkey, function(err, data) {
    console.dir(data);
  });
});
