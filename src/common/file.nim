import strutils
import karax/kbase

when defined(js):
  import jsffi
else:
  import json, streams

type
  FileData* = ref object
    text, lang, id, path: kstring
    unsavedChanges: bool

proc ks(): kstring = kstring("")

proc id*(file: FileData): kstring = 
  if isNil(file): ks() else: file.id
proc path*(file: FileData): kstring = 
  if isNil(file): ks() else: file.path
proc text*(file: FileData): kstring = 
  if isNil(file): ks() else: file.text
proc `text=`*(file: FileData, text: kstring) =
  file.text = text
proc lang*(file: FileData): kstring = 
  if isNil(file): ks() else: file.lang
proc unsavedChanges*(file: FileData): bool =
  if isNil(file): false else: file.unsavedChanges
proc `unsavedChanges=`*(file: FileData, unsavedChanges: bool) =
  file.unsavedChanges = unsavedChanges

proc `==`(f1, f2: FileData): bool = f1.id == f2.id


when defined(js):
  proc toFileData*(data: JsObject): FileData =
    FileData(
      text: to(data.text, kstring),
      lang: to(data.lang, kstring),
      id: to(data.id, kstring),
      path: to(data.path, kstring),
      unsavedChanges: to(data.unsavedChanges, bool))

  proc toFileSeq*(data: JsObject): seq[FileData] =
    for it in data.items:
      result.add(toFileData(it))


else:
  proc toJs*(file: FileData): JsonNode =
    result = %* {
      "text": file.text,
      "lang": file.lang,
      "id": file.id,
      "path": file.path,
      "unsavedChanges": file.unsavedChanges
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
      path: path,
      id: path.replace('/', '.'),
      text: readFile(path),
      lang: determineLanguage(path),
      unsavedChanges: false
    )

  proc saveFile*(file: FileData, text: string) =
      var fileStream = openFileStream(file.path, fmWrite)
      fileStream.write(text)
      fileStream.close()
      file.text = text
