'use strict'
class OpWriter {
  get hasGeneratedCode() { return true }

  constructor(settings) {
    this.settings = settings
  }

  beginWrite(buffer) {

  }

  write() {
    throw "Not Implemented"
  }

  endWrite(buffer) {
    
  }
}

class GetWriter extends OpWriter {
  write() {
    var prop = this.settings.var
    return `my_input['${prop}']`
  }
}

class SeqOpWriter extends OpWriter {
  get hasGeneratedCode() { return false }
}

class CondOpWriter extends OpWriter {
  get hasGeneratedCode() { return false }
}

module.exports = { OpWriter, GetWriter, SeqOpWriter, CondOpWriter }
