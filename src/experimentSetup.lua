local utils = require("lib.utils")

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

  return resolveArgs(utils.shallowcopy(args))
end

local registerExperimentInput = function(key, value, experimentName)
  if experimentName == nil then globalInputArgs[key] = value
  else
    if experimentSpecificInputArgs[experimentName] == nil then
      experimentSpecificInputArgs[experimentName] = {}
    end
    experimentSpecificInputArgs[experimentName][key] = value
  end
end

local clearExperimentInput = function(key, experimentName)
  if experimentName == nil then globalInputArgs[key] = nil
  else
    if experimentSpecificInputArgs[experimentName] ~= nil then
      experimentSpecificInputArgs[experimentName][key] = nil
    end
  end
end

local getExperimentInputs = function(experimentName)
  local inputArgs = fetchInputs(globalInputArgs)
  if experimentName ~= nil and experimentSpecificInputArgs[experimentName] ~= nil then
    return table.merge(inputArgs, fetchInputs(experimentSpecificInputArgs[experimentName]))
  end
  return inputArgs
end

return {
  getExperimentInputs = getExperimentInputs,
  clearExperimentInput = clearExperimentInput,
  registerExperimentInput = registerExperimentInput
}
