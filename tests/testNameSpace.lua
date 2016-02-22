require "lunit"

module("test_namespace", lunit.testcases)

-- class BaseExperiment extends Experiment {
--   configureLogger() {
--     return;
--   }
--
--   log(stuff) {
--     globalLog.push(stuff);
--   }
--
--   previouslyLogged() {
--     return;
--   }
--
--   getParamNames() {
--     return this.getDefaultParamNames();
--   }
--   setup() {
--     this.name = 'test_name';
--   }
-- };
--
-- var globalLog = [];
-- class Experiment1 extends BaseExperiment {
--   assign(params, args) {
--     params.set('test', 1)
--   }
-- }
--
-- class Experiment2 extends BaseExperiment {
--
--   assign(params, args) {
--     params.set('test', 2)
--   }
-- }
--
-- class Experiment3 extends BaseExperiment {
--   assign(params, args) {
--     params.set("test2", 3)
--   }
-- }
--
-- class BaseTestNamespace extends Namespace.SimpleNamespace {
--   setup() {
--     this.setName('test');
--     this.setPrimaryUnit('userid');
--   }
--
--   setupDefaults() {
--     this.numSegments = 100;
--   }
-- };
-- BEFORE --
-- var validateLog;
-- var validateSegments;
-- beforeEach(function() {
--   ExperimentSetup.toggleCompatibleHash(true);
--   validateLog = function(exp) {
--     expect(globalLog[0].salt).toEqual(`test-${exp}`)
--   }
--
--   validateSegments = function(namespace, segmentBreakdown) {
--     var segments = Object.keys(namespace.segmentAllocations);
--     var segCounts = {};
--     for (var i = 0; i < segments.length; i++) {
--       var seg = namespace.segmentAllocations[segments[i]];
--       if (!segCounts[seg]) {
--         segCounts[seg] = 1;
--       } else {
--         segCounts[seg] += 1;
--       }
--     }
--     expect(segCounts).toEqual(segmentBreakdown);
--   }
-- });

-- AFTER --
-- afterEach(function() {
--   globalLog = [];
-- });

function adds_segment()
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('Experiment1', Experiment1, 100);
  --   }
  -- };
  -- var namespace = new TestNamespace({'userid': 'blah'});
  -- expect(namespace.get('test')).toEqual(1);
  -- expect(namespace.availableSegments.length).toEqual(0);
  -- expect(Object.keys(namespace.segmentAllocations).length).toEqual(100);
  -- validateLog("Experiment1");
  -- validateSegments(namespace, { Experiment1: 100 });
end

function adds_2_segements()
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('Experiment1', Experiment1, 50);
  --     this.addExperiment('Experiment2', Experiment2, 50);
  --   }
  -- };
  --
  -- var namespace = new TestNamespace({'userid': 'blah'});
  -- expect(namespace.get('test')).toEqual(1);
  -- validateLog("Experiment1");
  -- globalLog = [];
  -- var namespace2 = new TestNamespace({'userid': 'abb'});
  -- expect(namespace2.get('test')).toEqual(2);
  -- validateLog("Experiment2");
  -- var segValidation = { Experiment1: 50, Experiment2: 50};
  -- validateSegments(namespace, segValidation);
end

function removes_segment()
  -- class TestNamespace extends BaseTestNamespace {
  --   setupDefaults() {
  --     this.numSegments = 10;
  --   }
  --
  --   setupExperiments() {
  --     this.addExperiment('Experiment1', Experiment1, 10);
  --     this.removeExperiment('Experiment1');
  --     this.addExperiment('Experiment2', Experiment2, 10);
  --   }
  -- };
  --
  -- var str = "bla";
  -- for(var i = 0; i < 100; i++) {
  --   str += "h";
  --   var namespace = new TestNamespace({'userid': str});
  --   expect(namespace.get('test')).toEqual(2);
  --   validateLog("Experiment2");
  -- }
  -- var namespace = new TestNamespace({'userid': str});
  -- validateSegments(namespace, { Experiment2: 10 });
end

function expose_only_when_potential_member()
  -- class TestNamespace extends BaseTestNamespace {
  --   setupDefaults() {
  --     this.numSegments = 10;
  --   }
  --
  --   setupExperiments() {
  --     this.addExperiment('Experiment1', Experiment1, 5);
  --     this.addExperiment('Experiment3', Experiment3, 5);
  --   }
  -- }
  --
  -- var namespace = new TestNamespace({'userid': 'hi'});
  -- expect(namespace.get('test2')).toEqual(null);
  -- expect(globalLog.length).toEqual(0);
  -- expect(namespace.get('test'));
  -- validateLog("Experiment1");
end

function can_override_namespace()
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('Experiment1', Experiment1, 50);
  --     this.addExperiment('Experiment3', Experiment3, 50);
  --   }
  --
  --   allowedOverride() {
  --     return true;
  --   }
  --
  --   getOverrides() {
  --     return {
  --       'test': {
  --         'experimentName': 'Experiment1',
  --         'value': 'overridden'
  --       },
  --       'test2': {
  --         'experimentName': 'Experiment3',
  --         'value': 'overridden2'
  --       }
  --     };
  --   }
  -- }
  --
  -- var namespace = new TestNamespace({'userid': 'hi'});
  -- expect(namespace.get('test')).toEqual('overridden');
  -- validateLog('Experiment1');
  -- globalLog = [];
  -- expect(namespace.get('test2')).toEqual('overridden2');
  -- validateLog('Experiment3');
end

function respects_auto_exposer_logging_turned_off
  -- class ExperimentNoExposure extends BaseExperiment {
  --   setup() {
  --     this.setAutoExposureLogging(false);
  --     this.name = 'test_name';
  --   }
  --
  --   assign(params, args) {
  --     params.set('test', 1)
  --   }
  -- };
  -- class TestNamespace extends BaseTestNamespace {
  --   setupExperiments() {
  --     this.addExperiment('ExperimentNoExposure', ExperimentNoExposure, 100);
  --   }
  -- };
  --
  -- var namespace = new TestNamespace({'userid': 'hi'});
  -- namespace.get('test');
  -- expect(globalLog.length).toEqual(0);
end

function works_with_dynamic_get_parameter_names
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

function works_with_get_params()
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

function not_log_exposure_if_parameter_not_in_experiment()
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

function works_with_experiment_setup()
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

function works_as_expected()
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
