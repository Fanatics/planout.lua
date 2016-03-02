require("lib.utils")
local pretty = require 'pl.pretty'

local globalInputArgs = {}
local experimentSpecificInputArgs = {}

local resolveArgs = function(args)
  for k, v in pairs(args) do
    if type(v) == "function" then args[k] = v() end
  end
  return args
end

local fetchInputs = function(args)
  if args == nil then return {} end

  return resolveArgs(shallowcopy(args))
end

function registerExperimentInput(key, value, experimentName)
  if experimentName == nil then globalInputArgs[key] = value
  else
    if experimentSpecificInputArgs[experimentName] == nil then
      experimentSpecificInputArgs[experimentName] = {}
    end
    experimentSpecificInputArgs[experimentName][key] = value
  end
end

function getExperimentInputs(experimentName)
  local inputArgs = fetchInputs(globalInputArgs)
  if experimentName ~= nil and experimentSpecificInputArgs[experimentName] ~= nil then
    return table.merge(inputArgs, fetchInputs(experimentSpecificInputArgs[experimentName]))
  end
  return inputArgs
end
