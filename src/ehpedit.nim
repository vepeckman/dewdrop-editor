import jester, asyncdispatch, asyncnet, strutils, sequtils, streams

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

proc clientFile(clientFileName, fileText, fileLang: string): string =
    result = ""
    for clientFile in clientFiles:
        if clientFile[0] == clientFileName:
            result = clientFile[1]
                .replace("\"EHPEDIT_TEXT_VALUE\"", "`" & fileText & "`")
                .replace("EHPEDIT_LANG_VALUE", fileLang)

proc serveFile(port = 8080, file: string): int =
    fileText = readFile(file)
    fileLang = determineLanguage(file)

    settings:
        port = Port(port)

    routes:
        post "/api/save":
            saveFile(file, request.body)
            resp ""

        get "/@clientFile":
            echo @"clientFile"
            resp clientFile(@"clientFile", fileText, fileLang)

    var server = initJester(settings)
    server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
