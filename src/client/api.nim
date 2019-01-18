import jsffi, asyncjs, sugar
import karax/karax, karax/kbase
import ../common/file, fetch, editor

var FileDataStore*: seq[FileData]
var CurrentFile*: FileData

proc getFiles*(): Future[seq[FileData]]  =
  fetch(cstring("/api/files"))
    .then((resp: JsObject) => resp.json()) 
    .then((data: JsObject) => toFileSeq(data))

proc getFile*(id: cstring): Future[FileData] =
  let fileUri = cstring("/api/files/") & id & cstring("/text");
  fetch(fileUri)
    .then((resp: JsObject) => resp.json())
    .then((data: JsObject) => toFileData(data))

proc saveFile*(file: FileData): Future[void] =
  let fileUri = cstring("/api/files/") & file.id & cstring("/text");
  var options = newJsObject()
  options.`method` = cstring("PUT")
  options.body = Editor.getEditorText()
  fetch(fileUri, options)
    .then((resp: JsObject) => echo "ok")

proc updateFileData*(file: FileData) {. async, discardable .} =
  if not isNil(CurrentFile):
    CurrentFile.text = Editor.getEditorText().to(kstring)
  Editor.updateEditor(file)
  CurrentFile = file
  if not isNil(kxi):
    kxi.redraw()

proc saveCurrentFile*(): Future[void] {. async, discardable .} = 
  await saveFile(CurrentFile)
  CurrentFile.unsavedChanges = false
  if not isNil(kxi):
    kxi.redraw()

proc apiStartup() {. async, discardable .} =
  FileDataStore = await getFiles()
  if FileDataStore.len > 0:
    updateFileData(FileDataStore[0])
  if not isNil(kxi):
    kxi.redraw()

apiStartup()
