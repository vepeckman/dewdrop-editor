import sugar, strformat, asyncjs
import jsffi except `&`
import ../common/file, api, editor
import karax / [kbase, vdom, kdom, vstyles, karax, karaxdsl, jdict, jstrutils, jjson, reactive]

var console {.nodecl, importc.}: JsObject

let babelPolyfill = require("babel-polyfill")


proc buttonComponent(txt: string, id = "", color = "blue", onclick: (Event, VNode) -> void = (e: Event, n: VNode) => nil): VNode =
  result = buildHtml():
    button(id=id, class=fmt"bg-{color} hover:bg-{color}-dark text-white font-bold py-2 px-4 rounded mx-6 my-6"):
      proc onClick(ev: Event, n: VNode) = saveCurrentFile()
      text txt


proc fileSelector(file: FileMetaData): proc (ev: Event, n: VNode) =
  # Needed because the reference to "file" in the karax dsl
  # isn't a closure. 
  proc onClick(ev: Event, n: VNode) = 
    echo file.path
    updateFileData(file)
  result = onClick

proc fileListComponent(): VNode =
  result = buildHtml():
    tdiv(class = "pl-6 flex flex-col"):
      text "Files:"
      for file in MetaDataStore:
        a(href = "/#", class = "text-blue hover:text-blue-dark pl-4 py-4", onclick = fileSelector(file)):
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
  
setRenderer(render, cstring("root"))
setForeignNodeId(cstring("editor-container"))
kxi.redrawSync()
monaco.setupEditor()
