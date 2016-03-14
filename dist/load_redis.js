const Promise = require('bluebird')
const fs = require('fs')
const redis = require('redis')
const Scripto = require('redis-scripto')
Promise.promisifyAll(redis.RedisClient.prototype)

const client = redis.createClient(6379, 'dockerip')


fs.readFile('./what_could_be.lua', 'utf8', (err, data) => {
  if (err) throw err;
  var file = data.split("--<<--")[1]
  var scriptManager = new Scripto(client)
  scriptManager.load({"load-do": file})

  scriptManager.run("load-do", ["domain", "user_id", "salt"], ["do-fanatics.com", "123454", "foo"], function(err, result) {
    console.log(result)
  })
});
