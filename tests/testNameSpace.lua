package.path = package.path .. ';../src/?.lua;'

local Experiment = require "experiment"
local pretty = require 'pl.pretty'

require("namespace")

EXPORT_ASSERT_TO_GLOBALS = true
require('resources.luaunit')

TestNamespace = {}
TestNamespace2 = {}

local NSBaseExperiment = Experiment:new()

function NSBaseExperiment:configureLogger()
  if self.globalLog == nil then self.globalLog = {} end
  return nil
end

function NSBaseExperiment:log(stuff)
  table.insert(self.globalLog, stuff)
end

function NSBaseExperiment:previouslyLogged()
  return nil
end

function NSBaseExperiment:getLog()
  return self.globalLog
end

function NSBaseExperiment:getLogLength()
  return #self.globalLog
end

function NSBaseExperiment:getParamNames()
  return self:getDefaultParamNames()
end

function NSBaseExperiment:setup()
  self.name = 'test_name'
end


local NSExperiment1 = NSBaseExperiment:new()

function NSExperiment1:assign(params, args)
  params:set('test', 1)
end


local NSExperiment2 = NSBaseExperiment:new()

function NSExperiment2:assign(params, args)
  params:set('test', 2)
end


local NSExperiment3 = NSBaseExperiment:new()

function NSExperiment3:assign(params, args)
  params:set('test', 3)
end


local NSBaseTestNamespace = SimpleNamespace:new()

function NSBaseTestNamespace:setup()
  self:setName('test')
  self:setPrimaryUnit('userid')
end

function NSBaseTestNamespace:setupDefaults()
  self.numSegments = 100
end

function NSBaseTestNamespace:getLog()
  if(self._experiment ~= nil) then return self._experiment:getLog()
  else return {} end
end

function NSBaseTestNamespace:clearLog()
  self._experiment.globalLog = {}
end


local validateLog = function(exp, globalLog)
  assert(globalLog[1].salt == 'test-' .. exp)
end

local validateSegments = function(namespace, segmentBreakdown)
  local segCounts = {}
  for segName, seg in pairs(namespace.segmentAllocations) do
    if segCounts[seg] == nil then segCounts[seg] = 0 end
    segCounts[seg] = segCounts[seg] + 1
  end
  for segName, segCount in pairs(segCounts) do
    assert(segCount == segmentBreakdown[segName])
  end
end

function TestNamespace:test_adds_segment()
  local SetupNamespace = NSBaseTestNamespace:new()
  function SetupNamespace:setupExperiments()
    self:addExperiment('Experiment1', NSExperiment1, 100)
  end

  local ns = SetupNamespace:new({['userid'] = 'blah'})
  assert(ns:get('test') == 1)
  assert(table.filledLength(ns.availableSegments) == 0)
  assert(table.filledLength(ns.segmentAllocations) == 100)
  validateLog("Experiment1", ns:getLog())
  validateSegments(ns, { ['Experiment1'] = 100 })
end

function TestNamespace:test_adds_2_segements()
  local SetupNamespace = NSBaseTestNamespace:new()
  function SetupNamespace:setupExperiments()
    self:addExperiment('Experiment1', NSExperiment1, 50)
    self:addExperiment('Experiment2', NSExperiment2, 50)
  end

  local ns = SetupNamespace:new({['userid'] = 'blah'})
  assert(ns:get('test') == 1)
  validateLog("Experiment1", ns:getLog())

  local ns2 = SetupNamespace:new({['userid'] = 'abb'})
  local testValue = ns2:get('test')
  assert(testValue == 2)
  validateLog("Experiment2", ns2:getLog())

  validateSegments(ns, { ['Experiment1'] = 50, ['Experiment2'] = 50 })
end

function TestNamespace:test_removes_segment()
  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupDefaults()
    self.numSegments = 10
  end
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', NSExperiment1, 10)
    self:removeExperiment('Experiment1')
    self:addExperiment('Experiment2', NSExperiment2, 10)
  end

  local ns
  local str = 'bla'
  local count = 0
  while count < 100 do
    str = str .. 'h'
    ns = TestNamespace:new({['userid'] = str})
    assert(ns:get('test') == 2)
    validateLog("Experiment2", ns:getLog())
    count = count + 1
  end

  local ns2 = TestNamespace:new({['userid'] = str})
  assert(ns2:get('test') == 2)
  validateSegments(ns2, { ['Experiment2'] = 10 })
end

