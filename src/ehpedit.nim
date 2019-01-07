import jester, asyncdispatch, asyncnet, strutils, sequtils, streams

const clientDir = "../build/dist"
const clientFiles = staticExec("ls " & clientDir)
                        .split(Whitespace)
                        .mapIt("/" & it)
                        .mapIt((it, staticRead(clientDir & it)))

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

proc handleApi(request: Request, file: string): string =
    case request.pathInfo
    of "/api/save":
        saveFile(file, request.body)
        result = ""

proc handleFile(request: Request, fileText, fileLang: string): string =
    result = ""
    for clientFile in clientFiles:
        if clientFile[0] == request.pathInfo:
            result = clientFile[1]
                .replace("\"EHPEDIT_TEXT_VALUE\"", "`" & fileText & "`")
                .replace("EHPEDIT_LANG_VALUE", fileLang)

proc serveFile(port = 8080, file: string): int =
    var fileText = readFile(file)
    var fileLang = determineLanguage(file)

    proc match(request: Request): Future[ResponseData] {.async.} =
        block route:
            if request.pathInfo.startsWith("/api"):
                resp handleApi(request, file)
            else:
                resp handleFile(request, fileText, fileLang)

    settings:
        port = Port(port)

    var server = initJester(match, settings)
    server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
