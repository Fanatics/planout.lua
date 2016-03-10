package.path = package.path .. ";../src/?.lua;"
local Interpreter = require "interpreter"

local pretty = require 'pl.pretty'

EXPORT_ASSERT_TO_GLOBALS = true
require("resources.luaunit")

TestCoreOps = {}

function runConfig(config, init)
  local obj = Interpreter:new(config, 'test_salt', init or {})
  return obj:getParams()
end

function runConfigSingle(config)
 local xConfig = {['op'] = 'set', ['var'] = 'x', ['value'] = config};
 return runConfig(xConfig)['x']
end

function TestCoreOps:test_set_appropriately()
  local c = {['op'] = 'set', ['value'] = 'x_val', ['var'] = 'x'}
  local d = runConfig(c)
  assert(d ~= nil and d['x'] == 'x_val')
end

function TestCoreOps:test_work_with_seq()
  local c = {['op'] = 'seq', ['seq'] = {
    {['op'] = 'set', ['value'] = 'x_val', ['var'] = 'x'},
    {['op'] = 'set', ['value'] = 'y_val', ['var'] = 'y'}
  }}
  local d = runConfig(c)
  assert(d ~= nil and d['x'] == 'x_val')
  assert(d ~= nil and d['y'] == 'y_val')
end

function TestCoreOps:test_work_with_arr()
  local arr = {4, 5, 'a'};
  local a = runConfigSingle({['op'] = 'array', ['values'] = arr});
  for i, v in ipairs(a) do
    assert(v == arr[i])
  end
end

function TestCoreOps:test_work_with_get()
  local c = {['op'] = 'seq', ['seq'] = {
    {['op'] = 'set', ['value'] = 'x_val', ['var'] = 'x'},
    {['op'] = 'set', ['value'] = {['op'] = 'get', ['var'] = 'x'}, ['var'] = 'y'}
  }}
  local d = runConfig(c)
  assert(d ~= nil and d['x'] == 'x_val')
  assert(d ~= nil and d['y'] == 'x_val')
end

function TestCoreOps:test_work_with_cond()
  local getInput = function(i, r)
    return {['op'] = 'equals', ['left'] = i, ['right'] = r}
  end
  local testIf = function(i)
    return runConfig({
     ['op'] = 'cond',
      ['cond'] = {
           {['if'] = getInput(i, 0),
            ['then'] = {['op'] = 'set', ['var'] = 'x', ['value'] = 'x_0'}},
           {['if'] = getInput(i, 1),
            ['then'] = {['op'] = 'set', ['var'] = 'x', ['value'] = 'x_1'}}
     }
  })
end
local zero = testIf(0)
local one = testIf(1)
assert(zero ~= nil and zero['x'] == 'x_0')
assert(one ~= nil and one['x'] == 'x_1')
end

function TestCoreOps:test_work_with_index()
  local arrayLiteral = {10, 20, 30}
--   var objLiteral = {'a': 42, 'b': 43};
  local objLiteral = { a = 42, b = 43}
--
  local x = runConfigSingle({['op'] = 'index', ['index'] = 1, ['base'] = arrayLiteral})-----------------------------------------
  assert(x == 10)

  x = runConfigSingle({['op'] = 'index', ['index'] = 3, ['base'] = arrayLiteral})
  assert(x == 30)

  x = runConfigSingle({['op'] = 'index', ['index'] = 'a', ['base'] = objLiteral})
  assert(x == 42)

  x = runConfigSingle({['op'] = 'index', ['index'] = 6, ['base'] = arrayLiteral})
  assert(x == nil)

  x = runConfigSingle({['op'] = 'index', ['index'] = 'c', ['base'] = objLiteral})
  assert(x == nill)

  x = runConfigSingle({
    ['op'] = 'index',
    ['index'] = 3,
    ['base'] = {['op'] = 'array', ['values'] = arrayLiteral}
  })

  assert(x == 30)
end


function TestCoreOps:test_work_with_coalesce()
  local x = runConfigSingle({['op'] = 'coalesce', ['values'] = {nil}})
  assert(x == nil)

  x = runConfigSingle({['op'] = 'coalesce', ['values'] = {nil, 42, nil}})
  assert(x == 42)

  x = runConfigSingle({['op'] = 'coalesce', ['values'] = {nil, nil, 43}})
  assert(x == 43)
end

