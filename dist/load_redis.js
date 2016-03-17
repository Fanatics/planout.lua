const Promise = require('bluebird')
const redis = require('redis')
const Scripto = require('redis-scripto')
Promise.promisifyAll(redis.RedisClient.prototype)

const client = redis.createClient(6379, 'dockerip')

var file = `
local arguments = {}
local success, errState = pcall(function()
  if #KEYS == #ARGV then
    for i, keyname in ipairs(KEYS) do arguments[keyname] = ARGV[i] end
  end
end)
if not success then return cjson.encode(arguments) end

local shallowcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local merge = function(results, ...)
  local arg={...}
  for i,v in ipairs(arg) do
    if type(v) == "table" then
      for k,vp in pairs(v) do
        results[k] = shallowcopy(vp)
      end
    else
      table.insert(results, v)
    end
  end
  return results
end

--PlanOut classes--

return (function(args)
  return (function(my_input)
    local var = cjson.decode(redis.call("get", args['domain']))
    local status, err = pcall(function() merge(my_input, var) end)
    if not status then return cjson.encode(err) end
    --PlanOuto script--
    return cjson.encode(my_input)
  end)(args)

end)(arguments)`

client.send_commandAsync("script", ["load", file]).then((sha1) => {
  client.send_commandAsync("keys", [`do-*`])
    .then((result) => {
      /*
      "do-notinasitegroup.com",
      "do-nflshop.com",
      "do-fanatics.com"
      */
      result.forEach((domainObject) => {
        client.set(domainObject.replace("do", "plos"), sha1, ()=>{})
      })
    }).then(() => {
      // After script has been loaded into redis
      client.getAsync("plos-nflshop.com").then((val) => {
        client.send_commandAsync('evalsha', [val, //SHA1 value
          3, //Number of arguments
          // Keys
          "domain",         "user_id",  "salt",
          // Values
          "do-nflshop.com", "123454",   "foo"])
          .then((result) => {
            console.log(result)
          }).catch((err) => {
            console.log(err)
          }).finally(() => client.end(true))
      })
    })
})
