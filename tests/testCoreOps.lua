require "lunit"

module("test_core_opts", lunit.testcases)

-- function runConfig(config, init={}) {
--   var interpreter = new Interpreter(config, 'test_salt', init);
--   return interpreter.getParams();
-- }
--
-- function runConfigSingle(config) {
--   var xConfig = {'op': 'set', 'var': 'x', 'value': config};
--   return runConfig(xConfig)['x'];
-- }

function set_appropriately()
  -- var c = {'op': 'set', 'value': 'x_val', 'var': 'x'}
  -- var d = runConfig(c);
  -- expect(d).toEqual({ 'x': 'x_val'});
end

function work_with_seq()
  -- var config = {'op': 'seq', 'seq': [
  --         {'op': 'set', 'value': 'x_val', 'var': 'x'},
  --         {'op': 'set', 'value': 'y_val', 'var': 'y'}
  --     ]};
  -- var d = runConfig(config)
  -- expect(d).toEqual({'x': 'x_val', 'y': 'y_val'});
end

function work_with_arr()
  -- var arr = [4, 5, 'a'];
  -- var a = runConfigSingle({'op': 'array', 'values': arr});
  -- expect(arr).toEqual(a);
end

function work_with_get()
  -- var d = runConfig({
  --           'op': 'seq',
  --           'seq': [
  --               {'op': 'set', 'var': 'x', 'value': 'x_val'},
  --               {'op': 'set', 'var': 'y', 'value': {'op': 'get', 'var': 'x'}}
  --           ]
  --       });
  -- expect({'x': 'x_val', 'y': 'x_val'}).toEqual(d);
end

function work_with_cond()
  -- var getInput = function(i, r) {
  --   return {'op': 'equals', 'left': i, 'right': r};
  -- };
  -- var testIf = function(i) {
  --   return runConfig({
  --     'op': 'cond',
  --       'cond': [
  --           {'if': getInput(i, 0),
  --            'then': {'op': 'set', 'var': 'x', 'value': 'x_0'}},
  --           {'if': getInput(i, 1),
  --            'then': {'op': 'set', 'var': 'x', 'value': 'x_1'}}
  --       ]
  --   });
  -- };
  -- expect(testIf(0)).toEqual({ 'x': 'x_0'});
  -- expect(testIf(1)).toEqual({ 'x': 'x_1'});
end

function work_with_index()
--   var arrayLiteral = [10, 20, 30];
--   var objLiteral = {'a': 42, 'b': 43};
--
--   var x = runConfigSingle(
--       {'op': 'index', 'index': 0, 'base': arrayLiteral}
--   )
--   expect(x).toEqual(10);
--
--   x = runConfigSingle(
--       {'op': 'index', 'index': 2, 'base': arrayLiteral}
--   )
--   expect(x).toEqual(30);
--
--   x = runConfigSingle(
--       {'op': 'index', 'index': 'a', 'base': objLiteral}
--   )
--   expect(x).toEqual(42);
--
--   x = runConfigSingle(
--       {'op': 'index', 'index': 6, 'base': arrayLiteral}
--   )
--   expect(x).toBe(undefined);
--
--   x = runConfigSingle(
--       {'op': 'index', 'index': 'c', 'base': objLiteral}
--   )
--   expect(x).toBe(undefined);
--
--   x = runConfigSingle({
--       'op': 'index',
--       'index': 2,
--       'base': {'op': 'array', 'values': arrayLiteral}
--   });
--   expect(x).toEqual(30);
-- });
end

function work_with_coalesce()
  -- var x = runConfigSingle({'op': 'coalesce', 'values': [null]});
  --   expect(x).toEqual(null);
  --
  --   x = runConfigSingle({'op': 'coalesce', 'values': [null, 42, null]});
  --   expect(x).toEqual(42);
  --
  --   x = runConfigSingle({'op': 'coalesce', 'values': [null, null, 43]});
  --   expect(x).toEqual(43);
end

function work_with_length()
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

function work_with_not()
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

function work_with_or()
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

function work_with_and
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

 function work_with_commutative_ops()
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

function work_with_binary_ops()
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

function work_with_map()
  -- let mapVal = {'a': 2, 'b': 'c', 'd': false };
  -- let mapOp = runConfigSingle({'op': 'map', 'a': 2, 'b': 'c', 'd': false});
  -- expect(mapOp).toEqual(mapVal);
  --
  -- let emptyMap = {};
  -- let mapOp2 = runConfigSingle({'op': 'map'});
  -- expect(emptyMap).toEqual(mapOp2);
end

function work_with_return()
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
