require("lib.utils")
require("ops.random")
require("experimentSetup")
local pretty = require 'pl.pretty'

local Experiment = require "experiment"
local Assignment = require "assignment"

DefaultExperiment = Experiment:new()

function DefaultExperiment:configureLogger()
  return
end

function DefaultExperiment:setup()
  self.name = 'test_name'
end

function DefaultExperiment:log(data)
  return
end

function DefaultExperiment:getParamNames()
  return self:getDefaultParamNames()
end

function DefaultExperiment:previouslyLogged()
  return true
end

function DefaultExperiment:assign(params, args)
  return
end


Namespace = {}

function Namespace:new(args)
  return _new_(self, {}):init(args)
end

function Namespace:init(args) return self end

function Namespace:addExperiment(name, obj, segments)
  error "addExperiment Not implemented"
end

function Namespace:removeExperiment(name)
  error "removeExperiment Not implemented"
end

function Namespace:setAutoExposureLogging(value)
  error "setAutoExposureLogging Not implemented"
end

function Namespace:inExperiment()
  error "inExperiment Not implemented"
end

function Namespace:get(name, defaultVal)
  error "get Not implemented"
end

function Namespace:logExposure(extras)
  error "logExposure Not implemented"
end

function Namespace:logEvent(eventType, extras)
  error "logEvent Not implemented"
end

function Namespace:requireExperiment()
  if not self._experiment then
    self:_assignExperiment()
  end
end

function Namespace:requireDefaultExperiment()
  if not this._defaultExperiment then
    self:_assignDefaultExperiment()
  end
end


SimpleNamespace = Namespace:new()

function SimpleNamespace:init(args)
  self.name = self:getDefaultNamespaceName()
  self.inputs = args or {}
  self.numSegments = 15
  self.segmentAllocations = range(self.numSegments)
  self.currentExperiments = {}

  self._experiment = nil
  self._defaultExperiment = nil
  self.defaultExperimentClass = DefaultExperiment
  self._inExperiment = false

  self:setupDefaults();
  self:setup();
  self.availableSegments = range(self.numSegments);

  self:setupExperiments();
  return self
end

function SimpleNamespace:setupDefaults()
  return
end

function SimpleNamespace:setup()
  --error "setup Not implemented"
end

function SimpleNamespace:setupExperiments()
  --error "setupExperiments Not implemented"
end

function SimpleNamespace:getPrimaryUnit()
  return self._primaryUnit
end

function SimpleNamespace:allowedOverride()
  return false
end

function SimpleNamespace:getOverrides()
  return {}
end

function SimpleNamespace:setPrimaryUnit(value)
  self._primaryUnit = value
end

function SimpleNamespace:addExperiment(name, expObject, segments)
  local numberAvailable = #self.availableSegments;

  if numberAvailable < segments or self.currentExperiments[name] ~= nil
  then return false end

  local a = Assignment:new(self.name);
  a:set('sampled_segments', Sample:new({
    ['choices'] = self.availableSegments,
    ['draws'] = segments,
    ['unit'] = name
  }))
  local sample = a:get('sampled_segments')

  --for(var i = 0; i < sample.length; i++) {
  for i, v in ipairs(sample) do
    self.segmentAllocations[v] = name
    local currentIndex = table.indexOf(self.availableSegments, v)
    table.remove(self.availableSegments, currentIndex)
  end

  self.currentExperiments[name] = expObject
end

function SimpleNamespace:removeExperiment(name)
  if self.currentExperiments[name] == nil then return false end
  local currentIndex = table.indexOf(self.segmentAllocations, name)
  while currentIndex ~= -1 do
    self.segmentAllocations[currentIndex] = currentIndex
    table.insert(self.availableSegments, currentIndex)
    self.currentExperiments[name] = nil
    currentIndex = table.indexOf(self.segmentAllocations, name)
  end

  return true
end

function SimpleNamespace:getSegment()
  local a = Assignment:new(self.name)
  local segment = RandomInteger:new({
    ['min'] = 0,
    ['max'] = self.numSegments - 1,
    ['unit'] = self.inputs[self:getPrimaryUnit()]
  })
  a:set('segment', segment);
  return a:get('segment');
end

function SimpleNamespace:getDefaultNamespaceName()
  return "GenericNamespace"
end

function SimpleNamespace:_assignExperiment()
  self.inputs = setmetatable(self.inputs, getExperimentInputs(self:getName()))
  local segment = self:getSegment()

  if type(self.segmentAllocations[segment]) == "string" then
    self:_assignExperimentObject(self.segmentAllocations[segment])
  end
end

function SimpleNamespace:_assignExperimentObject(experimentName)
  local experiment = self.currentExperiments[experimentName]:new(self.inputs)
  experiment:setName(self:getName() .. "-" .. experimentName)
  experiment:setSalt(self:getName() .. "-" .. experimentName)
  self._experiment = experiment
  self._inExperiment = experiment:inExperiment()
  if self._inExperiment then self:_assignDefaultExperiment() end
end

function SimpleNamespace:_assignDefaultExperiment()
  self._defaultExperiment = self.defaultExperimentClass:new(self.inputs);
end



function SimpleNamespace:getName()
  return self.name;
end

function SimpleNamespace:setName(name)
  self.name = name;
end
