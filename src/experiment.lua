require("lib.utils")
local JSON = require "lib.JSON"
local Assignment = require "assignment"

local pretty = require 'pl.pretty'
local Experiment = {}

function Experiment:new(inputs)
  return _new_(self, {}):init(inputs)
end

function Experiment:init(inputs)
  self.inputs = inputs
  self.exposureLogged = false
  self.salt = nil
  self._inExperiment = true

  self.name = self:getDefaultExperimentName()
  self.autoExposureLogging = true

  self:setup()

  self.assignment = Assignment:new(self:getSalt())
  self.assigned = false

  return self
end
function Experiment:getDefaultExperimentName()
  return "GenericExperiment"
end

function Experiment:getDefaultParamNames()
  if self.__defaultParams == nil then
    local Capture = {}
    local me = self
    function Capture:set(key, val)
      table.insert(me.__defaultParams, key)
    end
    self.__defaultParams = {}
    local res, err = pcall(function()
      me.assign({}, Capture, {})
    end)
  end
  return self.__defaultParams
end

function Experiment:requireAssignment()
  if not self.assigned then self:_assign() end
end

function Experiment:requireExposureLogging(paramName)
  if self:shouldLogExposure(paramName) then self:logExposure() end
end

function Experiment:_assign()
  self:configureLogger()
  local assigneVal = self:assign(self.assignment, self.inputs)
  self._inExperiment = assigneVal == nil or assigneVal ~= false
  self.assigned = true
end

function Experiment:setup()
  return
end

function Experiment:inExperiment()
  return self._inExperiment
end

function Experiment:addOverride(key, value)
  self.assignment:addOverride(key, value)
end

function Experiment:setOverrides(values)
  self.assignment:setOverrides(values)
  local obj = self.assignment:getOverrides()
  for k, v in pairs(obj) do self.inputs[k] = v end -----------------------------
end

function Experiment:getSalt()
  return self.salt or self.name
end

function Experiment:setSalt(value)
  self.salt = value
  if self.assignment ~= nil then self.assignment.experimentSalt = value end
end

function Experiment:getName()
  return self.name
end

function Experiment:assign(param, args)
  error "Not implemented"
end

function Experiment:getParamNames()
  error "Not implemented"
end

function Experiment:shouldFetchExperimentParameter(name)
  local experimentalParams = self:getParamNames()
  return table.indexOf(experimentalParams, name) > 0
end

function Experiment:setName(name)
  name = string.gsub(name, " ", "-")
  self.name = name
  if self.assignment ~= nil then self.assignment.experimentSalt = self:getSalt() end
end

function Experiment:__asBlob(extras)
  extras = extras or {}
  return table.merge(extras, {
    name = self:getName(),
    time = os.clock(),
    salt = self:getSalt(),
    inputs = self.inputs,
    params = self.assignment:getParams()
  })
end

function Experiment:setAutoExposureLogging(value)
  self.autoExposureLogging = value
end

function Experiment:getParams()
  self:requireAssignment()
  self:requireExposureLogging()
  return self.assignment:getParams()
end

function Experiment:get(name, def)
  self:requireAssignment()
  self:requireExposureLogging(name)
  return self.assignment:get(name, def)
end

function Experiment:toString()
  self:requireAssignment()
  self:requireExposureLogging()
  return JSON:encode(self:__asBlob())
end

function Experiment:logExposure(extras)
  if not self:inExperiment() then return end
  self.exposureLogged = true
  self:logEvent('exposure', extras)
end

function Experiment:shouldLogExposure(paramName)
  if paramName ~= nil and not self:shouldFetchExperimentParameter(paramName) then return false end
  return self.autoExposureLogging and not (self:previouslyLogged() ~= nil)
end

function Experiment:logEvent(eventType, extras)
  if not self:inExperiment() then return end
  local extraPayload = {
    event = eventType,
    extras_data = shallowcopy(extras)
  }

  self:log(self:__asBlob(extraPayload))
end

function Experiment:configureLogger()
  error "Not implemented"
end

function Experiment:log(data)
  error "Not implemented"
end

function Experiment:previouslyLogged()
  error "Not implemented"
end

local exp = Experiment:new({})


return Experiment
