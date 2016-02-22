require "lunit"

module("test_experiment_setup", lunit.testcases)

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
--
-- class Experiment1 extends BaseExperiment {
--   assign(params, args) {
--     params.set('foo', new UniformChoice({'choices': ['a', 'b'], 'unit': args.userid}));
--     params.set('paramVal', args.paramVal);
--     params.set('funcVal', args.funcVal);
--   }
-- }
--
-- class Experiment2 extends BaseExperiment {
--   assign(params, args) {
--     params.set('foobar', new UniformChoice({'choices': ['a', 'b'], 'unit': args.userid}));
--     params.set('paramVal', args.paramVal);
--     params.set('funcVal', args.funcVal);
--   }
-- }
--
-- class BaseTestNamespace extends Namespace.SimpleNamespace {
--   setup() {
--     this.setName('testThis');
--     this.setPrimaryUnit('userid');
--   }
--
--   setupDefaults() {
--     this.numSegments = 100;
--   }
--
--   setupExperiments() {
--     this.addExperiment('Experiment1', Experiment1, 50);
--     this.addExperiment('Experiment2', Experiment2, 50);
--   }
-- };

function works_with_global_inputs()
  -- var namespace = new BaseTestNamespace({'userid': 'a'});
  -- var fooVal = namespace.get('foo');
  -- var foobarVal = namespace.get('foobar');
  -- var namespace2 = new BaseTestNamespace();
  -- ExperimentSetup.registerExperimentInput('userid', 'a');
  -- expect(fooVal).toEqual(namespace2.get('foo'));
  -- expect(foobarVal).toEqual(namespace2.get('foobar'));
end

function works_with_scoped_inputs()
  var namespace = new BaseTestNamespace({'userid': 'a'});
  ExperimentSetup.registerExperimentInput('paramVal', '3', namespace.getName());
  expect(namespace.get('paramVal')).toEqual('3');

  class TestNamespace extends BaseTestNamespace {
    setup() {
      this.setName('test2');
      this.setPrimaryUnit('userid');
    }
  }

  var namespace2 = new TestNamespace();
  expect(namespace2.get('foo')).toEqual(undefined);
  expect(namespace2.get('paramVal')).toEqual(undefined);
end

function works_with_function_inputs()
  -- var namespace = new BaseTestNamespace({'userid': 'a'});
  -- var funct = function() {
  --   return '3';
  -- };
  -- ExperimentSetup.registerExperimentInput('funcVal', funct);
  -- expect(namespace.get('funcVal')).toEqual('3');
end
