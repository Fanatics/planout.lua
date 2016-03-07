-- Test.lua
-- Usage: lua test.lua -v (runs all tests)
-- This file combines all test files and initiates lua unit.
-- You can run all tests, or pass the name of the test you want to run as
-- a command line arguement. ex: lua test.lua TestAssignment  -v

require("testAssignment")
require("testCoreOps")
require("testExperimentSetup")
require("testInterpreter")
require("testNameSpace")
require("testRandomOps")

local lu = LuaUnit.new()
os.exit( lu:runSuite() )
