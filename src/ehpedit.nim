import jester, asyncdispatch, asyncnet, strutils, sequtils

# TODO: Determine language from extension
# TODO: expose route for updating file

const clientDir = "../build/dist"
const clientFiles = staticExec("ls " & clientDir)
                        .split(Whitespace)
                        .mapIt("/" & it)
                        .mapIt((it, staticRead(clientDir & it)))


proc serveFile(path: string): int =
    var fileText = readFile(path)
    var fileLang = "javascript"

    proc match(request: Request): Future[ResponseData] {.async.} =
        block route:
            var fileFound = false
            for clientFile in clientFiles:
                if clientFile[0] == request.pathInfo:
                    resp clientFile[1]
                        .replace("\"EHPEDIT_TEXT_VALUE\"", "`" & fileText & "`")
                        .replace("EHPEDIT_LANG_VALUE", fileLang)
                    fileFound = true
            if not fileFound:
                resp "Not found"

    var server = initJester(match)
    server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
