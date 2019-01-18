import jsffi, dom
import karax/kbase
import ../common/file

let ace = require("ace-builds/src-noconflict/ace")
discard require("ace-builds/src-noconflict/theme-monokai")
discard require("ace-builds/src-noconflict/mode-javascript")

var editor: JsObject

proc setupEditor*() =
  ace.config.set(cstring"basePath", cstring"client")
  editor = ace.edit("editor-element")
  editor.setTheme("ace/theme/monokai")
  editor.session.setMode("ace/mode/javascript")
  
proc updateEditor*(file: FileData) = 
  editor.setValue(file.text, -1)
proc getEditorText*(): kstring = editor.getValue().to(kstring)
