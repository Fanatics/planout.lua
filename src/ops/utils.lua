package.path = package.path .. ";../?.lua"
require("core")

local operators = {
    'literal' = Literal,
    'get' = Get,
    'set' = Set,
    'seq' = Seq,
    'return' = Return,
    'index' = Index,
    'array' = Arr,
    'equals' = Equals,
    'and' = And,
    'or' = Or,
    ">" = GreaterThan,
    "<" = LessThan,
    ">=" = GreaterThanOrEqualTo,
    "<=" = LessThanOrEqualTo,
    "%" = Mod,
    "/" = Divide,
    "not" = Not,
    "round" = Round,
    "negative" = Negative,
    "min" = Min,
    "max" = Max,
    "length" = Length,
    "coalesce" = Coalesce,
    "map" = Map,
    "cond" = Cond,
    "product" = Product,
    "sum" = Sum,
    "randomFloat" = RandomFloat,
    "randomInteger" = RandomInteger,
    "bernoulliTrial" = BernoulliTrial,
    "bernoulliFilter" = BernoulliFilter,
    "uniformChoice" = UniformChoice,
    "weightedChoice" = WeightedChoice,
    "sample" = Sample
  }

function operatorInstance(params)
  if params.op == nil or operators[params.op] == nil then error "Unknown Operator" end
  return operators[params.op]:new(params)
end
