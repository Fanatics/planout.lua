package.path = package.path .. ";../?.lua"
local utils = require("lib.utils")
local base = require("ops.base")
local bc = require "bc"
local sha1hex = redis and redis.sha1hex or require("lib.sha1")

local PlanOutOpRandom = base.PlanOutOpSimple:new()

function PlanOutOpRandom:init(args)
  self.args = args
  self.LONG_SCALE = utils.hex2bc("FFFFFFFFFFFFFFF");
  return self
end

function PlanOutOpRandom:getUnit(appendedUnit)
  local unit = self:getArgMixed('unit')
  if type(unit) ~= "table" or unit[1] == nil then unit = {unit} end
  if appendedUnit ~= nil then table.insert(unit, appendedUnit) end
  return unit
end

function PlanOutOpRandom:getUniform(minVal, maxVal, appendedUnit)
  minVal = minVal or 0.0
  maxVal = maxVal or 1.0
  local zeroToOne = bc.tonumber(bc.div(self:getHash(appendedUnit), self.LONG_SCALE))
  return zeroToOne * (maxVal - minVal) + (minVal)
end

function PlanOutOpRandom:getHash(appendedUnit)
  local fullSalt
  if self.args.full_salt ~= nil then fullSalt = self:getArgString('full_salt')
  else
    local salt
    if self.args.salt ~= nil then salt = self:getArgString('salt') else salt = self.mapper:get('experimentSalt') end
    fullSalt = self.mapper:get('experimentSalt') .. "." .. salt
  end

  local unitStr = table.concat(utils.map(self:getUnit(appendedUnit), function (val)
    return val .. ""
  end), ".")
  local hashStr = fullSalt .. "." .. unitStr
  local hash = sha1hex(hashStr)
  return utils.hex2bc(string.sub(hash, 0, 15))
end


local RandomFloat = PlanOutOpRandom:new()

function RandomFloat:simpleExecute()
  local minVal = self:getArgNumber('min');
  local maxVal = self:getArgNumber('max');
  return self:getUniform(minVal, maxVal);
end


local RandomInteger = PlanOutOpRandom:new()

function RandomInteger:simpleExecute()
  local minVal = self:getArgNumber('min');
  local maxVal = self:getArgNumber('max');
  return bc.tonumber(bc.mod(bc.add(self:getHash(), minVal), bc.number(maxVal - minVal + 1)));
end


local BernoulliTrial = PlanOutOpRandom:new()

function BernoulliTrial:simpleExecute()
  local p = self:getArgNumber('p');
  if p < 0 or p > 1 then error "Invalid probability"; end
  if self:getUniform(0.0, 1.0) <= p then return 1 else return 0 end
end


local BernoulliFilter = PlanOutOpRandom:new()

function BernoulliFilter:simpleExecute()
  local p = self:getArgNumber('p');
  local values = self:getArgList('choices')
  if p < 0 or p > 1 then error "Invalid probability"; end
  if #values == 0 then return {} end

  local result = {}
  for i, val in ipairs(values) do
    if self:getUniform(0.0, 1.0, val) <=p then table.insert(result, val) end
  end
  return result
end


local UniformChoice = PlanOutOpRandom:new()

function UniformChoice:simpleExecute()
  local values = self:getArgList('choices')
  if #values == 0 then return {} end
  local rand_index = bc.tonumber(bc.mod(self:getHash(), #values)) + 1
  return values[rand_index]
end


local WeightedChoice = PlanOutOpRandom:new()

function WeightedChoice:simpleExecute()
  local values = self:getArgList('choices')
  local weights = self:getArgList('weights')
  if #values == 0 then return {} end

  local cumSum = 0
  local cumWeights = {}
  for i, val in ipairs(weights) do
    cumSum = cumSum + val
    table.insert(cumWeights, cumSum)
  end
  local stopVal = self:getUniform(0.0, cumSum)
  for i, val in ipairs(cumWeights) do
    if stopVal <= val then return values[i] end
  end
  return nil
end


local Sample = PlanOutOpRandom:new()

function Sample:sample(array, numDraws)
  for i = #array, 1, -1 do
    local j = bc.tonumber(bc.mod(self:getHash(i), i + 1)) + 1
    local temp = array[i]
    array[i] = array[j]
    array[j] = temp;
  end

  return table.slice(array, 1, numDraws)
end

function Sample:simpleExecute()
  local values = utils.shallowcopy(self:getArgList('choices'))
  local numDraws = 0
  if self.args.draws ~= nil then numDraws = self:getArgNumber('draws')
  else numDraws = #values end
  return self:sample(values, numDraws)
end

return {
  Sample = Sample,
  WeightedChoice = WeightedChoice,
  UniformChoice = UniformChoice,
  BernoulliFilter = BernoulliFilter,
  BernoulliTrial = BernoulliTrial,
  RandomInteger = RandomInteger,
  RandomFloat = RandomFloat,
  PlanOutOpRandom = PlanOutOpRandom
}
