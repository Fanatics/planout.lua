package.path = package.path .. ";../?.lua"
local utils = require("lib.utils")
local base = require("ops.base")

local map = utils.map
local round = utils.round
local deepcopy = utils.deepcopy

local StopPlanOutException = utils.StopPlanOutException
local PlanOutOp = base.PlanOutOp
local PlanOutOpSimple = base.PlanOutOpSimple
local PlanOutOpCommutative = base.PlanOutOpCommutative
local PlanOutOpBinary = base.PlanOutOpBinary
local PlanOutOpUnary = base.PlanOutOpUnary

local cjson = require("cjson")

local jsIs = function(value)
  return not (not value or value == 0)
end

local Literal = PlanOutOp:new()

function Literal:execute(mapper)
  return self:getArgMixed('value')
end


local Get = PlanOutOp:new()

function Get:execute(mapper)
  return mapper:get(self:getArgString('var'))
end


local Seq = PlanOutOp:new()

function Seq:execute(mapper)
  local sequence = self:getArgList('seq')
  for i, val in ipairs(sequence) do
    mapper:evaluate(val)
  end
end


local Return = PlanOutOp:new()

function Return:execute(mapper)
  local value = mapper:evaluate(self:getArgMixed('value'))
  error(StopPlanOutException:new(value ~= false and value ~= 0))
end

local Set = PlanOutOp:new()

function Set:execute(mapper)
  local variable = self:getArgString('var')
  local value = self:getArgMixed('value')

  if mapper:hasOverride(variable) then return end

  if utils.isOperator(value) and value.salt == nil then value.salt = variable end

  if variable == "experimentSalt" then mapper.experimentSalt = value end

  mapper:set(variable, mapper:evaluate(value));
end


local Arr = PlanOutOp:new()

function Arr:execute(mapper)
  return map(self:getArgList('values'), function(value)
    return mapper:evaluate(value)
  end)
end


local Coalesce = PlanOutOp:new()

function Coalesce:execute(mapper)
  local values = self:getArgList('values')

  for i, val in pairs(values) do
    local x = mapper:evaluate(val)
    if type(x) ~= nil then return x end
  end
  return nil
end


local Index = PlanOutOpSimple:new()

function Index:simpleExecute()
  local base = self:getArgIndexish('base') or {}
  local index = self:getArgMixed('index')
  if type(index) == "number" then
    local length = #base
    if index <= 0 or index > length then return nil end
  end
  return base[index]
end


local Cond = PlanOutOp:new()

function Cond:execute(mapper)
  local list = self:getArgList('cond')
  for i, val in ipairs(list) do
    ifClause = val['if']
    local eval = mapper:evaluate(ifClause)
    if eval and eval ~= 0 then return mapper:evaluate(val['then']) end
  end
  return nil
end


local And = PlanOutOp:new()

function And:execute(mapper)
  local list = self:getArgList('values')
  for i, val in ipairs(list) do
    if not jsIs(mapper:evaluate(val)) then return false end
  end
  return true
end

local Or = PlanOutOp:new()

function Or:execute(mapper)
  local list = self:getArgList('values')
  for i, val in ipairs(list) do
    if jsIs(mapper:evaluate(val)) then return true end
  end
  return false
end


local Product = PlanOutOpCommutative:new()

function Product:commutativeExecute(values)
  local result = 1
  for i, val in ipairs(values) do
    result = result * val
  end
  return result
end


local Sum = PlanOutOpCommutative:new()

function Sum:commutativeExecute(values)
  local result = 0
  for i, val in ipairs(values) do
    result = result + val
  end
  return result
end

local Equals = PlanOutOpBinary:new();

function Equals:binaryExecute(left, right)
  return left == right
end

function Equals:getInfixString()
  return "=="
end


local GreaterThan = PlanOutOpBinary:new();

function GreaterThan:binaryExecute(left, right)
  return left > right
end


local LessThan = PlanOutOpBinary:new();

function LessThan:binaryExecute(left, right)
  return left < right
end


local LessThanOrEqualTo = PlanOutOpBinary:new();

function LessThanOrEqualTo:binaryExecute(left, right)
  return left <= right
end


local GreaterThanOrEqualTo = PlanOutOpBinary:new();

function GreaterThanOrEqualTo:binaryExecute(left, right)
  return left >= right
end


local Mod = PlanOutOpBinary:new();

function Mod:binaryExecute(left, right)
  return left % right
end


local Divide = PlanOutOpBinary:new();

function Divide:binaryExecute(left, right)
  return left / right
end


local Round = PlanOutOpUnary:new();

function Round:unaryExecute(value)
  return round(value)
end



local Not = PlanOutOpUnary:new();

function Not:unaryExecute(value)
  return not value or value == 0
end

function Not:getUnaryString()
  return '!';
end


local Negative = PlanOutOpUnary:new()

function Negative:unaryExecute(value)
  return 0 - value
end

function Negative:getUnaryString()
  return '-';
end


local Length = PlanOutOpUnary:new();

function Length:unaryExecute(value)
  return #value
end


local Min = PlanOutOpCommutative:new()

function Min:commutativeExecute(values)
  return math.min(unpack(values))
end



local Max = PlanOutOpCommutative:new()

function Max:commutativeExecute(values)
  return math.max(unpack(values))
end


local Map = PlanOutOpSimple:new()

function Map:simpleExecute()
  local copy = deepcopy(self.args)
  copy.op = nil
  copy.salt = nil
  return copy
end

return {
  Map = Map,
  Max = Max,
  Min = Min,
  Length = Length,
  Negative = Negative,
  Not = Not,
  Round = Round,
  Divide = Divide,
  Mod = Mod,
  GreaterThanOrEqualTo = GreaterThanOrEqualTo,
  LessThanOrEqualTo = LessThanOrEqualTo,
  LessThan = LessThan,
  GreaterThan = GreaterThan,
  Equals = Equals,
  Sum = Sum,
  Product = Product,
  Or = Or,
  And = And,
  Cond = Cond,
  Index = Index,
  Coalesce = Coalesce,
  Arr = Arr,
  Set = Set,
  Return = Return,
  Seq = Seq,
  Get = Get
}
