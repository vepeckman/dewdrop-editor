import sugar, strformat
import jsffi except `&`
import karax/[vstyles, jdict]
include karax / prelude


proc fetch(uri: cstring): JsObject {. importc .}
proc fetch(uri: cstring, data: JsObject): JsObject {. importc .}
var location {.nodecl, importc.}: JsObject

let editor = require("./editor.js")
let fileApi = cstring("/api/files") & to(location.pathname, cstring) & cstring("/text");


proc buttonComponent(txt: string, id = "", color = "blue", onclick: (Event, VNode) -> void = (e: Event, n: VNode) => nil): VNode =
  result = buildHtml():
    button(id=id, class=fmt"bg-{color} hover:bg-{color}-dark text-white font-bold py-2 px-4 rounded mx-6 my-6"):
      text txt

proc render(): VNode =
  var styles = newJSeq[cstring](4)
  styles.add(cstring("min-height"))
  styles.add(cstring("500px"))
  styles.add(cstring("border"))
  styles.add(cstring("1px solid #ccc"))
  result = buildHtml(tdiv):
    tdiv(id="header"):
      text "Dewdrop"
    tdiv(id="file-container"):
      text "Files"
    tdiv(style=styles, class="mx-6", id="editor-container")
    tdiv(id="lower-control-panel", class="flex"):
      buttonComponent("Save", id = "savebtn", color = "green")
    tdiv(id="footer"):
      text "Made by me"

proc postRender() =
  echo "After render"
  editor.setupEditor()
  fetch(fileApi)
    .then(proc (resp: JsObject): JsObject = resp.json())
    .then(proc (fileData: JsObject) = editor.updateEditor(fileData))
  
setRenderer(render, cstring("root"), postRender)
