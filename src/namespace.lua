require("lib.utils")

local Experiment = require "Experiment"
local Assignment = require "Assignment"

DefaultExperiment = Experiment:new()

function DefaultExperiment:configureLogger()
  return
end

function DefaultExperiment:setup()
  self.name = 'test_name'
end

function DefaultExperiment:log(data)
  return
end

function DefaultExperiment:getParamNames()
  return self:getDefaultParamNames()
end

function DefaultExperiment:previouslyLogged()
  return true
end

function DefaultExperiment:assign(params, args)
  return
end
