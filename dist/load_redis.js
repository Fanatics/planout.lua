const Promise = require('bluebird')
const redis = require('redis')
const Scripto = require('redis-scripto')
Promise.promisifyAll(redis.RedisClient.prototype)
const noop = () => {}
const client = redis.createClient(6379, 'dockerip')

var file = `
local arguments = cjson.decode(ARGV[1])

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
    local doName = "do-" .. args['domain']
    if args["_do"] ~= nil and redis.call("EXISTS", args["_do"]) == 1 then doName = args["_do"] end

    local var = cjson.decode(redis.call("get", doName))
    local status, err = pcall(function() merge(my_input, var) end)
    if not status then return cjson.encode(err) end
    --PlanOuto script--
    return cjson.encode(my_input)
  end)(args)

end)(arguments)`

var settingsResolver = `
local arguments = cjson.decode(ARGV[1])
local result = {}
local plos = 'plos-' .. arguments['domain']
local dos = 'do-' .. arguments['domain']

local ws = nil
if arguments["workspace"] ~= nil then ws = "ws-" .. arguments["workspace"] .. "-" end

if ws ~= nil and redis.call("EXISTS", ws .. plos) == 1 then
  result["plos"] = redis.call("GET", ws .. plos)
elseif redis.call("EXISTS", plos) == 1 then
  result["plos"] = redis.call("GET", plos)
end

if ws ~= nil and redis.call("EXISTS", ws .. dos) == 1 then
  result["_do"] = ws .. dos
elseif redis.call("EXISTS", dos) == 1 then
  result["_do"] = dos
end

return cjson.encode(result)
`
var context = {
  "domain": "nflshop.com",
  "user_id": "123454",
  "salt": "foo",
  "app": "iris",
  "resource": "hp",
  "workspace": "mgloystein"
}

client.send_commandAsync("script", ["load", settingsResolver]).then((resolverSha) => {
  client.set("__settings-resolver", resolverSha, noop)

  client.send_commandAsync("script", ["load", file]).then((sha1) => {
    client.send_commandAsync("keys", [`do-*`]).then((result) => {
      /*
      "do-notinasitegroup.com",
      "do-nflshop.com",
      "do-fanatics.com"
      */
      result.forEach((domainObject) => {
        client.set(domainObject.replace("do", "plos"), sha1, noop)
      })
    }).then(() => {
      // After script has been loaded into redis
      client.getAsync("__settings-resolver").then((resolverSha) => {
        client.send_commandAsync('evalsha', [resolverSha, 1, "context", JSON.stringify(context)])
          .then((result) => {
            result = JSON.parse(result)
            context["_do"] = result["_do"]
            client.send_commandAsync('evalsha', [result.plos, 1, "context", JSON.stringify(context)])
              .then((result) => {
                console.log(result)
              }).catch((err) => {
                console.log(err)
              }).finally(() => client.end(true))
          })
      })
    })
  })
})
