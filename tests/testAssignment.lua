package.path = package.path .. ";../src/?.lua;"
local Assignment = require "assignment"
require("ops.random")

EXPORT_ASSERT_TO_GLOBALS = true
require("resources.luaunit")

TestAssignment = {}

local testerUnit = '4'
local testerSalt = 'test_salt'

function TestAssignment:test_set_constrants_correctly()
  local a = Assignment:new(testerSalt)
  a:set("foo", 12)
  assert(a:get("foo") == 12, "Constraints are not being set properly")
end

function TestAssignment:test_work_with_uniform_choice()
  local a = Assignment:new(testerSalt)
  local choices = {"a", "b"}

  a:set('foo', UniformChoice:new({['choices'] = choices, ['unit'] = testerUnit}))
  a:set('bar', UniformChoice:new({['choices'] = choices, ['unit'] = testerUnit}))
  a:set('baz', UniformChoice:new({['choices'] = choices, ['unit'] = testerUnit}))

  --assert(a:get('foo') == "b")
  --assert(a:get('bar') == "a")
  --assert(a:get('baz') == "a")
end

function TestAssignment:test_work_with_overrides()
  local a = Assignment:new(testerSalt)
  a:setOverrides({['x'] = 42, ['y'] = 43})
  a:set('x', 5);
  a:set('y', 6);
  assert(a:get('x') == 42)
  assert(a:get('y') == 43)
end

function TestAssignment:test_work_with_falsy_overrides()
  local a = Assignment:new(testerSalt)
  a:setOverrides({['x'] = 0, ['y'] = '', ['z'] = false})
  a:set('x', 5)
  a:set('y', 6)
  a:set('z', 7)

  assert(a:get('x') == 0)
  assert(a:get('y') == '')
  assert(a:get('z') == false)
end

local lu = LuaUnit.new()
os.exit( lu:runSuite() )
