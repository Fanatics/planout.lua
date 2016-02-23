
function _new_(self, instance)
  instance = instance or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

StopPlanOutException = {}

function StopPlanOutException:new(inExperiment)
  return _new_(self, {inExperiment = inExperiment})
end

function isOperator(op)
  return type(op) == "table" and type(op.op) ~= "nil"
end

function map(obj, func, context)
  local results = {}
  if type(obj) == "table" then
    for i, val in ipairs(obj) do
      table.insert(results, func(val, i, obj))
    end
  end
  return results
end

function round(x)
  if x%2 ~= 0.5
    return math.floor(x+0.5)
  end
  return x-0.5
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
