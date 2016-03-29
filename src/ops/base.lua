package.path = package.path .. ";../?.lua"
local utils = require("lib.utils")
local cjson = require "cjson"

local _new_ = utils._new_
-- Base PlanOut object --
local PlanOutOp = {}

function PlanOutOp:new(args)
  return _new_(self, {}):init(args)
end

function PlanOutOp:init(args)
  self.args = args
  return self
end

function PlanOutOp:execute(mapper)
  error "Not implemented"
end

function PlanOutOp:dumpArgs()
  print(cjson.encode(self.args))
end

function PlanOutOp:getArgMixed(name)
  local cur = self.args[name]
  if type(cur) == "nil" then error("Property '" .. name .. "' is not defined") end
  return cur
end

function PlanOutOp:getArgNumber(name)
  local cur = self:getArgMixed(name)
  if type(cur) ~= "number" then error("Property '" .. name .. "' is not a number") end
  return cur
end

function PlanOutOp:getArgString(name)
  local cur = self:getArgMixed(name)
  if type(cur) ~= "string" then error("Property '" .. name .. "' is not a string") end
  return cur
end

function PlanOutOp:getArgList(name)
  local cur = self:getArgMixed(name)
  for i, val in pairs(cur) do if(type(i) == "number" ) then return cur end end
  error("Property '" .. name .. "' is not a list")
end

function PlanOutOp:getArgObject(name)
  local cur = self:getArgMixed(name)
  if type(cur) ~= "table" then error("Property '" .. name .. "' is not an object") end
  return cur
end

function PlanOutOp:getArgIndexish(name)
  return self:getArgObject(name)
end

-- Base PlanOut object --
local PlanOutOpSimple = PlanOutOp:new()

function PlanOutOpSimple:simpleExcute(mapper)
  error "Not implemented"
end

function PlanOutOpSimple:execute(mapper)
  self.mapper = mapper
  for k,v in pairs(self.args) do
    self.args[k] = mapper:evaluate(v)
  end
  return self:simpleExecute();
end

-- Base PlanOut object --
local PlanOutOpUnary = PlanOutOpSimple:new()

function PlanOutOpUnary:simpleExecute()
  return self:unaryExecute(self:getArgMixed('value'))
end

function PlanOutOpUnary:getUnaryString()
  return self.args.op
end

function PlanOutOpUnary:unaryExecute(value)
  error "Not implemented"
end

-- Base PlanOut object --
local PlanOutOpBinary = PlanOutOpSimple:new()

function PlanOutOpBinary:simpleExecute()
  local left = self:getArgMixed('left');
  return self:binaryExecute(self:getArgMixed('left'), self:getArgMixed('right'));
end

function PlanOutOpBinary:getInfixString()
  return self.args.op;
end

function PlanOutOpBinary:binaryExecute(left, right)
  error "Not implemented"
end

-- Base PlanOut object --
local PlanOutOpCommutative = PlanOutOpSimple:new()

function PlanOutOpCommutative:simpleExecute()
  return self:commutativeExecute(self:getArgList('values'));
end

function PlanOutOpCommutative:getCommutativeString()
  return self.args.op;
end

function PlanOutOpCommutative:commutativeExecute(values)
  error "Not implemented"
end

return {
  PlanOutOpCommutative = PlanOutOpCommutative,
  PlanOutOpBinary = PlanOutOpBinary,
  PlanOutOpUnary = PlanOutOpUnary,
  PlanOutOpSimple = PlanOutOpSimple,
  PlanOutOp = PlanOutOp
}
