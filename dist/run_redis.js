const Promise = require('bluebird')
const fs = require('fs')
const redis = require('redis')
const Scripto = require('redis-scripto');
Promise.promisifyAll(redis.RedisClient.prototype)

const client = redis.createClient(6379, 'dockerip')

var scriptManager = new Scripto(client)

scriptManager.run("what", [], [], function(err, result) {
  console.log(result)
})
