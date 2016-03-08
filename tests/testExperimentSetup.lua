package.path = package.path .. ";../src/?.lua;"
require('experimentSetup')
require('namespace')
local Experiment = require "experiment"

local pretty = require 'pl.pretty'

EXPORT_ASSERT_TO_GLOBALS = true
require("resources.luaunit")

TestExperimentSetup = {}
TestExperimentSetups = {}

BaseExperiment = Experiment:new()

function BaseExperiment:configureLogger()
  if self.globalLog == nil then self.globalLog = {} end
  return nil
end

function BaseExperiment:log(stuff)
  table.insert(self.globalLog, stuff)
end

function BaseExperiment:previouslyLogged()
  return nil
end

function BaseExperiment:getLog()
  return self.globalLog
end

function BaseExperiment:getLogLength()
  return #self.globalLog
end

function BaseExperiment:getParamNames()
  return self:getDefaultParamNames()
end

function BaseExperiment:setup()
  self.name = 'test_name'
end

local Experiment1 = BaseExperiment:new()

function Experiment1:assign(params, args)
  params:set('foo', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['userid']}))
  params:set('paramVal', args.paramVal)
  params:set('funcVal', args.funcVal)
end

local Experiment2 = BaseExperiment:new()

function Experiment2:assign(params, args)
  params:set('foobar', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['userid']}))
  params:set('paramVal', args.paramVal)
  params:set('funcVal', args.funcVal)
end

BaseTestNamespace = SimpleNamespace:new()

function BaseTestNamespace:setup()
  self:setName('testThis')
  self:setPrimaryUnit('userid')
end

function BaseTestNamespace:setupDefaults()
  self.numSegments = 100
end

function BaseTestNamespace:setupExperiments()
  self:addExperiment('Experiment1', Experiment1, 50);
  self:addExperiment('Experiment2', Experiment2, 50);
end

function TestExperimentSetup:test_works_with_global_inputs()
  local namespace = BaseTestNamespace:new({['userid'] = 'a'})
  local fooVal = namespace:get('foo')
  local foobarVal = namespace:get('foobar')
  local namespace2 = BaseTestNamespace:new({['userid'] = 'a'})
  registerExperimentInput('userid', 'a')
  assert(namespace2:get('foo') == fooVal)
  assert(namespace2:get('foobar') == foobarVal)
end

function TestExperimentSetups:test_works_with_scoped_inputs()
  local namespace = BaseTestNamespace:new({['userid'] = 'a'})
  registerExperimentInput('paramVal', '3', namespace:getName())

  assert(namespace:get('paramVal') == '3')

  local TestNamespace = BaseTestNamespace:new()

  function TestNamespace:setup()
    self:setName('test2')
    self:setPrimaryUnit('userid')
  end

  local namespace2 = TestNamespace:new({['userid'] = 'a'})
  assert(namespace2:get('foo') == nil)
  assert(namespace2:get('paramVal') == nil)
end

function TestExperimentSetup:test_works_with_function_inputs()
  local namespace = BaseTestNamespace:new({['userid'] = 'a'})
  registerExperimentInput('funcVal', function() return '3' end)
  assert(namespace:get('funcVal') == '3')
end
