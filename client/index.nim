import jsffi, sugar


proc fetch(uri: cstring): JsObject {. importc .}
proc fetch(uri: cstring, data: JsObject): JsObject {. importc .}
var location {.nodecl, importc.}: JsObject

let editor = require("./editor.js")
let fileApi = cstring("/api/files") & to(location.pathname, cstring) & cstring("/text");

editor.setupEditor()
fetch(fileApi)
  .then(proc (resp: JsObject): JsObject = resp.json())
  .then(proc (fileData: JsObject) = editor.updateEditor(fileData))
