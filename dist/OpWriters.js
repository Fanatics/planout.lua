'use strict'

class OpWriter {

  constructor(settings, luaClass) {
    this.settings = settings

    if(typeof(luaClass) === "function") {
      this.luaWriter = new luaClass(settings)
    } else if(typeof(luaClass) === "string") {
      this.luaWriter = new LuaOpWriter(settings, luaClass)
    }
  }

  write(buffer) {
    this.beginWrite(buffer)

    this.endWrite(buffer)
  }

  beginWrite(buffer) {
    buffer.push(this.luaWriter.writeStandard(this.settings.var))
  }

  endWrite(buffer) {

  }

  setProp(name, value) {
    if(this.properties === undefined) {
      this.properties = {}
    }
    if(this.properties[name] === undefined) {
      this.properties[name] = value
    }
    this.luaWriter.setProp(name, value)
  }
}

class GetWriter extends OpWriter {
  beginWrite(buffer) {
    var prop = this.settings.var
    buffer.push( `my_input['${prop}']`)
  }
}

class SetWriter extends OpWriter {
  endWrite(buffer) {
    if(typeof(this.settings.value) !== "object") {
      var prop = this.settings.var
      var val = JSON.stringify(this.settings.value)
      buffer.push( `my_input['${prop}'] = ${val}`)
    } else {
      this.properties.value.write(buffer)
    }
  }
}

class SeqOpWriter extends OpWriter {

  beginWrite(buffer) {
    let children = this.properties["seq"]
    if(children !== undefined && children.length > 0) {
      children.forEach((child) => {
        if(typeof(child.write) === "function") {
          child.write(buffer)
        }
      })
    }
  }
}

class CondOpWriter extends OpWriter {
  constructor(settings, luaClass) {
    super(settings, luaClass)
  }


  beginWrite(buffer) {
    let conditions = this.properties.cond
    conditions.forEach((cond) => {
      let id = CondOpWriter.instance++
      let buffTemp = []
      cond.ifCond.writer.write(buffTemp)
      let result = buffTemp.join("")
      buffer.push(`

    local cond_${id} = ${result}
    if cond_${id} and cond_${id} ~=0 then`)

      cond.thenAction.writer.write(buffer)
    })
  }

  endWrite(buffer) {
    buffer.push(`
    end\n`)
  }
}

CondOpWriter.instance = 0

class LuaCodeWriter {
  constructor(settings, luaOp) {
    this.luaOp = luaOp
    this.properties = {}
  }

  setProp(name, value) {
    if(this.properties[name] === undefined) {
      this.properties[name] = value
    }
  }

  writeStandard(variable, childList, needsExecuting) {
  }
}

class LuaOpWriter extends LuaCodeWriter {

  evalProp(prop) {
    let val = this.properties[prop]
    let tempBuff = []
    tempBuff.push(`['${prop}'] = `)
    if(typeof(val) === "object" &&
      typeof(val.write) === "function" ) {
      val.write(tempBuff)
    } else if(val instanceof Array) {
      tempBuff.push("{", val.map(this.evalArrProp.bind(this)), "}")
    } else {
      tempBuff.push(val)
    }
    return tempBuff.join("")
  }

  evalArrProp(val) {
    let tempBuff = []
    if(typeof(val) === "object" &&
      typeof(val.write) === "function" ) {
      val.write(tempBuff)
    } else if(val instanceof Array) {
      return val.map(this.evalArrProp.bind(this))
    } else {
      tempBuff.push(val)
    }
    return tempBuff.join("")
  }

  evaluateChildren() {
    var buff = Object.keys(this.properties).map(this.evalProp.bind(this))
    return buff.join(", ")
  }

  writeStandard(variable, needsExecuting) {
    const operation = this.luaOp
    const children = this.evaluateChildren()
    return `

    assigment:set('${variable}', ${operation}:new({
      ${children}
    }))
    my_input['${variable}'] = assigment:get('${variable}')` + (needsExecuting ? `:simpleExecute()` : ``)
  }
}
module.exports = { OpWriter, GetWriter, SeqOpWriter, CondOpWriter, LuaCodeWriter, SetWriter }
