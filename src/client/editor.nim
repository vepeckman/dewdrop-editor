import jsffi, dom, macros
import karax/kbase
import ../common/file, fetch

proc lazyImport(path: cstring): Future[JsObject] {. nodecl, importcpp: "import(@)" .}
let ace = require("ace-builds/src-noconflict/ace")

var editor: JsObject

proc setupEditor*() =
  editor = ace.edit("editor-element")
  discard lazyImport(cstring"ace-builds/src-noconflict/theme-xcode").then(proc (module: JsObject) = editor.setTheme(cstring"ace/theme/xcode"))
  
macro importLang(lang: static[string]): untyped =
  result = newStmtList()
  let promise = ident("promise")
  let importStr = newCall(ident("cstring"), newStrLitNode("ace-builds/src-noconflict/mode-" & lang))
  let importCall = newCall(ident("lazyImport"), importStr)
  result.add(newLetStmt(promise, importCall))
  result.add(quote do:
    discard `promise`.then(proc (module: JsObject) = editor.session.setMode("ace/mode/" & `lang`))
    )

proc updateLanguage(file: FileData) =
  case $file.lang
  of "javascript": 
    importLang("javascript")
  of "yaml":
    importLang("yaml")

proc updateEditor*(file: FileData) = 
  editor.setValue(file.text, -1)
  updateLanguage(file)

proc getEditorText*(): kstring = editor.getValue().to(kstring)
