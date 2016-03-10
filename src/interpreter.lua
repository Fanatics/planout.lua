require("lib.utils")
require("ops.utils")
require("ops.core")

local pretty = require 'pl.pretty'

local Experiment = require "experiment"
local Assignment = require "assignment"

local Interpreter = {}

function Interpreter:new(serialization, experimentSalt, inputs, environment)
  return _new_(self, {}):init(serialization, experimentSalt, inputs, environment)
end

function Interpreter:init(serialization, experimentSalt, inputs, environment)
  experimentSalt = experimentSalt or 'global_salt'
  inputs = inputs or {}

  self.serialization = serialization
  self._env = environment or Assignment:new(experimentSalt)
  self.experimentSalt = experimentSalt
  self._experimentSalt = experimentSalt
  self._evaluated = false
  self._inExperiment = false
  self._inputs = shallowcopy(inputs)

  return self
end

function Interpreter:inExperiment()
  return self._inExperiment
end

function Interpreter:setEnv(newEnv)
  self._env = deepCopy(newEnv);
  return self;
end

function Interpreter:has(name)
  return self._env[name]
end

function Interpreter:get(name, defaultVal)
  return self._inputs[name] or self._env:get(name) or defaultVal
end

function Interpreter:getParams()
  local me = self
  if not self._evaluated then
    local status, err = pcall(function()
      me:evaluate(me.serialization)
    end)
    if instanceOf(err, StopPlanOutException) then
      self._inExperiment = err.inExperiment
    end
    self._evaluated = true
  end
  return self._env:getParams();
end

function Interpreter:set(key, value)
  self._env:set(key, value)
  return self
end

function Interpreter:setOverrides(overrides)
  self._env:setOverrides(overrides)
  return self
end

function Interpreter:getOverrides()
  return self._env:getOverrides()
end

function Interpreter:hasOverride(name)
  local overrides = self:getOverrides()
  return overrides ~= nill and overrides[name] ~= nil
end

function Interpreter:evaluate(planoutCode)
  if type(planoutCode) == "table" and planoutCode.op ~= nil then
    local oi = operatorInstance(planoutCode)
    return oi:execute(self)
  elseif type(planoutCode) == "table" and planoutCode[1] ~= nil then
    local arr = {}
    for i, val in ipairs(planoutCode) do
      table.insert(arr, self:evaluate(val))
    end
    return arr
  else return planoutCode end
end

return Interpreter
