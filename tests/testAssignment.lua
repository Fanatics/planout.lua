package.path = package.path .. ";../src/?.lua;"
local Assignment = require "assignment"

local LuaUnit = require "resources.luaunit"
TestAssignment = {}

local testerUnit = '4'
local testerSalt = 'test_salt'

function TestAssignment:test_set_constrants_correctly()
  assert_false( false, "This test never fails.")
  -- var a = new Assignment(testerSalt);
  -- a.set('foo', 12);
  -- expect(a.get('foo')).toBe(12);
end

function TestAssignment:work_with_uniform_choice()
  assert_false( false, "This test never fails.")
  -- var a = new Assignment(testerSalt);
  -- var choices = ['a', 'b'];
  -- a.set('foo', new UniformChoice({'choices': choices, 'unit': testerUnit}));
  -- a.set('bar', new UniformChoice({'choices': choices, 'unit': testerUnit}));
  -- a.set('baz', new UniformChoice({'choices': choices, 'unit': testerUnit}));
  --
  -- expect(a.get('foo')).toEqual('b');
  -- expect(a.get('bar')).toEqual('a');
  -- expect(a.get('baz')).toEqual('a');
end

function TestAssignment:work_with_overrides()
  assert_false( false, "This test never fails.")
  -- var a = new Assignment(testerSalt);
  -- a.setOverrides({'x': 42, 'y': 43});
  -- a.set('x', 5);
  -- a.set('y', 6);
  -- expect(a.get('x')).toEqual(42);
  -- expect(a.get('y')).toEqual(43);
end

function TestAssignment:work_with_falsy_overrides()
  assert_false( false, "This test never fails.")
  -- var a = new Assignment(testerSalt);
  -- a.setOverrides({'x': 0, 'y': '', 'z': false});
  -- a.set('x', 5);
  -- a.set('y', 6);
  -- a.set('z', 7);
  -- expect(a.get('x')).toEqual(0);
  -- expect(a.get('y')).toEqual('');
  -- expect(a.get('z')).toEqual(false);
end

LuaUnit:run()
