require("lib.utils")
JSON = require "lib.JSON"
local pretty = require 'pl.pretty'

Assignment = {}

function Assignment:new(experimentSalt, overrides)
  return _new_(self, {}):init(experimentSalt, overrides)
end

function Assignment:init(experimentSalt, overrides)
  if type(overrides) ~= "table" then overrides = {} end
  self.experimentSalt = experimentSalt
  self.overrides = shallowcopy(overrides)
  self.data = shallowcopy(overrides)

  return self
end

function Assignment:evaluate(value)
  return value
end

function Assignment:getOverrides()
  return self.overrides
end

function Assignment:addOverride(key, value)
  self.overrides[key] = value
  self.data[key] = value
end

function Assignment:setOverrides(overrides)
  self.overrides = shallowcopy(overrides)
  for k, v in pairs(self.overrides) do self.data[k] = v end
end

function Assignment:set(name, value)
  if name == "_data" then self.data = value return
  elseif name == "_overrides" then self.overrides = value return
  elseif name == "experimentSalt" then self.experimentSalt = value return end

  if self.overrides[name] ~= nil then return end
  if instanceOf(value, PlanOutOpRandom) then
    if value.args.salt == nil then value.args.salt = name end
    self.data[name] = value:execute(self)
  else
    self.data[name] = value
  end
end

function Assignment:get(name)
  if name == "_data" then return self.data
  elseif name == "_overrides" then return self.overrides
  elseif name == "experimentSalt" then return self.experimentSalt
  else return self.data[name] end
end

function Assignment:getParams()
  return self.data
end

function Assignment:del(name)
  this.data[name] = nil
end

function Assignment:toString()
  return JSON:encode(self.data)
end

function Assignment:length()
  return tablelength(self.data)
end

return Assignment
