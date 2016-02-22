require "lunit"

module("test_random_ops", lunit.testcases)

-- function assertProp(observedP, expectedP, N) {
--   var se = z * Math.sqrt(expectedP * (1 - expectedP) / N);
--   expect(Math.abs(observedP - expectedP) <= se).toBe(true);
-- }
--
-- function sum(obj) {
--   return obj.reduce(function(totalSum, cur) {
--     return totalSum + cur;
--   }, 0);
-- }
--
-- function valueMassToDensity(valueMass) {
--   var values = valueMass.map(function(val) { return Object.keys(val)[0]; });
--   var ns     = valueMass.map(function(val) { return val[Object.keys(val)[0]]});
--   var ns_sum = parseFloat(sum(ns));
--   ns         = ns.map(function(val) {
--     return val / ns_sum;
--   });
--   var ret = {};
--   for (var i = 0; i < values.length; i++) {
--     ret[values[i]] = ns[i];
--   }
--   return ret;
-- }
--
-- function Counter(l) {
--   var ret = {}
--   l.forEach(function(el) {
--     if (ret[el]) {
--       ret[el] += 1;
--     } else {
--       ret[el] = 1;
--     }
--   });
--   return ret;
-- }
--
-- function assertProbs(xs, valueDensity, N) {
--   var hist = Counter(xs);
--   Object.keys(hist).forEach(function(el) {
--     assertProp(hist[el] / N, valueDensity[el], N);
--   });
-- }
--
-- function distributionTester(xs, valueMass, N=10000) {
--   var valueDensity = valueMassToDensity(valueMass);
--
--   assertProbs(xs, valueDensity, parseFloat(N));
-- }
-- BEFORE --
-- beforeEach(() => {
--   ExperimentSetup.toggleCompatibleHash(true);
-- });

function salts_correctly()
  var i = 20;
  var a = new Assignment("assign_salt_a");

  a.set('x', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i}));
  a.set('y', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i}));
  expect(a.get('x')).not.toEqual(a.get('y'));

  a.set('z', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i, 'salt': 'x'}));
  expect(a.get('x')).toEqual(a.get('z'));

  var b = new Assignment('assign_salt_b');
  b.set('x', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i}));
  expect(a.get('x')).not.toEqual(b.get('x'));

  a.set('f', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i, 'full_salt':'fs'}));
  b.set('f', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i, 'full_salt':'fs'}));
  expect(a.get('f')).toEqual(b.get('f'));

  a.set('f', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i, 'full_salt':'fs2'}));
  b.set('f', new Random.RandomInteger({ 'min': 0, 'max': 100000, 'unit': i, 'full_salt':'fs2'}));
  expect(a.get('f')).toEqual(b.get('f'));
end

function works_for_bernoulli_trials()
  -- var N = 10000;
  -- function bernoulli(p) {
  --   var xs = [];
  --   for (var i = 0; i < N; i++) {
  --     var a = new Assignment(p);
  --     a.set('x', new Random.BernoulliTrial({ 'p': p, 'unit': i }));
  --     xs[i] = a.get('x');
  --   }
  --   return xs;
  -- }
  --
  -- ExperimentSetup.toggleCompatibleHash(true);
  -- distributionTester(bernoulli(0.0), [{0: 1}, {1: 0}], N);
  -- distributionTester(bernoulli(0.1), [{0: 0.9}, {1: 0.1}], N);
  -- distributionTester(bernoulli(1.0), [{0: 0}, {1: 1}], N);
  -- ExperimentSetup.toggleCompatibleHash(false);
  -- distributionTester(bernoulli(0.0), [{0: 1}, {1: 0}], N);
  -- distributionTester(bernoulli(0.1), [{0: 0.9}, {1: 0.1}], N);
  -- distributionTester(bernoulli(1.0), [{0: 0}, {1: 1}], N);
end

