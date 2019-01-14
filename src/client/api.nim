import jsffi, asyncjs, sugar
import karax/karax
import ../common/file, fetch, editor

var MetaDataStore*: seq[FileMetaData]

proc getFiles*(): Future[seq[FileMetaData]]  =
  fetch(cstring("/api/files"))
    .then((resp: JsObject) => resp.json()) 
    .then((data: JsObject) => toFileMetaDataSeq(data))

proc getFile*(id: cstring): Future[FileData] =
  let fileUri = cstring("/api/files/") & id & cstring("/text");
  fetch(fileUri)
    .then((resp: JsObject) => resp.json())
    .then((data: JsObject) => toFileData(data))

proc updateMetaData*() {. async, discardable .} =
  let files = await getFiles()
  MetaDataStore = files
  if not isNil(kxi):
    kxi.redraw()

proc updateFileData*(metaData: FileMetaData) {. async, discardable .} =
  let file = await getFile(metaData.id)
  monaco.updateEditor(file)

updateMetaData()