function TestNamespace:test_expose_only_when_potential_member()
  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupDefaults()
    self.numSegments = 10
  end
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', NSExperiment1, 5)
    self:addExperiment('Experiment3', NSExperiment3, 5)
  end

  local ns = TestNamespace:new({['userid'] = 'hi'})
  assert(ns:get("test2") == nil)
  assert(#ns:getLog() == 0)
  assert(ns:get("test") ~= nil)
  validateLog("Experiment1", ns:getLog())
end

function TestNamespace:test_can_override_namespace()
  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', NSExperiment1, 50)
    self:addExperiment('Experiment2', NSExperiment2, 50)
  end
  function TestNamespace:allowedOverride() return true end
  function TestNamespace:getOverrides()
    return {
      ['test'] = {
        ['experimentName'] = 'Experiment1',
        ['value'] = 'overridden'
      },
      ['test2'] = {
        ['experimentName'] = 'Experiment3',
        ['value'] = 'overridden2'
      }
    }
  end
  local ns = TestNamespace:new({['userid'] = 'hi'})
  assert(ns:get('test') == 'overridden')
  validateLog("Experiment1", ns:getLog())
  ns:clearLog()
  assert(ns:get('test') == 'overridden')
  validateLog("Experiment1", ns:getLog())
end

function TestNamespace:test_respects_auto_exposer_logging_turned_off()
  local ExperimentNoExposure = NSBaseExperiment:new()
  function ExperimentNoExposure:assign(params, args)
    params:set('test', 1)
  end
  function ExperimentNoExposure:setup()
    self:setAutoExposureLogging(false)
    self.name = 'test_name'
  end

  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('ExperimentNoExposure', ExperimentNoExposure, 100)
  end

  local ns = TestNamespace:new({['userid'] = 'hi'})
  ns:get("test")
  assert(#ns:getLog() == 0)
end

function TestNamespace:test_works_with_dynamic_get_parameter_names()
  local ExperimentParamTest = NSExperiment1:new()
  function ExperimentParamTest:assign(params, args)
    local clonedArgs = shallowcopy(args)
    clonedArgs.userid = nil
    for k, v in pairs(clonedArgs) do
      params:set(k, 1)
    end
  end
  function ExperimentParamTest:getParamNames() return {'foo', 'bar'} end

  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('ExperimentParamTest', ExperimentParamTest, 100)
  end

  local ns = TestNamespace:new({['userid'] = 'hi', ['foo'] = 1, ['bar'] = 1})
  ns:get('test')
  assert(#ns:getLog() == 0)
  ns:get('foo')
  assert(#ns:getLog() == 1)
end

function TestNamespace:test_works_with_get_params()
  local SimpleExperiment = NSBaseExperiment:new()
  function SimpleExperiment:assign(params,args)
    params:set('test', 1)
  end

  local TestNamespace2 = NSBaseTestNamespace:new()
  function TestNamespace2:setupExperiments()
    self:addExperiment('SimpleExperiment', SimpleExperiment, 100)
  end

  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    return nil
  end

  local ns = TestNamespace:new({['userid'] = 'hi', ['foo'] = 1, ['bar'] = 1})
  ns:getParams('SimpleExperiment')
  assert(#ns:getLog() == 0)

  local ns2 = TestNamespace2:new({['userid'] = 'hi', ['foo'] = 1, ['bar'] = 1})
  local params = ns2:getParams('SimpleExperiment')
  assert(#ns2:getLog() == 1)
  assert(params['test'] == 1)
end

function TestNamespace:test_not_log_exposure_if_parameter_not_in_experiment()
  local SimpleExperiment = NSBaseExperiment:new()
  function SimpleExperiment: assign(params,args)
    params:set('test', 1)
  end

  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('SimpleExperiment', SimpleExperiment, 100)
  end

  local ns = TestNamespace:new({['userid'] = 'hi', ['foo'] = 1, ['bar'] = 1})
  ns:get('foobar')
  assert(#ns:getLog() == 0)
  assert(ns:get("test") == 1)
  assert(#ns:getLog() == 1)
end

function TestNamespace:test_works_with_experiment_setup()
  local SimpleExperiment = NSBaseExperiment:new()
  function SimpleExperiment: assign(params,args)
    params:set('test', 1)
  end

  local TestNamespace = NSBaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('SimpleExperiment', SimpleExperiment, 100)
  end

  local ns = TestNamespace:new({['foo'] = 1, ['bar'] = 1})
  registerExperimentInput('userid', 'hi')

  assert(ns:get("test") == 1)
  assert(#ns:getLog() == 1)
end

function TestNamespace:test_works_as_expected()
  local TestNamespaces = NSBaseTestNamespace:new()
  function TestNamespaces:setup()
    self:setName('testomg')
    self:setPrimaryUnit('userid')
  end
  function TestNamespaces:setupDefaults()
    self.numSegments = 10
  end
  function TestNamespaces:setupExperiments()
    self:addExperiment('Experiment1', NSExperiment1, 6)
  end

  local count = 0
  local total = 10000
  local index = 0
  while index < total do
    registerExperimentInput('userid', index)
    local ns = TestNamespaces:new({})
    if ns:get('test') ~= nil then count = count + 1 end
    index = index + 1
  end
  assert(count >= 5500 and count <= 6500)
end
