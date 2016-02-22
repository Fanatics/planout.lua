require "lunit"

module("test_experiment", lunit.testcases)

-- var globalLog = [];
--
-- class BaseExperiment extends Experiment {
--   configureLogger() {
--     return;
--   }
--   log(stuff) {
--     globalLog.push(stuff);
--   }
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
-- }

-- BEFORE --
-- var validateLog;
-- var experimentTester;
-- beforeEach(function() {
--   ExperimentSetup.toggleCompatibleHash(true);
--   validateLog = function (blob, expectedFields) {
--     if (!expectedFields || !blob) { return; }
--     Object.keys(expectedFields).forEach(function(field) {
--       expect(blob[field]).not.toBe(undefined);
--       if (expectedFields[field] !== undefined) {
--         validateLog(blob[field], expectedFields[field]);
--       }
--     });
--   };
--
--   experimentTester = function (expClass, inExperiment=true) {
--     globalLog = [];
--     var e = new expClass({ 'i': 42});
--     e.setOverrides({'bar': 42});
--     var params = e.getParams();
--
--     expect(params['foo']).not.toBe(undefined);
--     expect(params['foo']).toEqual('b');
--     expect(params['bar']).toEqual(42);
--
--     if (inExperiment) {
--       expect(globalLog.length).toEqual(1);
--       validateLog(globalLog[0], {
--         'inputs': { 'i': null },
--         'params': { 'foo': null, 'bar': null}
--       });
--     } else {
--       expect(globalLog.length).toEqual(0);
--     }
--
--     expect(e.inExperiment(), inExperiment);
--   };
-- });

function work_basic_experiments()
  -- class TestVanillaExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('foo', new UniformChoice({'choices': ['a', 'b'], 'unit': args.i}));
  --   }
  -- }
  -- experimentTester(TestVanillaExperiment);
end

function can_disable_experiment()
  -- class TestVanillaExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('foo', new UniformChoice({'choices': ['a', 'b'], 'unit': args.i}));
  --     return false;
  --   }
  -- }
  -- experimentTester(TestVanillaExperiment, false);
end

function only_assign_once()
  -- class TestSingleAssignment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('foo', new UniformChoice({'choices': ['a', 'b'], 'unit': args.i}));
  --     var counter = args.counter;
  --     if (!counter.count) { counter.count = 0; }
  --     counter.count = counter.count + 1;
  --   }
  -- }
  --
  -- var assignment_count = {'count': 0};
  -- var e = new TestSingleAssignment({'i': 10, 'counter': assignment_count});
  -- expect(assignment_count.count).toEqual(0);
  -- e.get('foo');
  -- expect(assignment_count.count).toEqual(1);
  -- e.get('foo');
  -- expect(assignment_count.count).toEqual(1);
end

function can_pull_experiment_parameters()
  -- class TestAssignmentRetrieval extends BaseExperiment {
  --     assign(params, args) {
  --       params.set('foo', 'heya');
  --       if (false) {
  --         params.set('boo', 'hey');
  --       }
  --     }
  --   }
  --
  --   class TestAssignmentRetrieval2 extends BaseExperiment {
  --     assign(params, args) {
  --       return;
  --     }
  --   }
  --
  --   var e = new TestAssignmentRetrieval();
  --   expect(e.getParamNames()).toEqual(['foo', 'boo']);
  --   var f = new TestAssignmentRetrieval2();
  --   expect(f.getParamNames()).toEqual([]);
end

function work_with_interpreted_experiments()
  -- class TestInterpretedExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     var compiled =
  --       {"op":"seq",
  --        "seq": [
  --         {"op":"set",
  --          "var":"foo",
  --          "value":{
  --            "choices":["a","b"],
  --            "op":"uniformChoice",
  --            "unit": {"op": "get", "var": "i"}
  --            }
  --         },
  --         {"op":"set",
  --          "var":"bar",
  --          "value": 41
  --         }
  --       ]};
  --     var proc = new Interpreter(compiled, this.getSalt(), args, params);
  --     var par = proc.getParams();
  --     Object.keys(par).forEach(function(param) {
  --       params.set(param, par[param]);
  --     });
  --   }
  -- };
  -- experimentTester(TestInterpretedExperiment);
end

function not_log_exposure_if_parameter_not_in_experiment()
  -- class TestVanillaExperiment extends BaseExperiment {
  --   assign(params, args) {
  --     params.set('foo', new UniformChoice({'choices': ['a', 'b'], 'unit': args.i}));
  --   }
  -- }
  -- globalLog = [];
  -- var e = new TestVanillaExperiment({ 'i': 42});
  -- e.get('fobz');
  -- expect(globalLog.length).toEqual(0);
end
