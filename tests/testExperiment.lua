package.path = package.path .. ";../src/?.lua;"
require("ops.random")
local Experiment = require "experiment"
local Interpreter = require "interpreter"

local pretty = require 'pl.pretty'

EXPORT_ASSERT_TO_GLOBALS = true
require("resources.luaunit")

TestExperiment = {}
TestExperiments = {}

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

local validateLog = function(blob, expectedFields)
  if blob == nil or expectedFields == nil then return end
  for k, v in pairs(expectedFields) do
    assert(blob[k] ~= nil)
    if(type(v) == "table") then validateLog (blob[k], v) end
  end
end

local experimentTester = function(expClass, inExperiment)
  local e = expClass:new({['i'] = 42})
  e:setOverrides({['bar'] = 42})
  local params = e:getParams()

  assert(params['foo'] ~= nil)
  --assert(params['foo'] == 'b')
  assert(params['bar'] == 42)

  if inExperiment then
    assert(e:getLogLength() == 1)
    validateLog(e:previouslyLogged(), {
      ['inputs'] = { ['i'] = true },
      ['params'] = { ['foo'] = true, ['bar'] = true}
    });
  else assert(e:getLogLength() == 0) end

  assert(e:inExperiment() == inExperiment)
end

function TestExperiment:test_work_basic_experiments()
  local TestVanillaExperiment = BaseExperiment:new()

  function TestVanillaExperiment:assign(params, args)
    params:set('foo', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['i']}))
  end

  experimentTester(TestVanillaExperiment, true)
end

function TestExperiment:test_can_disable_experiment()
  local TestVanillaExperiment = BaseExperiment:new()

  function TestVanillaExperiment:assign(params, args)
    params:set('foo', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['i']}))
    return false
  end

  experimentTester(TestVanillaExperiment, false)
end

function TestExperiment:test_only_assign_once()
  local TestSingleAssignment = BaseExperiment:new()

  function TestSingleAssignment:assign(params, args)
    params:set('foo', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['i']}))
    if args['counter'] ~= nil then
      local counter = args['counter']
      if not counter.count then counter.count = 0 end
      counter.count = counter.count + 1
    end
  end

  local assignment_count = {['count'] = 0};
  local e = TestSingleAssignment:new({['i'] = 10, ['counter'] = assignment_count});
  assert(assignment_count['count'] == 0)
  e:get('foo')
  assert(assignment_count['count'] == 1)
  e:get('foo')
  assert(assignment_count['count'] == 1)
end

function TestExperiment:test_can_pull_experiment_parameters()
  local TestAssignmentRetrieval = BaseExperiment:new()

  function TestAssignmentRetrieval:assign(params, args)
    params:set('foo', 'heya')
    params:set('boo', 'yeah')
  end

  local TestAssignmentRetrieval2 = BaseExperiment:new()

  function TestAssignmentRetrieval2:assign(params, args)
    return nil
  end

  local e = TestAssignmentRetrieval:new()
  local params = e:getParamNames()
  assert(#params == 2)
  assert(table.indexOf(params, 'foo') == 1)
  assert(table.indexOf(params, 'boo') == 2)
  local f = TestAssignmentRetrieval2:new()
  assert(#f:getParamNames() == 0)
end

function TestExperiment:test_work_with_interpreted_experiments()
  local TestInterpretedExperiment = BaseExperiment:new()

  function TestInterpretedExperiment:assign(params, args)
    local compiled = {
      ['op'] = 'seq',
      ['seq'] = {
        {
          ['op'] = 'set',
          ['var'] = 'foo',
          ['value'] = {
            ['choices'] = {'a','b'},
            ['op'] = 'uniformChoice',
            ['unit'] = {['op'] = 'get', ['var'] = 'i'}
          }
        },
        {
          ['op'] = 'set',
          ['var'] = 'bar',
          ['value'] = 41
        }
      }
    }
    local proc = Interpreter:new(compiled, self:getSalt(), args, params)
    local par = proc:getParams()
    for k, v in pairs(par) do params:set(k, v) end
  end

  experimentTester(TestInterpretedExperiment, true)
end

function TestExperiment:test_not_log_exposure_if_parameter_not_in_experiment()
  local TestVanillaExperiment = BaseExperiment:new()

  function TestVanillaExperiment:assign(params, args)
    params:set('foo', UniformChoice:new({['choices'] = {'a','b'}, ['unit'] = args['i']}))
    return false
  end

  local e = TestVanillaExperiment:new({['i'] = 42})
  e:get('fobz')
  assert(e:getLogLength() == 0)
end



local lu = LuaUnit.new()
os.exit( lu:runSuite() )
