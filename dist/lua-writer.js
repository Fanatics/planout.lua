var writer = {}
var EventEmitter = require("./EventEmitter")

const PREAMBLE = `local arguments = {}
local success, errState = pcall(function()
  if #KEYS == #ARGV then
    for i, keyname in ipairs(KEYS) do arguments[keyname: ARGV[i] end
  end
end)
if not success then return cjson.encode(arguments) end

return (function(args)`

const POST = `
  return cjson.encode(my_input)
end)(args)`

const ACTION = `return (function(my_input)
  local var = cjson.decode(redis.call("get", args['domain']))

  local status, err = pcall(function() merge(my_input, var) end)
  if not status then return cjson.encode(err) end

  local user_id_assigment = Assignment:new(my_input['salt'])`

const ACTION_END = `
  return cjson.encode(my_input)
end)(args)`

const required_func = [
  '_new_',
  'shallowcopy',
  'hex2bc',
  'instanceOf',
  'merge',
  'jsIs'
]

const required_class = [
  'PlanOutOp',
  'PlanOutOpSimple',
  'PlanOutOpRandom',
  'Assignment'
]

class OpWriter {
  constructor(settings) {
    this.settings = settings
  }
}

class ValueParser {
  constructor(settings) {
    this.settings = settings
  }

  getPropertyName() {
    return 'value'
  }

  prepare() {
    var val = this.settings[this.getPropertyName()]

    if(val && val.op) {
      search(val)
    }
  }
}

class VarParser extends ValueParser {
  getPropertyName() {
    return 'var'
  }
}

class ValuesParser extends ValueParser {
  getPropertyName() {
    return 'values'
  }
}

class SequenceParser extends ValueParser {
  prepare() {
    var val = this.settings['seq']

    if(val instanceof Array) {
        val.forEach((item) => search(item))
    }
  }
}

class CondParser extends ValueParser {
  getPropertyName() {
    return 'if'
  }
}

class BinaryParser extends ValueParser {
  prepare() {
    var val = this.settings['left']

    if(val && val.op) {
      search(val)
    }

    val = this.settings['right']

    if(val && val.op) {
      search(val)
    }
  }
}

const ops = {
  'literal': {'lua-class': "Literal", 'parser': ValueParser},
  'get': {'lua-class': "Get", 'parser': VarParser},
  'set': {'lua-class': "Set", 'parser': ValueParser},
  'seq': {'lua-class': "Seq", 'parser': SequenceParser},
  'return': {'lua-class': "Return", 'parser': ValueParser},
  'index': {'lua-class': "Index", 'parser': ValueParser},
  'array': {'lua-class': "Arr", 'parser': ValuesParser},
  'equals': {'lua-class': "Equals", 'parser': BinaryParser},
  'and': {'lua-class': "And", 'parser': ValuesParser},
  'or': {'lua-class': "Or", 'parser': ValuesParser},
  '>': {'lua-class': "GreaterThan", 'parser': BinaryParser},
  '<': {'lua-class': "LessThan", 'parser': BinaryParser},
  '>=': {'lua-class': "GreaterThanOrEqualTo", 'parser': BinaryParser},
  '<=': {'lua-class': "LessThanOrEqualTo", 'parser': BinaryParser},
  '%': {'lua-class': "Mod", 'parser': BinaryParser},
  '/': {'lua-class': "Divide", 'parser': BinaryParser},
  'not': {'lua-class': "Not", 'parser': ValueParser},
  'round': {'lua-class': "Round", 'parser': ValueParser},
  'negative': {'lua-class': "Negative", 'parser': ValueParser},
  'min': {'lua-class': "Min", 'parser': ValueParser},
  'max': {'lua-class': "Max", 'parser': ValueParser},
  'length': {'lua-class': "Length", 'parser': ValueParser},
  'coalesce': {'lua-class': "Coalesce", 'parser': ValuesParser},
  'map': {'lua-class': "Map", 'parser': ValueParser},
  'cond': {'lua-class': "Cond", 'parser': CondParser},
  'product': {'lua-class': "Product", 'parser': ValuesParser},
  'sum': {'lua-class': "Sum", 'parser': ValuesParser},
  'randomFloat': {'lua-class': "RandomFloat", 'parser': ValueParser},
  'randomInteger': {'lua-class': "RandomInteger", 'parser': ValueParser},
  'bernoulliTrial': {'lua-class': "BernoulliTrial", 'parser': ValueParser},
  'bernoulliFilter': {'lua-class': "BernoulliFilter", 'parser': ValueParser},
  'uniformChoice': {'lua-class': "UniformChoice", 'parser': ValueParser},
  'weightedChoice': {'lua-class': "WeightedChoice", 'parser': ValueParser},
  'sample': {'lua-class': "Sample", 'parser': ValueParser}
}

const ops_dependencies = {
  'return': ['StopPlanOutException'],
  'equals': ['PlanOutOpBinary'],
  '>': ['PlanOutOpBinary'],
  '<': ['PlanOutOpBinary'],
  '>=': ['PlanOutOpBinary'],
  '<=': ['PlanOutOpBinary'],
  '%': ['PlanOutOpBinary'],
  '/': ['PlanOutOpBinary'],
  'not': ['PlanOutOpUnary'],
  'round': ['PlanOutOpUnary'],
  'negative': ['PlanOutOpUnary'],
  'min': ['PlanOutOpCommutative'],
  'max': ['PlanOutOpCommutative'],
  'length': ['PlanOutOpUnary'],
  'map': ['deepcopy'],
  'product': ['PlanOutOpCommutative'],
  'sum': ['PlanOutOpCommutative']
}

var found_ops = {}
var dependency_funcs = {}
var dependency_class = {}
var sequence = []

EventEmitter.onSync("object.op", function(event, settings, op) {
  found_ops[op] = true

  if(ops[op]) {
    var parser = new (ops[op].parser || ValueParser)(settings)
    var opWriter = new (ops[op].opWriter || OpWriter)(settings)
    sequence.push({ parser, opWriter })
    parser.prepare();
  }
})

function search(input) {
  if(input instanceof Array) {
    input.forEach((item) => {
      search(item)
    })
  } else if(input instanceof Object) {
    if(input.op) {
      EventEmitter.trigger(`object.op`, input, input.op)
    }
  }
}

writer.parse = function parse(input) {
  search(input)

  console.log(found_ops)
  Object.keys(found_ops).forEach((item) => {
    var dep = ops_dependencies[item]
    if(dep instanceof Array) {
      dep.forEach((name) => {

      })
    }
  })
}

module.exports = writer
