package.path = package.path .. ";../src/?.lua;"
require('experimentSetup')
require('namespace')
local Experiment = require "experiment"

local pretty = require 'pl.pretty'

EXPORT_ASSERT_TO_GLOBALS = true
require("resources.luaunit")

TestExperimentSetup = {}

local SetupBaseExperiment = Experiment:new()

function SetupBaseExperiment:configureLogger()
  if self.globalLog == nil then self.globalLog = {} end
  return nil
end

function SetupBaseExperiment:log(stuff)
  table.insert(self.globalLog, stuff)
end

function SetupBaseExperiment:previouslyLogged()
  return nil
end

function SetupBaseExperiment:getLog()
  return self.globalLog
end

function SetupBaseExperiment:getLogLength()
  return #self.globalLog
end

function SetupBaseExperiment:getParamNames()
  return self:getDefaultParamNames()
end

function SetupBaseExperiment:setup()
  self.name = 'test_name'
end

local SetupExperiment1 = SetupBaseExperiment:new()

function SetupExperiment1:assign(params, args)
  params:set('foo', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['userid']}))
  params:set('paramVal', args.paramVal)
  params:set('funcVal', args.funcVal)
end

local SetupExperiment2 = SetupBaseExperiment:new()

function SetupExperiment2:assign(params, args)
  params:set('foobar', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['userid']}))
  params:set('paramVal', args.paramVal)
  params:set('funcVal', args.funcVal)
end

local SetupBaseTestNamespace = SimpleNamespace:new()

function SetupBaseTestNamespace:setup()
  self:setName('testThis')
  self:setPrimaryUnit('userid')
end

function SetupBaseTestNamespace:setupDefaults()
  self.numSegments = 100
end

function SetupBaseTestNamespace:setupExperiments()
  self:addExperiment('Experiment1', SetupExperiment1, 50);
  self:addExperiment('Experiment2', SetupExperiment2, 50);
end

function TestExperimentSetup:test_works_with_global_inputs()
  local namespace = SetupBaseTestNamespace:new({['userid'] = 'a'})
  local fooVal = namespace:get('foo')
  local foobarVal = namespace:get('foobar')
  local namespace2 = SetupBaseTestNamespace:new({['userid'] = 'a'})
  registerExperimentInput('userid', 'a')
  assert(namespace2:get('foo') == fooVal)
  assert(namespace2:get('foobar') == foobarVal)

  clearExperimentInput('userid')
end

function TestExperimentSetup:test_works_with_scoped_inputs()
  local namespace = SetupBaseTestNamespace:new({['userid'] = 'a'})
  registerExperimentInput('paramVal', '3', namespace:getName())

  assert(namespace:get('paramVal') == '3')

  local SetupTestNamespace = SetupBaseTestNamespace:new()

  function SetupTestNamespace:setup()
    self:setName('test2')
    self:setPrimaryUnit('userid')
  end

  local namespace2 = SetupTestNamespace:new({['userid'] = 'a'})
  assert(namespace2:get('foo') == nil)
  assert(namespace2:get('paramVal') == nil)
end

function TestExperimentSetup:test_works_with_function_inputs()
  local namespace = SetupBaseTestNamespace:new({['userid'] = 'a'})
  registerExperimentInput('funcVal', function() return '3' end)
  assert(namespace:get('funcVal') == '3')
end
