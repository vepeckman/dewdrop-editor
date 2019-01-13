import sugar, strformat, asyncjs
import jsffi except `&`
import ../common/file
import karax/[vstyles, jdict]
include karax / prelude

proc fetch(uri: cstring): Future[JsObject] {. importc .}
proc fetch(uri: cstring, data: JsObject): Future[JsObject] {. importc .}
proc then[T, R](promise: Future[T], next: proc (data: T): Future[R]): Future[R] {. importcpp: "#.then(@)" .}
proc then[T, R](promise: Future[T], next: proc (data: T): R): Future[R] {. importcpp: "#.then(@)" .}
proc then[T](promise: Future[T], next: proc(data: T)): Future[void] {. importcpp: "#.then(@)" .}
var console {.nodecl, importc.}: JsObject

let fileId = cstring("testfiles.test.js")
let babelPolyfill = require("babel-polyfill")
let editor = require("./editor.js")
let fileApi = cstring("/api/files/") & fileId & cstring("/text");

proc getFiles(): Future[seq[FileMetaData]]  =
  fetch(cstring("/api/files"))
    .then((resp: JsObject) => resp.json()) 
    .then((data: JsObject) => toFileMetaDataSeq(data))

proc buttonComponent(txt: string, id = "", color = "blue", onclick: (Event, VNode) -> void = (e: Event, n: VNode) => nil): VNode =
  result = buildHtml():
    button(id=id, class=fmt"bg-{color} hover:bg-{color}-dark text-white font-bold py-2 px-4 rounded mx-6 my-6"):
      text txt

var fileMetaData: seq[FileMetaData]

proc fileListComponent(): VNode =
  result = buildHtml(tdiv):
    for file in fileMetaData:
      text file.path

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
      fileListComponent()
    tdiv(id="editor-container", style=styles, class="mx-6")
    tdiv(id="lower-control-panel", class="flex"):
      buttonComponent("Save", id = "savebtn", color = "green")
    tdiv(id="footer"):
      text "Made by me"
  
let kxi = setRenderer(render, cstring("root"))
setForeignNodeId(cstring("editor-container"))

proc initData() {. async, discardable .} =
  fileMetaData = await getFiles()
  kxi.redrawSync()
  editor.setupEditor()

initData()
