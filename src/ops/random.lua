package.path = package.path .. ";../?.lua"
require("lib.utils")
require("ops.base")

local sha1 = require "lib.sha1"
local pretty = require 'pl.pretty'

PlanOutOpRandom = PlanOutOpSimple:new()

function PlanOutOpRandom:init(args)
  self.args = args
  self.LONG_SCALE_NON_COMPAT = 0xFFFFFFFFFFFFF;
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
  local zeroToOne = self:getHash(appendedUnit) / self.LONG_SCALE_NON_COMPAT
  return zeroToOne * (maxVal - minVal) + (minVal)
end

function PlanOutOpRandom:getHash(appendedUnit)
  local fullSalt
  if self.args.full_salt ~= nil then fullSalt = self:getArgString('full_salt')
  else
    local salt = self:getArgString('salt')
    fullSalt = self.mapper:get('experimentSalt') .. "." .. salt
  end

  local unitStr = table.concat(map(self:getUnit(appendedUnit), function (val)
    return val .. ""
  end), ".")
  local hashStr = fullSalt .. "." .. unitStr
  local hash = sha1(hashStr)
  return tonumber(string.sub(hash, 0, 13), 16)
end


RandomFloat = PlanOutOpRandom:new()

function RandomFloat:simpleExecute()
  local minVal = self:getArgNumber('min');
  local maxVal = self:getArgNumber('max');
  return self:getUniform(minVal, maxVal);
end


RandomInteger = PlanOutOpRandom:new()

function RandomInteger:simpleExecute()
  local minVal = self:getArgNumber('min');
  local maxVal = self:getArgNumber('max');
  return (self:getHash() + minVal) % (maxVal - minVal + 1);
end


BernoulliTrial = PlanOutOpRandom:new()

function BernoulliTrial:simpleExecute()
  local p = self:getArgNumber('p');
  if p < 0 or p > 1 then error "Invalid probability"; end
  if self:getUniform(0.0, 1.0) <= p then return 1 else return 0 end
end


BernoulliFilter = PlanOutOpRandom:new()

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


UniformChoice = PlanOutOpRandom:new()

function UniformChoice:simpleExecute()
  local values = self:getArgList('choices')
  if #values == 0 then return {} end
  local rand_index = math.fmod(self:getHash(), #values) + 1
  --print(JSON:encode(values) .. ":" .. rand_index .. ":" .. values[rand_index])
  return values[rand_index]
end


WeightedChoice = PlanOutOpRandom:new()

function WeightedChoice:simpleExecute()
  local values = self:getArgList('choices')
  local weights = self:getArgList('weights')
  if #values == 0 then return {} end

  local cumSum = 0
  for i, val in weights do cumSum = cumSum + val end
  local stopVal = self:getUniform(0.0, cumSum) ----
end


Sample = PlanOutOpRandom:new()

function Sample:sample(array, numDraws)
  local len = #array
  local stoppingPoint = len - numDraws + 1

  for i, val in ipairs(array) do
    local j = self:getHash(i) % i
    local temp = array[i]
    array[i] = array[j]
    array[j] = temp;

    if stoppingPoint == i then
      return table.slice(array, i, len)
    end
  end
  return table.slice(array, 1, numDraws)
end

function Sample:simpleExecute()
  local values = shallowcopy(self:getArgList('choices'))
  local numDraws = 0
  if self.args.draws ~= nil then numDraws = self:getArgNumber('draws')
  else numDraws = #values end
  return self:sample(values, numDraws)
end
