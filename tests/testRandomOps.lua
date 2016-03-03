package.path = package.path .. ";../src/?.lua;"
require("ops.random")
local pretty = require 'pl.pretty'
-- included this for stuff like map, reduce, join.
_ = require 'underscore'
local Assignment = require "assignment"
EXPORT_ASSERT_TO_GLOBALS = true
require("resources.luaunit")

TestRandomOps = {}
TestRandomOps2 = {}

local z = 3.29

function assertProp(observedP, expectedP, N)
  local se = z * math.sqrt(expectedP * (1 - expectedP) / N)
  assert((math.abs(observedP - expectedP) <= se) == true)
end

function sum(obj)
  return _.reduce(obj, function(totalSum, cur) return totalSum + cur end)
end

function valueMassToDensity(valueMass)
  local values = _.map(valueMass, function(val) for k,v in pairs(val) do return k end end)
  local ns = _.map(valueMass, function(val, i) return val[values[i]] end)
  local ns_sum = sum(ns)
  ns = _.map(ns, function(val) return val / ns_sum end)
  local ret = {}
  for i=1, #values do
    ret[values[i]] = ns[i]
  end
  return ret
end

function Counter(l)
  local ret = {}
  for k,v in pairs(l) do
    if ret[k..""] ~= nil then
      ret[k..""] = ret[k..""] + 1
    else
      ret[k..""] = 1
    end
  end
  return ret
end

function assertProbs(xs, valueDensity, N)
  local hist = Counter(xs)
  for i,v in ipairs(hist) do
    assertProp(v / N, valueDensity[v..""], N)
  end
end

function distributionTester(xs, valueMass, N)
  N = N or 10000
  local valueDensity = valueMassToDensity(valueMass)
  assertProbs(xs, valueDensity, N)
end

function TestRandomOps:test_salts_correctly()
  local i = 20;
  local a = Assignment:new("assign_salt_a")

  a:set('x', RandomInteger:new({['min'] = 0, ['max'] = 100000, ['unit'] = i }))
  a:set('y', RandomInteger:new({['min'] = 0, ['max'] = 100000, ['unit'] = i }))
  assert(a:get('x') ~= a:get('y'))

  a:set('z', RandomInteger:new({ ['min'] = 0, ['max'] = 100000, ['unit'] = i, ['salt'] = 'x'}))
  assert(a:get('x') == a:get('z'));

  local b = Assignment:new('assign_salt_b');
  b:set('x', RandomInteger:new({ ['min'] = 0, ['max'] = 100000, ['unit'] = i}));
  assert(a:get('x') ~= b:get('x'));

  a:set('f', RandomInteger:new({ ['min'] = 0, ['max'] = 100000, ['unit'] = i, ['full_salt'] = 'fs'}))
  b:set('f', RandomInteger:new({ ['min'] = 0, ['max'] = 100000, ['unit'] = i, ['full_salt'] =' fs'}))
  assert(a:get('f') == b:get('f'));

  a:set('f', RandomInteger:new({ ['min'] = 0, ['max'] = 100000, ['unit'] = i, ['full_salt'] = 'fs2'}))
  b:set('f', RandomInteger:new({ ['min'] = 0, ['max'] = 100000, ['unit'] = i, ['full_salt'] = 'fs2'}))
  assert(a:get('f') == b:get('f'));
end

function TestRandomOps:test_works_for_bernoulli_trials()
  local N = 10000
  function bernoulli(p)
    local xs = {}
    for i=0, N do
      local a = Assignment:new(p)
      a:set('x', BernoulliTrial:new({['p'] = p, ['unit'] = i }))
      xs[i] = a:get('x')
    end
    return xs
  end

  distributionTester(bernoulli(0.0), {{['0'] = 1}, {['1'] = 0}}, N)
  distributionTester(bernoulli(0.1), {{['0'] = 0.9}, {['1'] = 0.1}}, N)
  distributionTester(bernoulli(1.0), {{['0'] = 0}, {['1'] = 1}}, N)

end

function TestRandomOps:test_works_for_uniform_choice()
  local N = 10000
  function uniformChoice(choices)
    local xs = {}
    for i=0, N do
      local a = Assignment:new(_.join(choices, ','))
      a:set('x', UniformChoice:new({ ['choices'] = choices, ['unit'] = i}))
      xs[i] = a:get('x')
    end
    return xs
  end

  function testDistributions()
    distributionTester(uniformChoice({'a'}), {{['a'] = 1}}, N);
    distributionTester(uniformChoice({'a', 'b'}), {{['a'] = 1}, {['b'] = 1}}, N);
  end

  testDistributions();
  testDistributions();

end

function TestRandomOps:test_works_for_weighted_choice()
  local N = 10000
  function weightedChoice(choose)

    local xs = {}
    local weights = _.map(choose, function(choice) for k,v in pairs(choice) do return v end end)
    local choices = _.map(choose, function(choice) for k,v in pairs(choice) do return k end end)
    for i=0, N do
      local a = Assignment:new(_.join(weights, ', '))
      a:set('x', WeightedChoice:new({['choices'] = choices, ['weights'] = weights, ['unit'] = i }))
      xs[i] = a:get('x')
    end
    return xs
  end

  function testDistributions()
    local d = {{['a'] = 1}}
    distributionTester(weightedChoice(d), d, N)
    d = {{['a'] = 1}, {['b'] = 2}}
    distributionTester(weightedChoice(d), d, N)
    d = {{['a'] = 0}, {['b'] = 2}, {['c'] = 0}}
    distributionTester(weightedChoice(d), d, N)

    local da = {{['a'] = 1}, {['b'] = 2}, {['c'] = 0}, {['a'] = 2}}
    local db = {{['a'] = 3}, {['b'] = 2}, {['c'] = 0}}
    distributionTester(weightedChoice(da), db, N)
  end

  testDistributions();

  testDistributions();
end

function TestRandomOps:test_works_for_sample()
  local N = 100
  function sample(choices, draws)
    local xs = {}
    for i=0, N do
      local a = Assignment:new(_.join(choices, ', '))
      a:set('x', Sample:new({['choices'] = choices, ['draws'] = draws, ['unit'] = i}))
      xs[i] = a:get('x')
    end
    return xs
  end

  function listDistributionTester(xsList, valueMass, N)
    local valueDensity = valueMassToDensity(valueMass)
    local l = {}

    for xs,i in pairs(xsList) do
      for x,j in pairs(i) do
        if l[j] then
          l[j] = k
        else
          table.insert(l, k)
        end
      end
      if i == #xsList then
        for k,v in pairs(l) do
          assertProbs(el, valueDensity, N)
        end
      end
    end
  end

  function testDistributions()
    local a = {1,2,3}
    local ret = {{[1] = 1},{[2] = 1},{[3] = 1}}
    listDistributionTester(sample(a, 2), ret, N)
    listDistributionTester(sample(a, 2), ret, N)
    a = {'a', 'a', 'b'}
    ret = {{['a'] = 2}, {['b'] = 1}}
    listDistributionTester(sample(a, 3), ret, N)
  end
  testDistributions();

  testDistributions();
end

function TestRandomOps:test_works_for_efficient_sample()
  local choices = {1,2,3,4,5,6,7}
  local draws = 5

  local a = Assignment:new(_.join(choices, ', '))
  a:set('x', Sample:new({['choices'] = choices, ['draws'] = draws, ['unit'] = '1'}))
  local x = a:get('x')
  assert(#x == 5)
end

local lu = LuaUnit.new()
os.exit( lu:runSuite() )
