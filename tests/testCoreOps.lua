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
  -- expect(arr).toEqual(a);
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
  assert(false)
  -- var arr = [0, 1, 2, 3, 4, 5];
  -- var length_test = runConfigSingle({'op': 'length', 'value': arr});
  -- expect(length_test).toEqual(arr.length);
  -- length_test = runConfigSingle({'op': 'length', 'value': []});
  -- expect(length_test).toEqual(0);
  -- length_test = runConfigSingle({'op': 'length', 'value':
  --                                   {'op': 'array', 'values': arr}
  --                                 });
  -- expect(length_test).toEqual(arr.length);
end

function TestCoreOps:test_work_with_not()
  assert(false)
  -- var x = runConfigSingle({'op': 'not', 'value': 0})
  -- expect(x).toBe(true);
  --
  -- x = runConfigSingle({'op': 'not', 'value': false});
  -- expect(x).toBe(true);
  --
  -- x = runConfigSingle({'op': 'not', 'value': 1})
  -- expect(x).toBe(false);
  --
  -- x = runConfigSingle({'op': 'not', 'value': true});
  -- expect(x).toBe(false);
end

function TestCoreOps:test_work_with_or()
  assert(false)
  -- var x = runConfigSingle({
  --         'op': 'or',
  --         'values': [0, 0, 0]})
  -- expect(x).toBe(false);
  --
  -- x = runConfigSingle({
  --     'op': 'or',
  --     'values': [0, 0, 1]})
  -- expect(x).toBe(true);
  --
  -- x = runConfigSingle({
  --     'op': 'or',
  --     'values': [false, true, false]})
  -- expect(x).toBe(true);
end

function TestCoreOps:test_work_with_and()
  assert(false)
 --  var x = runConfigSingle({
 --          'op': 'and',
 --          'values': [1, 1, 0]})
 --  expect(x).toEqual(false);
 --
 --  x = runConfigSingle({
 --      'op': 'and',
 --      'values': [0, 0, 1]})
 -- expect(x).toBe(false);
 --
 --  x = runConfigSingle({
 --      'op': 'and',
 --      'values': [true, true, true]})
 --  expect(x).toBe(true);
end

 function TestCoreOps:test_work_with_commutative_ops()
   assert(false)
  --  var arr = [33, 7, 18, 21, -3];
  --
  -- var minTest = runConfigSingle({'op': 'min', 'values': arr});
  -- expect(minTest).toEqual(-3);
  --
  -- var maxTest = runConfigSingle({'op': 'max', 'values': arr});
  -- expect(maxTest).toEqual(33);
  --
  -- var sumTest = runConfigSingle({'op': 'sum', 'values': arr});
  -- expect(sumTest).toEqual(76);
  --
  -- var productTest = runConfigSingle({'op': 'product', 'values': arr});
  -- expect(productTest).toEqual(-261954);
end

function TestCoreOps:test_work_with_binary_ops()
  assert(false)
  -- var eq = runConfigSingle({'op': 'equals', 'left': 1, 'right': 2});
  -- expect(eq).toEqual(1 == 2);
  --
  -- eq = runConfigSingle({'op': 'equals', 'left': 2, 'right': 2});
  -- expect(eq).toEqual(2 == 2);
  --
  -- var gt = runConfigSingle({'op': '>', 'left': 1, 'right': 2});
  -- expect(gt).toEqual(1 > 2);
  --
  -- var lt = runConfigSingle({'op': '<', 'left': 1, 'right': 2});
  -- expect(lt).toEqual(1 < 2);
  --
  -- var gte = runConfigSingle({'op': '>=', 'left': 2, 'right': 2});
  -- expect(gte).toEqual(2 >= 2);
  -- gte = runConfigSingle({'op': '>=', 'left': 1, 'right': 2});
  -- expect(gte).toEqual(1 >= 2);
  --
  -- var lte = runConfigSingle({'op': '<=', 'left': 2, 'right': 2});
  -- expect(lte).toEqual(2 <= 2);
  --
  -- var mod = runConfigSingle({'op': '%', 'left': 11, 'right': 3});
  -- expect(mod).toEqual(11 % 3);
  --
  -- var div = runConfigSingle({'op': '/', 'left': 3, 'right': 4})
  -- expect(div).toEqual(0.75);
end

function TestCoreOps:test_work_with_map()
  assert(false)
  -- let mapVal = {'a': 2, 'b': 'c', 'd': false };
  -- let mapOp = runConfigSingle({'op': 'map', 'a': 2, 'b': 'c', 'd': false});
  -- expect(mapOp).toEqual(mapVal);
  --
  -- let emptyMap = {};
  -- let mapOp2 = runConfigSingle({'op': 'map'});
  -- expect(emptyMap).toEqual(mapOp2);
end

function TestCoreOps:test_work_with_return()
  assert(false)
  -- var returnRunner = function(return_value) {
  --   var config = {
  --       "op": "seq",
  --       "seq": [
  --           {
  --             "op": "set",
  --             "var": "x",
  --             "value": 2
  --           },
  --           {
  --               "op": "return",
  --               "value": return_value
  --           },
  --           {
  --               "op": "set",
  --               "var": "y",
  --               "value": 4
  --           }
  --       ]
  --   };
  --   var e = new Interpreter(config, 'test_salt');
  --   return e;
  -- };
  -- var i = returnRunner(true);
  -- expect(i.getParams()).toEqual({'x': 2});
  -- expect(i.inExperiment()).toEqual(true);
  --
  -- i = returnRunner(42);
  -- expect(i.getParams()).toEqual({ 'x': 2});
  -- expect(i.inExperiment()).toEqual(true);
  --
  -- i = returnRunner(false);
  -- expect(i.getParams()).toEqual({ 'x': 2});
  -- expect(i.inExperiment()).toEqual(false);
  --
  -- i = returnRunner(0);
  -- expect(i.getParams()).toEqual({ 'x': 2});
  -- expect(i.inExperiment()).toEqual(false);
end

local lu = LuaUnit.new()
os.exit( lu:runSuite() )
