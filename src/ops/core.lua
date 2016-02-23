package.path = package.path .. ";../?.lua"
require("lib.utils")
local pretty = require 'pl.pretty'

require("base")

Literal = PlanOutOp:new()

function Literal:execute(mapper)
  return self:getArgMixed('value')
end


Get = PlanOutOp:new()

function Get:execute(mapper)
  return mapper:get(self:getArgString('var'))
end


Seq = PlanOutOp:new()

function Seq:execute(mapper)
  local sequence = self:getArgList('seq')
  for i, val in ipairs(sequence) do
    mapper:evaluate(val)
  end
end


Return = PlanOutOp:new()

function Return:execute(mapper)
  local value = mapper:evaluate(self:getArgMixed('value'))
  error(topPlanOutException:new(value ~= false and value ~= 0))
end

Set = PlanOutOp:new()

function Set:execute(mapper)
  local variable = this.getArgString('var');
  local value = this.getArgMixed('value');

  if mapper:hasOverride(variable) then return end

  if isOperator(value) and type(value.salt) == nil then
    value.salt = variable;
  end

  if variable == "experimentSalt" then
    mapper.experimentSalt = value;
  end

  mapper:set(variable, mapper:evaluate(value));
end


Arr = PlanOutOp:new()

function Arr:execute(mapper)
  return map(self:getArgList('values'), function(value)
    return mapper:evaluate(value)
  end)
end


Coalesce = PlanOutOp:new()

function Coalesce:execute(mapper)
  local values = self:getArgList('values')
  for i, val in ipairs(values) do
    local x = mapper.evaluate(val)
    if type(x) ~= nil then return x end
  end
  return nil
end


Index = PlanOutOpSimple:new()

function Index:simpleExecute()
  local base = self:getArgIndexish('base') or {}
  local index = self:getArgMixed('index')
  if type(index) == "number" then
    local length = #base
    if index <= 0 or index > length then return nil end
  end
  return base[index]
end


Cond = PlanOutOp:new()

function Cond:execute(mapper)
  local list = self:getArgList('cond')
  for i, val in ipairs(list) do
    ifClause = val['if']
    if mapper.evaluate(ifClause) the return mapper.evaluate(val['then']) end
  end
  return nil
end


And = PlanOutOp:new()

function And:execute(mapper)
  local list = self:getArgList('values')
  for i, val in ipairs(list) do
    if not mapper.evaluate(val) then return false end
  end
  return true
end

Or = PlanOutOp:new()

function Or:execute(mapper)
  local list = self:getArgList('values')
  for i, val in ipairs(list) do
    if  mapper.evaluate(val) then return true end
  end
  return false
end


Product = PlanOutOpCommutative:new()

function Product:commutativeExecute(values)
  local result = 1
  for i, val in ipairs(values) do
    result = result * val
  end
  return result
end


Sum = PlanOutOpCommutative:new()

function Sum:commutativeExecute(values)
  local result = 1
  for i, val in ipairs(values) do
    result = result + val
  end
  return result
end

Equals = PlanOutOpBinary:new();

function Equals:binaryExecute(left, right)
  return left == right
end

function Equals:getInfixString()
  return "=="
end


GreaterThan = PlanOutOpBinary:new();

function GreaterThan:binaryExecute(left, right)
  return left > right
end


LessThan = PlanOutOpBinary:new();

function LessThan:binaryExecute(left, right)
  return left < right
end


LessThanOrEqualTo = PlanOutOpBinary:new();

function LessThanOrEqualTo:binaryExecute(left, right)
  return left <= right
end


GreaterThanOrEqualTo = PlanOutOpBinary:new();

function GreaterThanOrEqualTo:binaryExecute(left, right)
  return left >= right
end


Mod = PlanOutOpBinary:new();

function Mod:binaryExecute(left, right)
  return left % right
end


Divide = PlanOutOpBinary:new();

function Divide:binaryExecute(left, right)
  return left / right
end


Round = PlanOutOpUnary:new();

function Round:unaryExecute(value
  return round(value)
end



Not = PlanOutOpUnary:new();

function Not:unaryExecute(value)
  return not value
end

function Not:getUnaryString()
  return '!';
end


Negative = PlanOutOpUnary:new()

function Negative:unaryExecute(value)
  return 0 - value
end

function Negative:getUnaryString()
  return '-';
end


Length = PlanOutOpUnary:new();

function Length:unaryExecute(value)
  return #value
end


Min = PlanOutOpCommutative:new()

function Min:commutativeExecute(values)
  return math.min(unpack(values))
end



Max = PlanOutOpCommutative:new()

function Max:commutativeExecute(values)
  return math.max(unpack(values))
end


Map = PlanOutOpSimple:new()

function Map:simpleExecute()
  local copy = deepcopy(self.args)
  copy.op = nil
  copy.salt = nil
  return copy
end
