import jester, asyncdispatch, asyncnet, strutils, sequtils, streams, json

const clientDir = "../build/client"
const clientFiles = staticExec("ls " & clientDir)
                        .split(Whitespace)
                        .mapIt((it, staticRead(clientDir & "/" & it)))

var fileText = ""
var fileLang = ""

proc determineLanguage(path: string): string =
    let fileParts = path.split('.')
    let fileExtension = fileParts[fileParts.len - 1]
    
    result = case fileExtension
    of "js": "javascript"
    of "yaml": "yaml"
    else: ""

proc saveFile(file, text: string) =
    var fileStream = openFileStream(file, fmWrite)
    fileStream.write(text)
    fileStream.close()
    fileText = text

proc clientFile(clientFileName: string): string =
    result = ""
    for clientFile in clientFiles:
        if clientFile[0] == clientFileName:
            result = clientFile[1]

proc serveFile(port = 8080, file: string): int =
    fileText = readFile(file)
    fileLang = determineLanguage(file)

    settings:
        port = Port(port)

    routes:
      get "/api/file/@fileName/text":
        let data = %* {
          "text": fileText,
          "lang": fileLang
        }
        resp data

      put "/api/file/@fileName/text":
        saveFile(file, request.body)
        resp ""

      get "/client/@clientFile":
        resp clientFile(@"clientFile")

      get "/index.html":
        resp clientFile("index.html")

    var server = initJester(settings)
    server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
