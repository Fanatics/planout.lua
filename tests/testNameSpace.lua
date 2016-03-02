package.path = package.path .. ';../src/?.lua;'

local Experiment = require "experiment"
local pretty = require 'pl.pretty'

require("namespace")

EXPORT_ASSERT_TO_GLOBALS = true
require('resources.luaunit')

TestNamespace = {}
TestNamespaces = {}

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


Experiment1 = BaseExperiment:new()

function Experiment1:assign(params, args)
  params:set('test', 1)
end


Experiment2 = BaseExperiment:new()

function Experiment2:assign(params, args)
  params:set('test', 2)
end


Experiment3 = BaseExperiment:new()

function Experiment3:assign(params, args)
  params:set('test', 3)
end


BaseTestNamespace = SimpleNamespace:new()

function BaseTestNamespace:setup()
  self:setName('test')
  self:setPrimaryUnit('userid')
end

function BaseTestNamespace:setupDefaults()
  self.numSegments = 100
end

function BaseTestNamespace:getLog()
  return self._experiment:getLog()
end

function BaseTestNamespace:clearLog()
  self._experiment.globalLog = {}
end


local validateLog = function(exp, globalLog)
  assert(globalLog[1].salt == 'test-' .. exp)
end

local validateSegments = function(namespace, segmentBreakdown)
  local segCounts = {}
  for segName, seg in ipairs(namespace.segmentAllocations) do
    if segCounts[seg] == nil then segCounts[seg] = 0 end
    segCounts[seg] = segCounts[seg] + 1
  end
  for segName, segCount in pairs(segCounts) do
    assert(segCount == segmentBreakdown[segName])
  end
end

function TestNamespace:test_adds_segment()
  local TestNamespace = BaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', Experiment1, 100)
  end

  local ns = TestNamespace:new({['userid'] = 'blah'})
  assert(ns:get('test') == 1)
  assert(#ns.availableSegments == 0)
  assert(#ns.segmentAllocations == 100)
  validateLog("Experiment1", ns:getLog())
  validateSegments(ns, { ['Experiment1'] = 100 })
end

function TestNamespace:test_adds_2_segements()
  local TestNamespace = BaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', Experiment1, 50)
    self:addExperiment('Experiment2', Experiment2, 50)
  end

  local ns = TestNamespace:new({['userid'] = 'blah'})
  assert(ns:get('test') == 1)
  validateLog("Experiment1", ns:getLog())

  local ns2 = TestNamespace:new({['userid'] = 'abb'})
  assert(ns2:get('test') == 2)
  validateLog("Experiment2", ns2:getLog())

  validateSegments(ns, { ['Experiment1'] = 50, ['Experiment2'] = 50 })
end

function TestNamespace:test_removes_segment()
  local TestNamespace = BaseTestNamespace:new()
  function TestNamespace:setupDefaults()
    self.numSegments = 10
  end
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', Experiment1, 10)
    self:removeExperiment('Experiment1')
    self:addExperiment('Experiment2', Experiment2, 10)
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
  local TestNamespace = BaseTestNamespace:new()
  function TestNamespace:setupDefaults()
    self.numSegments = 10
  end
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', Experiment1, 5)
    self:addExperiment('Experiment3', Experiment3, 5)
  end

  local ns = TestNamespace:new({['userid'] = 'hi'})
  assert(ns:get("test2") == nil)
  assert(#ns:getLog() == 0)
  assert(ns:get("test") ~= nil)
  validateLog("Experiment1", ns:getLog())
end

function TestNamespace:test_can_override_namespace()
  local TestNamespace = BaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('Experiment1', Experiment1, 50)
    self:addExperiment('Experiment2', Experiment2, 50)
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

function TestNamespaces:test_respects_auto_exposer_logging_turned_off()
  local ExperimentNoExposure = BaseExperiment:new()
  function ExperimentNoExposure:assign(params, args)
    params:set('test', 1)
  end
  function ExperimentNoExposure:setup()
    self:setAutoExposureLogging(false)
    self.name = 'test_name'
  end

  local TestNamespace = BaseTestNamespace:new()
  function TestNamespace:setupExperiments()
    self:addExperiment('ExperimentNoExposure', ExperimentNoExposure, 100)
  end

  local ns = TestNamespace:new({['userid'] = 'hi'})
  ns:get("test")
  assert(#ns:getLog() == 0)
end

function TestNamespace:test_works_with_dynamic_get_parameter_names()
  -- class ExperimentParamTest extends Experiment1 {
  --
  --   assign(params, args) {
  --     let clonedArgs = Utils.shallowCopy(args);
  --     delete clonedArgs.userid;
  --     let keys = Object.keys(clonedArgs);
  --     Utils.forEach(keys, function(key) {
  --       params.set(key, 1);
  --     });
  --   }
  --
  --   getParamNames() {
  --     return ['foo', 'bar'];
  --   }
  -- };
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('ExperimentParamTest', ExperimentParamTest, 100);
  --   }
  -- };
  -- var namespace = new TestNamespace({'userid': 'hi', 'foo': 1, 'bar': 1});
  -- namespace.get('test');
  -- expect(globalLog.length).toEqual(0);
  -- namespace.get('foo');
  -- expect(globalLog.length).toEqual(1);
end

function TestNamespace:test_works_with_get_params()
  -- class SimpleExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('test', 1)
  --   }
  -- };
  -- class TestNamespace2 extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('SimpleExperiment', SimpleExperiment, 100);
  --   }
  -- };
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     return;
  --   }
  -- }
  -- var namespace = new TestNamespace({'userid': 'hi', 'foo': 1, 'bar': 1});
  -- namespace.getParams('SimpleExperiment');
  -- expect(globalLog.length).toEqual(0);
  -- var namespace2 = new TestNamespace2({'userid': 'hi', 'foo': 1, 'bar': 1});
  -- var params = namespace2.getParams('SimpleExperiment');
  -- expect(globalLog.length).toEqual(1);
  -- expect(params).toEqual({'test': 1});
