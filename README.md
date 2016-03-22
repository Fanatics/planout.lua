# PlanOut.lua

PlanOut.lua is a Lua-based implementation of [PlanOut](http://facebook.github.io/planout/). It is a complete port of the PlanOut API and language interpreter.

## Installation

PlanOut.lua requires Lua 5.1 and Luarocks.

To install, pull down the repo and run `make install`. This will install PlanOut.lua dependencies via Luarocks.

## Examples

A basic Experiment
```lua
local MyExperiment = Experiment:new()

function MyExperiment:assign(param, args)
  param:set("button_color", UniformChoice:new({["choices"] = {"#ff0000", "#00ff00"}, ["unit"] = arg["userid"]}))
  param:set("button_text", UniformChoice:new({["choices"] = {"I voted", "I am a voter"}, ["unit"] = arg["userid"]}))
end

function MyExperiment:setup()
  self.salt = "MyExperimentSalt"
end

-- later in the code

local my_exp = MyExperiment:new({["userid"] = 101})
local color = my_exp:get("button_color")
local text = my_exp:get("button_text")
```
or run through the interpreter
```lua
local compiled = {
  ["op"] = "seq",
  ["seq"] = {
    {
      ["op"] = "set",
      ["var"] = "button_color",
      ["value"] = {
        ["op"] = "uniformChoice",
        ["unit"] = {
          ["op"] = "get",
          ["var"] = "userid"
        },
        ["choices"] = {
          ["op"] = "array",
          ["values"] = {"#ff0000", "#00ff00"}
        }
      }
    },
    {
      ["op"] = "set",
      ["var"] = "button_text",
      ["value"] = {
        ["op"] = "uniformChoice",
        ["unit"] = {
          ["op"] = "get",
          ["var"] = "userid"
        },
        ["choices"] = {
          ["op"] = "array",
          ["values"] = {"I voted", "I am a voter"}
        }
      }
    }
  }
}
-- Interpreter:new(serialization, experimentSalt, inputs, environment)
local int = Interpreter:new(compiled, "MyExperimentSalt", {['userid'] = 101})
local params = int:getParams()
local color = params:get("button_color")
local text = params:get("button_text")
```
The compiled serialization can be stored as json and decoded with cjson or can be generated else where in the scripts




## Testing

PlanOut.lua tests can be run via the command `make test`, which runs every test.

If you want to run individual test files or tests, you can call them from the tests directory. Use `lua test.lua -v <testfile>` to run tests from a specific test file and `lua test.lua -v <testfile>.<specifictest>` to call a specific test from within that testfile.
