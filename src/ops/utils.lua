package.path = package.path .. ";../?.lua"

local core = require("ops.core")
local random = require("ops.random")

local operators = {
    ['literal'] = core.Literal,
    ['get'] = core.Get,
    ['set'] = core.Set,
    ['seq'] = core.Seq,
    ['return'] = core.Return,
    ['index'] = core.Index,
    ['array'] = core.Arr,
    ['equals'] = core.Equals,
    ['and'] = core.And,
    ['or'] = core.Or,
    ['>'] = core.GreaterThan,
    ['<'] = core.LessThan,
    ['>='] = core.GreaterThanOrEqualTo,
    ['<='] = core.LessThanOrEqualTo,
    ['%'] = core.Mod,
    ['/'] = core.Divide,
    ['not'] = core.Not,
    ['round'] = core.Round,
    ['negative'] = core.Negative,
    ['min'] = core.Min,
    ['max'] = core.Max,
    ['length'] = core.Length,
    ['coalesce'] = core.Coalesce,
    ['map'] = core.Map,
    ['cond'] = core.Cond,
    ['product'] = core.Product,
    ['sum'] = core.Sum,
    ['randomFloat'] = random.RandomFloat,
    ['randomInteger'] = random.RandomInteger,
    ['bernoulliTrial'] = random.BernoulliTrial,
    ['bernoulliFilter'] = random.BernoulliFilter,
    ['uniformChoice'] = random.UniformChoice,
    ['weightedChoice'] = random.WeightedChoice,
    ['sample'] = random.Sample
  }

local operatorInstance = function(params)
  if params.op == nil or operators[params.op] == nil then error "Unknown Operator" end
  return operators[params.op]:new(params)
end

return {
  operatorInstance = operatorInstance,
  operators = operators
}
