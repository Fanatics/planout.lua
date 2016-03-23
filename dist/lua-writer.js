'use strict'
var writer = {}
var EventEmitter = require("./EventEmitter")
var { OpWriter, GetWriter, SeqOpWriter, CondOpWriter, LuaCodeWriter, SetWriter } = require("./OpWriters")

const PREAMBLE = `local arguments = {}
local arguments = cjson.decode(ARGV[1])

return (function(args)
`

const POST = `
end)(arguments)
`

const ACTION = `
  return (function(my_input)
  local doName = "do-" .. args['domain']
  if args["_do"] ~= nil and redis.call("EXISTS", args["_do"]) == 1 then doName = args["_do"] end

  local var = cjson.decode(redis.call("get", doName))

    local status, err = pcall(function() merge(my_input, var) end)
    if not status then return cjson.encode(err) end

    local assigment = Assignment:new(my_input['salt'])`

const ACTION_END = `
    return cjson.encode(my_input)
  end)(args)
`

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

class ValueParser {
  constructor(settings, writer) {
    this.settings = settings
    this.writer = writer
  }

  getPropertyName() {
    return 'value'
  }

  prepare() {
    var val = this.settings[this.getPropertyName()]

    this.setProps(this.process(val))
  }

  setProps(item) {
    this.writer.setProp(this.getPropertyName(), item)
  }

  process(val) {
    if(val && val.op) {
      return search(val)
    } else {
      return val
    }
  }

  write(buffer) {
    this.writer.write(buffer)
  }
}

class SetParser extends ValueParser {
  process(val) {
    val.var = this.settings.var
    return super.process(val)
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

  process(val) {
    if(val instanceof Array) {
      return val.map((item) => super.process(item))
    }
  }
}

class SequenceParser extends ValuesParser {
  getPropertyName() {
    return 'seq'
  }
}

class MultiNameParser extends ValueParser {
  prepare() {
    var property = this.getPropertyName()
    property.forEach((prop) => {
      this.setProps(this.process(this.settings[prop]), prop)
    })
  }

  setProps(item, propName) {
    this.writer.setProp(propName, item)
  }
}

class CondParser extends ValueParser {
  getPropertyName() {
    return 'cond'
  }

  process(val) {
    if(val instanceof Array) {
      return val.map((item) => {
        let ifCond = search(item.if)
        let thenAction = search(item.then)
        return { ifCond, thenAction }
      })
    }
  }
}

function MakeMultiNameParser() {
  var args = arguments
  return class ExtentedParser extends MultiNameParser {
    getPropertyName() {
      return [...args]
    }
  }
}

var BinaryParser = MakeMultiNameParser("left", "right")
var RandomNumberParser = MakeMultiNameParser("min", "max", "unit")

function write_funcs(required, buffer) {
  required.forEach((func) => {
    buffer.push("\t--", func, "\n")
  })
}

function write_classes(required, buffer) {
  required.forEach((className) => {
    buffer.push("\t--", className, "\n")
  })
}

class LuaEvaluator extends LuaCodeWriter {
  writeStandard(item) {

  }
}

class ArrayEvaluator extends LuaCodeWriter {
  writeStandard(item) {

    return "{" + this.properties.values.map((val) => {
      if(typeof(val) === "object" &&
        typeof(val.write) === "function" ) {

        let tempBuff = []
        val.write(tempBuff)

        return tempBuff.join()
      } else {
        return JSON.stringify(val)
      }
    }).join(",") + "}";
  }
}

const ops = {
  'literal': {'lua-class': LuaEvaluator, 'parser': ValueParser},
  'get': {'lua-class': LuaEvaluator, 'parser': VarParser, 'opWriter': GetWriter},
  'set': {'lua-class': LuaEvaluator, 'parser': SetParser, 'opWriter': SetWriter},
  'seq': {'lua-class': LuaEvaluator, 'parser': SequenceParser, 'opWriter': SeqOpWriter},
  'return': {'lua-class': LuaEvaluator, 'parser': ValueParser},
  'index': {'lua-class': LuaEvaluator, 'parser': ValueParser},
  'array': {'lua-class': ArrayEvaluator, 'parser': ValuesParser},
  'equals': {'lua-class': LuaEvaluator, 'parser': BinaryParser},
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
  'cond': {'lua-class': LuaEvaluator, 'parser': CondParser, 'opWriter': CondOpWriter},
  'product': {'lua-class': "Product", 'parser': ValuesParser},
  'sum': {'lua-class': "Sum", 'parser': ValuesParser},
  'randomFloat': {'lua-class': "RandomFloat", 'parser': RandomNumberParser},
  'randomInteger': {'lua-class': "RandomInteger", 'parser': RandomNumberParser},
  'bernoulliTrial': {'lua-class': "BernoulliTrial", 'parser': MakeMultiNameParser("p", "unit")},
  'bernoulliFilter': {'lua-class': "BernoulliFilter", 'parser': MakeMultiNameParser("p", "choices", "unit")},
  'uniformChoice': {'lua-class': "UniformChoice", 'parser': MakeMultiNameParser("choices", "unit")},
  'weightedChoice': {'lua-class': "WeightedChoice", 'parser': MakeMultiNameParser("choices", "weights", "unit")},
  'sample': {'lua-class': "Sample", 'parser': MakeMultiNameParser("choices", "draws", "unit")}
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

function GenParser(settings, op) {
  var opers = found_ops[op]
  if(opers === undefined) {
    opers = [];
    found_ops[op] = opers;
  }
  opers.push(settings)

  if(ops[op]) {
    var opWriter = new (ops[op].opWriter || OpWriter)(settings, ops[op]['lua-class'])
    var parser = new (ops[op].parser || ValueParser)(settings, opWriter)
    parser.prepare()
    return parser
  }
}

function search(input) {
  if(input instanceof Array) {
    return input.map((item) => {
      return search(item)
    })
  } else if(input instanceof Object) {
    if(input.op) {
      return GenParser(input, input.op)
    } else {
      return Object.keys(input).map((prop) => {
        return search(input[prop])
      })
    }
  }
}

writer.parse = function parse(input) {
  var obj = search(input)

  //console.log(found_ops)
  Object.keys(found_ops).forEach((item) => {
    var dep = ops_dependencies[item]
    if(dep instanceof Array) {
      dep.forEach((name) => {
        if(name[0] == name[0].toUpperCase()) {
          dependency_class[name] = name
        } else {
          dependency_funcs[name] = name
        }
      })
    }

    if(typeof(ops[item]['lua-class']) === "string") {
      dependency_class[ops[item]['lua-class']] = ops[item]['lua-class']
    }
  })

  var funcs = required_func.concat(Object.keys(dependency_funcs))
  var clazzes = required_class.concat(Object.keys(dependency_class))

  var buffer = [PREAMBLE]
  write_funcs(funcs, buffer)
  write_classes(clazzes, buffer)
  buffer.push(ACTION)
  obj.write(buffer)
  buffer.push(ACTION_END, POST)
  return buffer.join("")
}

module.exports = writer
