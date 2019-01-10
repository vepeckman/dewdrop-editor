import sugar
import jsffi except `&`
import karax/[vstyles, jdict]
include karax / prelude


proc fetch(uri: cstring): JsObject {. importc .}
proc fetch(uri: cstring, data: JsObject): JsObject {. importc .}
var location {.nodecl, importc.}: JsObject

let editor = require("./editor.js")
let fileApi = cstring("/api/files") & to(location.pathname, cstring) & cstring("/text");


proc render(): VNode =
  var styles = newJSeq[cstring](4)
  styles.add(cstring("height"))
  styles.add(cstring("600px"))
  styles.add(cstring("border"))
  styles.add(cstring("1px solid #ccc"))
  result = buildHtml(tdiv):
    tdiv(style=styles, class="mx-6 mt-6 w-3/5", id="container")
    button(id="savebtn", class="bg-blue hover:bg-blue-dark text-white font-bold py-2 px-4 rounded mx-6 my-6"):
      text "Save"

proc postRender() =
  echo "After render"
  editor.setupEditor()
  fetch(fileApi)
    .then(proc (resp: JsObject): JsObject = resp.json())
    .then(proc (fileData: JsObject) = editor.updateEditor(fileData))
  
setRenderer(render, cstring("root"), postRender)
