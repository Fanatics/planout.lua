require "redis-lib"
--<<--

return (function(keys, args)

  -- Lib --
  local _new_ = function(self, instance)
    instance = instance or {}
    setmetatable(instance, self)
    self.__index = self
    return instance
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

  local hex2bc = function(s)
  	local x=0
  	for i=1,#s do
  		x=16*x+tonumber(s:sub(i,i),16)
  	end
  	return x
  end

  local instanceOf = function (subject, super)
  	super = tostring(super)
  	local mt = getmetatable(subject)

  	while true do
  		if mt == nil then return false end
  		if tostring(mt) == super then return true end

  		mt = getmetatable(mt)
  	end
  end

  local merge = function(results, ...)
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

  local Product = PlanOutOpCommutative:new()

  function Product:commutativeExecute(values)
    local result = 1
    for i, val in ipairs(values) do
      result = result * val
    end
    return result
  end

  -- Random --
  local PlanOutOpRandom = PlanOutOpSimple:new()

  local LONG_SCALE = hex2bc("FFFFFFFFFF")

  function PlanOutOpRandom:init(args)
    self.args = args
    self.LONG_SCALE = LONG_SCALE
    return self
  end

  function PlanOutOpRandom:getUnit(appendedUnit)
    local unit = self:getArgMixed('unit')
    if type(unit) ~= "table" or unit[1] == nil then unit = {unit} end
    if appendedUnit ~= nil then table.insert(unit, appendedUnit) end
    return unit
  end

  function PlanOutOpRandom:getUniform(minVal, maxVal, appendedUnit)
    minVal = minVal or 0.0
    maxVal = maxVal or 1.0
    local zeroToOne = self:getHash(appendedUnit) / self.LONG_SCALE
    return zeroToOne * (maxVal - minVal) + (minVal)
  end

  function PlanOutOpRandom:getHash(appendedUnit)
    local fullSalt
    if self.args.full_salt ~= nil then fullSalt = self:getArgString('full_salt')
    else
      local salt = self:getArgString('salt')
      fullSalt = self.mapper:get('experimentSalt') .. "." .. salt
    end
    local unitArr = {}
    for i, v in pairs(self:getUnit(appendedUnit)) do
      table.insert(unitArr, v)
    end
    local unitStr = table.concat(unitArr, ".")
    local hashStr = fullSalt .. "." .. unitStr
    local hash = redis.sha1hex(hashStr)
    return hex2bc(string.sub(hash, 0, 10))
  end

  local BernoulliTrial = PlanOutOpRandom:new()

  function BernoulliTrial:simpleExecute()
    local p = self:getArgNumber('p');
    if p < 0 or p > 1 then error "Invalid probability"; end
    if self:getUniform(0.0, 1.0) <= p then return 1 else return 0 end
  end

  local UniformChoice = PlanOutOpRandom:new()

  function UniformChoice:simpleExecute()
    local values = self:getArgList('choices')
    if #values == 0 then return {} end
    local rand_index = (self:getHash() % #values) + 1
    return values[rand_index]
  end

  local Assignment = {}

  function Assignment:new(experimentSalt, overrides)
    return _new_(self, {}):init(experimentSalt, overrides)
  end

  function Assignment:init(experimentSalt, overrides)
    if type(overrides) ~= "table" then overrides = {} end
    self.experimentSalt = experimentSalt
    self.overrides = shallowcopy(overrides)
    self.data = shallowcopy(overrides)
    return self
  end

  function Assignment:evaluate(value)
    return value
  end

  function Assignment:getOverrides()
    return self.overrides
  end

  function Assignment:addOverride(key, value)
    self.overrides[key] = value
    self.data[key] = value
  end

  function Assignment:setOverrides(overrides)
    self.overrides = shallowcopy(overrides)
    for k, v in pairs(self.overrides) do self.data[k] = v end
  end

  function Assignment:set(name, value)
    if name == "_data" then self.data = value return
    elseif name == "_overrides" then self.overrides = value return
    elseif name == "experimentSalt" then self.experimentSalt = value return end

    if self.overrides[name] ~= nil then return end
    if instanceOf(value, PlanOutOpRandom) then
      if value.args.salt == nil then value.args.salt = name end
      self.data[name] = value:execute(self)
    else
      self.data[name] = value
    end
  end

  function Assignment:get(name)
    if name == "_data" then return self.data
    elseif name == "_overrides" then return self.overrides
    elseif name == "experimentSalt" then return self.experimentSalt
    else return self.data[name] end
  end

  function Assignment:getParams()
    return self.data
  end

  function Assignment:del(name)
    this.data[name] = nil
  end

  function Assignment:toString()
    return cjson.encode(self.data)
  end

  function Assignment:length()
    return tablelength(self.data)
  end

  return (function(my_input)
    local var = cjson.decode(redis.call("get", args[1]))

    local status, err = pcall(function() merge(my_input, var) end)
    if not status then return cjson.encode(err) end

    local user_id_assigment = Assignment:new(my_input['salt'])

    user_id_assigment:set('group_size', UniformChoice:new({
      ['choices'] = {1,10},
      ['unit'] = my_input['user_id']
    }))
    my_input['group_size'] = user_id_assigment:get('group_size')

    user_id_assigment:set('specific_goal', BernoulliTrial:new({
      ['p'] = 0.8,
      ['unit'] = my_input['user_id']
    }))
    my_input['specific_goal'] = user_id_assigment:get('specific_goal')

    local cond_1 = my_input['specific_goal']
    if cond_1 and cond_1 ~=0 then
      user_id_assigment:set('ratings_per_user_goal', UniformChoice:new({
        ['choices'] = {8,16,32,64},
        ['unit'] = my_input['user_id']
      }))
      my_input['ratings_per_user_goal'] = user_id_assigment:get('ratings_per_user_goal')

      local ratings_goal_product_arr = {
        my_input['group_size'],
        my_input['ratings_per_user_goal']
      }
      user_id_assigment:set('ratings_goal', Product:new({
        ['values'] = ratings_goal_product_arr
      }))
      my_input['ratings_goal'] = user_id_assigment:get('ratings_goal'):simpleExecute()
    end

    return cjson.encode(my_input)
  end)({
    ['user_id'] = 123454,
    ['salt'] = 'foo'
  })

end)(KEYS, ARGV)
