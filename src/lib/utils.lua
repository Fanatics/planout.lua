local bc = require "bc"

local _new_ = function(self, instance)
  instance = instance or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

local StopPlanOutException = {}

function StopPlanOutException:new(inExperiment)
  return _new_(self, {inExperiment = inExperiment})
end

local isOperator = function(op)
  return type(op) == "table" and op.op ~= nil
end

local map = function(obj, func, context)
  local results = {}
  if type(obj) == "table" then
    for i, val in ipairs(obj) do
      table.insert(results, func(val, i, obj))
    end
  end
  return results
end

local round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

local deepcopy
-- Delcaration must be separated from definition because it is recursive
deepcopy = function(orig)
  local copy
  local status, err = pcall(function()
    local orig_type = type(orig)
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
  end)
  if err ~= nil then print(cjson(err)) end
  return copy
end

local shallowcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

table.slice = function(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

local instanceOf = function(subject, super)
	super = tostring(super)
	local mt = getmetatable(subject)

	while true do
		if mt == nil then return false end
		if tostring(mt) == super then return true end

		mt = getmetatable(mt)
	end
end

local tablelength = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

table.indexOf = function( t, object )
	if "table" == type( t ) then
		for i, v in pairs(t) do
			if object == t[i] then
				return i
			end
		end
	end

	return -1
end

table.merge = function(results, ...)
  local arg={...}
  for i,v in ipairs(arg) do
    if type(v) == "table" then
      for k,vp in pairs(v) do
        results[k] = shallowcopy(vp)
      end
    else
      table.insert(results, v)
    end
  end
  return results
end

string.split = function(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
        table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

table.filledLength = function(table)
  local len = 0
  for i, v in ipairs(table) do
    if v ~= -1 then len = len + 1 end
  end
  return len
end

table.length = function(table)
  if #table == 0 then
    local i = 0
    for k,v in pairs(table) do i = i + 1 end
    return i
  end
  return #table
end

local hex2bc = function(s)
	local x=bc.number(0)
	for i=1,#s do
		x=16*x+tonumber(s:sub(i,i),16)
	end
	return x
end

local range = function(max, start)
  local l = {}
  for i = start or 1, max do
    table.insert(l, i)
  end
  return l
end

return {
  range = range,
  hex2bc = hex2bc,
  tablelength = tablelength,
  instanceOf = instanceOf,
  shallowcopy = shallowcopy,
  deepcopy = deepcopy,
  round = round,
  map = map,
  isOperator = isOperator,
  StopPlanOutException = StopPlanOutException,
  _new_ = _new_
}
