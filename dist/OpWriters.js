'use strict'

class OpWriter {

  constructor(settings, luaClass) {
    this.settings = settings

    if(typeof(luaClass) === "function") {
      this.luaWriter = new luaClass(settings)
    } else if(typeof(luaClass) === "string") {
      this.luaWriter = new LuaCodeFinder(settings, luaClass)
    }
  }

  write(buffer, children) {
    this.beginWrite(buffer)
    children.forEach((child) => child.write(buffer))
    this.endWrite(buffer)
  }

  beginWrite(buffer) {
    buffer.push(this.luaWriter.writeStandard(this.settings.var))
  }

  endWrite(buffer) {

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
    }
  }
}

class SeqOpWriter extends OpWriter {

}

class CondOpWriter extends OpWriter {
  constructor(settings, luaClass) {
    super(settings, luaClass)
    this.instanceId = CondOpWriter.instance++
  }


  beginWrite(buffer) {
    var id = this.instanceId
    var result = `my_input['specific_goal']`
    buffer.push(`
      
    local cond_${id} = ${result}
    if cond_${id} and cond_${id} ~=0 then`)
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
  }

  writeStandard(variable, childList, needsExecuting) {

  }
}

class LuaCodeFinder extends LuaCodeWriter {


  evaluateChildren(childList) {

  }

  writeStandard(variable, childList, needsExecuting) {
    const operation = this.luaOp
    const children = this.evaluateChildren(childList)
    return `

    assigment:set('${variable}', ${operation}:new({
      ${children}
    }))
    my_input['${variable}'] = assigment:get('${variable}')` + (needsExecuting ? `:simpleExecute()` : ``)
  }
}
module.exports = { OpWriter, GetWriter, SeqOpWriter, CondOpWriter, LuaCodeWriter }
