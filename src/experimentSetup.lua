require("lib.utils")

local globalInputArgs = {}
local experimentSpecificInputArgs = {}

local fetchInputs = function(args)
  if args == nil then return {} end

  return resolveArgs(shallowcopy(args))
end

local resolveArgs = function(args)
  for k, v in args do
    if type(v) == "function" then args[k] = v() end
  end
  return args
end

function registerExperimentInput(key, value, experimentName)
  if experimentName == nil then globalInputArgs[key] = value
  else
    if experimentSpecificInputArgs[experimentName] = nil then
      experimentSpecificInputArgs[experimentName] = {}
    end
    experimentSpecificInputArgs[experimentName][key] = value
  end
end

function  getExperimentInputs(experimentName)
  local inputArgs = fetchInputs(globalInputArgs)
  if experimentName ~= nil and experimentSpecificInputArgs[experimentName] ~= nil then
    return setmetatable(inputArgs, fetchInputs(experimentSpecificInputArgs[experimentName]))
  end
  return inputArgs
end
