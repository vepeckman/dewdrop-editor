import strutils
import karax/kbase

when defined(js):
  import jsffi
else:
  import json, streams

type
  FileMetaData* = ref object
    id, path: kstring

  FileData* = ref object
    text, lang: kstring
    metaData: FileMetaData

proc id*(data: FileMetaData): kstring = data.id
proc path*(data: FileMetaData): kstring = data.path

proc id*(file: FileData): kstring = file.metaData.id
proc path*(file: FileData): kstring = file.metaData.path
proc text*(file: FileData): kstring = file.text
proc lang*(file: FileData): kstring = file.lang
proc metaData*(file: FileData): FileMetaData = file.metaData


proc newMetaData*(path: string): FileMetaData =
  FileMetaData(path: path, id: path.replace('/', '.'))

when defined(js):
  proc toFileMetaData*(data: JsObject): FileMetaData = 
    FileMetaData(id: to(data.id, kstring), path: to(data.path, kstring))

  proc toFileMetaDataSeq*(data: JsObject): seq[FileMetaData] =
    for it in data.items:
      result.add(toFileMetaData(it))
else:
  proc toJs*(data: FileMetaData): JsonNode =
    result = %* {
      "id": data.id,
      "path": data.path
    }
  
  proc toJs*(file: FileData): JsonNode =
    result = %* {
      "text": file.text,
      "lang": file.lang,
      "id": file.id,
      "path": file.path
    }

  proc determineLanguage(path: string): string =
      let fileParts = path.split('.')
      let fileExtension = fileParts[fileParts.len - 1]
      
      result = case fileExtension
      of "js": "javascript"
      of "yaml": "yaml"
      else: ""

  proc newFileData*(path: string): FileData =
    FileData(
      text: readFile(path),
      lang: determineLanguage(path),
      metaData: newMetaData(path)
    )

  proc saveFile*(file: FileData, text: string) =
      var fileStream = openFileStream(file.path, fmWrite)
      fileStream.write(text)
      fileStream.close()
      file.text = text
