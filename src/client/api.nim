import jsffi, asyncjs, sugar
import karax/karax
import ../common/file, fetch, editor

var MetaDataStore*: seq[FileMetaData]
var CurrentFile: FileData

proc getFiles*(): Future[seq[FileMetaData]]  =
  fetch(cstring("/api/files"))
    .then((resp: JsObject) => resp.json()) 
    .then((data: JsObject) => toFileMetaDataSeq(data))

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

proc updateMetaData*() {. async, discardable .} =
  let files = await getFiles()
  MetaDataStore = files
  if not isNil(kxi):
    kxi.redraw()

proc updateFileData*(metaData: FileMetaData) {. async, discardable .} =
  let file = await getFile(metaData.id)
  Editor.updateEditor(file)
  CurrentFile = file

proc saveCurrentFile*(): Future[void] {. discardable .} = saveFile(CurrentFile)

updateMetaData()