function TestCoreOps:test_work_with_length()
  local arr = {0, 1, 2, 3, 4, 5};
  local length_test = runConfigSingle({['op'] = 'length', ['value'] = arr})
  assert(length_test == #arr)

  length_test = runConfigSingle({['op'] = 'length', ['value'] = {}})
  assert(length_test == 0)

  local length_test = runConfigSingle({['op'] = 'length',
    ['value'] = {['op'] = 'array', ['values'] = arr}
  })
  assert(length_test == #arr)
end

function TestCoreOps:test_work_with_not()
  local x = runConfigSingle({['op'] = 'not', ['value'] = 0})
  assert(x)

  x = runConfigSingle({['op'] = 'not', ['value'] = false})
  assert(x)

  x = runConfigSingle({['op'] = 'not', ['value'] = 1})
  assert_false(x)

  x = runConfigSingle({['op'] = 'not', ['value'] = true})
  assert_false(x)
end

function TestCoreOps:test_work_with_or()
  local x = runConfigSingle({
          ['op'] = 'or',
          ['values'] = {0, 0, 0}})
  assert_false(x)

  x = runConfigSingle({
          ['op'] = 'or',
          ['values'] = {0, 0, 1}})
  assert(x)

  x = runConfigSingle({
          ['op'] = 'or',
          ['values'] = {false, true, false}})
  assert(x)
end

function TestCoreOps:test_work_with_and()
  local x = runConfigSingle({
          ['op'] = 'and',
          ['values'] = {1, 1, 0}})
  assert_false(x)

  x = runConfigSingle({
          ['op'] = 'and',
          ['values'] = {0, 0, 1}})
  assert_false(x)

  x = runConfigSingle({
          ['op'] = 'and',
          ['values'] = {true, true, true}})
  assert(x)
end

 function TestCoreOps:test_work_with_commutative_ops()
  local arr = {33, 7, 18, 21, -3}

  local minTest = runConfigSingle({['op'] = 'min', ['values'] = arr})
  assert(minTest == -3)

  local maxTest = runConfigSingle({['op'] = 'max', ['values'] = arr})
  assert(maxTest == 33)

  local sumTest = runConfigSingle({['op'] = 'sum', ['values'] = arr})
  assert(sumTest == 76)

  local productTest = runConfigSingle({['op'] = 'product', ['values'] = arr})
  assert(productTest == -261954)
end

function TestCoreOps:test_work_with_binary_ops()
  local eq = runConfigSingle({['op'] = 'equals', ['left'] = 1, ['right'] = 2})
  assert(eq == (1 == 2))

  eq = runConfigSingle({['op'] = 'equals', ['left'] = 2, ['right'] = 2})
  assert(eq == (2 == 2))

  local gt = runConfigSingle({['op'] = '>', ['left'] = 1, ['right'] = 2})
  assert(gt == (1 > 2))

  local lt = runConfigSingle({['op'] = '<', ['left'] = 1, ['right'] = 2})
  assert(lt == (1 < 2))

  local gte = runConfigSingle({['op'] = '>=', ['left'] = 2, ['right'] = 2})
  assert(gte == (2 >= 2))

  gte = runConfigSingle({['op'] = '>=', ['left'] = 1, ['right'] = 2})
  assert(gte == (1 >= 2))

  local lte = runConfigSingle({['op'] = '<=', ['left'] = 2, ['right'] = 2})
  assert(lte == (2 <= 2))

  local mod = runConfigSingle({['op'] = '%', ['left'] = 11, ['right'] = 3})
  assert(mod == (11 % 3))

  local div = runConfigSingle({['op'] = '/', ['left'] = 3, ['right'] = 4})
  assert(div == (0.75))
end

function TestCoreOps:test_work_with_map()
  local mapVal = {['a'] = 2, ['b'] = 'c', ['d'] = false };
  local mapOp = runConfigSingle({['op'] = 'map', ['a'] = 2, ['b'] = 'c', ['d'] = false});

  for k, v in pairs(mapVal) do assert(mapOp[k] == v) end
  for k, v in pairs(mapOp) do assert(mapVal[k] == v) end

  local mapOp2 = runConfigSingle({['op'] = 'map'});
  assert(#mapOp2 == 0);
end

function TestCoreOps:test_work_with_return()

  local returnRunner = function(return_value)
    local config = {
      ["op"] = "seq",
      ["seq"] = {
        {
          ["op"] = "set",
          ["var"] = "x",
          ["value"] = 2
        },
        {
          ["op"] = "return",
          ["value"] = return_value
        },
        {
          ["op"] = "set",
          ["var"] = "y",
          ["value"] = 4
        }
      }
    }
    return Interpreter:new(config, 'test_salt')
  end

  local i = returnRunner(true)
  assert(i:getParams()['x'] == 2)
  assert(i:inExperiment() == true)

  i = returnRunner(42)
  assert(i:getParams()['x'] == 2)
  assert(i:inExperiment() == true)

  i = returnRunner(false);
  assert(i:getParams()['x'] == 2)
  assert(i:inExperiment() == false)

  i = returnRunner(0);
  assert(i:getParams()['x'] == 2)
  assert(i:inExperiment() == false)
end