end

function TestNamespace:test_not_log_exposure_if_parameter_not_in_experiment()
  -- class SimpleExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('test', 1)
  --   }
  -- };
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('SimpleExperiment', SimpleExperiment, 100);
  --   }
  -- };
  -- var namespace = new TestNamespace({'userid': 'hi', 'foo': 1, 'bar': 1});
  -- namespace.get('foobar');
  -- expect(globalLog.length).toEqual(0);
  -- expect(namespace.get('test')).toBe(1);
  -- expect(globalLog.length).toEqual(1);
end

function TestNamespace:test_works_with_experiment_setup()
  -- class SimpleExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('test', 1)
  --   }
  -- };
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('SimpleExperiment', SimpleExperiment, 100);
  --   }
  -- };
  -- var namespace = new TestNamespace({'foo': 1, 'bar': 1});
  -- ExperimentSetup.registerExperimentInput('userid', 'hi');
  -- expect(namespace.get('test')).toBe(1);
  -- expect(globalLog.length).toEqual(1);
end

function TestNamespace:test_works_as_expected()
  -- class TestNamespaces extends BaseTestNamespace {
  --   setup() {
  --     this.setName('testomg');
  --     this.setPrimaryUnit('userid');
  --   }
  --
  --   setupDefaults() {
  --     this.numSegments = 10;
  --   }
  --
  --   setupExperiments() {
  --     this.addExperiment('Experiment1', Experiment1, 6);
  --   }
  -- }
  -- var count = 0;
  -- var total = 10000;
  -- ExperimentSetup.toggleCompatibleHash(false)
  -- for (var i = 0; i < total; i++) {
  --   ExperimentSetup.registerExperimentInput('userid', i);
  --   var n = new TestNamespaces();
  --   if (n.get('test')) {
  --     count += 1;
  --   }
  -- }
  -- expect(count >= 5500 && count <= 6500).toBe(true);
end



local lu = LuaUnit.new()
os.exit( lu:runSuite() )