function works_for_uniform_choice()
  -- var N = 10000;
  -- function uniformChoice(choices) {
  --   var xs = [];
  --   for (var i = 0; i < N; i++) {
  --     var a = new Assignment(choices.join(','));
  --     a.set('x', new Random.UniformChoice({ 'choices': choices, 'unit': i }));
  --     xs[i] = a.get('x');
  --   }
  --   return xs;
  -- }
  --
  -- function testDistributions() {
  --   distributionTester(uniformChoice(['a']), [{'a': 1}], N);
  --   distributionTester(uniformChoice(['a', 'b']), [{'a': 1}, {'b': 1}], N);
  -- };
  --
  -- ExperimentSetup.toggleCompatibleHash(true);
  -- testDistributions();
  --
  -- ExperimentSetup.toggleCompatibleHash(false);
  -- testDistributions();
end

function works_for_weighted_choice()
  -- var N = 10000;
  -- function weightedChoice(choices) {
  --   var xs = [];
  --   var weights = choices.map(function(choice) { return choice[Object.keys(choice)[0]]});
  --   var choices = choices.map(function(choice) { return Object.keys(choice)[0]; });
  --   for (var i = 0; i < N; i++) {
  --     var a = new Assignment(weights.join(', '));
  --     a.set('x', new Random.WeightedChoice({ 'choices': choices, 'weights': weights, 'unit': i }));
  --     xs[i] = a.get('x');
  --   }
  --   return xs;
  -- }
  --
  -- function testDistributions() {
  --   var d = [{'a': 1}];
  --   distributionTester(weightedChoice(d), d, N);
  --   d = [{'a': 1}, {'b': 2}];
  --   distributionTester(weightedChoice(d), d, N);
  --   d = [{'a': 0}, {'b': 2}, {'c': 0}];
  --   distributionTester(weightedChoice(d), d, N);
  --
  --   var da = [{'a': 1}, {'b': 2}, {'c': 0}, {'a': 2}];
  --   var db = [{'a': 3}, {'b': 2}, {'c': 0}];
  --   distributionTester(weightedChoice(da), db, N);
  -- }
  --
  -- ExperimentSetup.toggleCompatibleHash(true);
  -- testDistributions();
  --
  -- ExperimentSetup.toggleCompatibleHash(false);
  -- testDistributions();
end

function works_for_sample()
  -- var N = 100;
  -- function sample(choices, draws) {
  --   var xs = [];
  --   for (var i = 0; i < N; i++) {
  --     var a = new Assignment(choices.join(', '));
  --     a.set('x', new Random.Sample({ 'choices': choices, 'draws': draws, 'unit': i }));
  --     xs[i] = a.get('x');
  --   }
  --   return xs;
  -- }
  --
  -- function listDistributionTester(xsList, valueMass, N) {
  --   var valueDensity = valueMassToDensity(valueMass);
  --   var l = [];
  --
  --   /* bad equivalent to zip() from python */
  --   xsList.forEach(function(xs, i){
  --     xs.forEach(function(x, j) {
  --       if (!l[j]) {
  --         l[j] = [x];
  --       } else {
  --         l[j].push(x);
  --       }
  --     });
  --     if (i === xsList.length-1) {
  --       l.forEach(function(el) {
  --         assertProbs(el, valueDensity, N);
  --       });
  --     }
  --   });
  -- }
  --
  -- function testDistributions() {
  --   var a = [1, 2, 3];
  --   var ret = [{1: 1}, {2: 1}, {3: 1}];
  --   listDistributionTester(sample(a, 3), ret, N);
  --   listDistributionTester(sample(a, 2), ret, N);
  --   a = ['a', 'a', 'b'];
  --   ret = [{'a': 2}, {'b': 1}];
  --   listDistributionTester(sample(a, 3), ret, N);
  -- }
  -- 
  -- ExperimentSetup.toggleCompatibleHash(true);
  -- testDistributions();
  --
  -- ExperimentSetup.toggleCompatibleHash(false);
  -- testDistributions();
end

function works_for_efficient_sample()
  -- ExperimentSetup.toggleCompatibleHash(false);
  -- var choices = [1, 2, 3, 4, 5, 6, 7];
  -- var draws = 5;
  --
  -- var a = new Assignment(choices.join(', '));
  -- a.set('x', new Random.Sample({ 'choices': choices, 'draws': draws, 'unit': '1' }));
  -- var x = a.get('x');
  -- expect(x.length).toEqual(5);
end
