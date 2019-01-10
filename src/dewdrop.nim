import jester, asyncdispatch, asyncnet, strutils, sequtils, streams, json, sugar

type 
  FileData = ref object
    path, id, text, lang: string

const clientDir = "../build/client"
const clientFiles = staticExec("ls " & clientDir)
                        .split(Whitespace)
                        .mapIt((it, staticRead(clientDir & "/" & it)))

var files: seq[FileData]

proc determineLanguage(path: string): string =
    let fileParts = path.split('.')
    let fileExtension = fileParts[fileParts.len - 1]
    
    result = case fileExtension
    of "js": "javascript"
    of "yaml": "yaml"
    else: ""

proc newFileData(path: string): FileData =
  FileData(
    text: readFile(path),
    lang: determineLanguage(path),
    path: path,
    id: path.replace('/', '.')
  )

proc saveFile(file: FileData, text: string) =
    var fileStream = openFileStream(file.path, fmWrite)
    fileStream.write(text)
    fileStream.close()
    file.text = text

proc clientFile(clientFileName: string): string =
    result = ""
    for clientFile in clientFiles:
        if clientFile[0] == clientFileName:
            result = clientFile[1]

proc serveFile(port = 8080, filenames: seq[string]): int =
  if filenames.len < 1:
    echo "Dewdrop requires one or more files"
    return 0

  files = filenames.mapIt(newFileData(it))

  settings:
      port = Port(port)

  routes:
    get "/api/files":
      var data = newJArray()
      for file in files:
        let fileJson = %* {
          "lang": file.lang,
          "text": file.text,
          "id": file.id
        }
        data.add(fileJson)
      resp data

    get "/api/files/@id/text":
      let matchingFiles = files.filterIt(it.id == @"id")
      cond matchingFiles.len > 0
      let file = matchingFiles[0]
      let data = %* {
        "text": file.text,
        "lang": file.lang
      }
      resp data

    put "/api/files/@id/text":
      let matchingFiles = files.filterIt(it.id == @"id")
      cond matchingFiles.len > 0
      let file = matchingFiles[0]
      saveFile(file, request.body)
      resp ""

    get "/client/@clientFile":
      resp clientFile(@"clientFile")

    get "/@id":
      resp clientFile("index.html")

  var server = initJester(settings)
  server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
