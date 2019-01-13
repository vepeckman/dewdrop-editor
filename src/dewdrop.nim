import jester, asyncdispatch, asyncnet, sequtils, json, sugar, strutils, os
import common/file

when defined(release):
  const clientDir = "../build/client"
  const clientFiles = staticExec("ls " & clientDir)
                          .split(Whitespace)
                          .mapIt((it, staticRead(clientDir & "/" & it)))

var files: seq[FileData]

when defined(release):
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

  when not defined(release):
    settings:
        port = Port(port)
        staticDir = getCurrentDir() / "build"
  else:
    settings:
        port = Port(port)

  when not defined(release):
    routes:
      get "/api/files":
        var data = newJArray()
        for file in files:
          data.add(file.metaData.toJs)
        resp data

      get "/api/files/@id/text":
        let matchingFiles = files.filterIt(it.id == @"id")
        cond matchingFiles.len > 0
        resp matchingFiles[0].toJs

      put "/api/files/@id/text":
        let matchingFiles = files.filterIt(it.id == @"id")
        cond matchingFiles.len > 0
        let file = matchingFiles[0]
        saveFile(file, request.body)
        resp ""

      get "/":
        resp readFile("./build/client/index.html")

  else:
    routes:
      get "/api/files":
        var data = newJArray()
        for file in files:
          data.add(file.metaData.toJs)
        resp data

      get "/api/files/@id/text":
        let matchingFiles = files.filterIt(it.id == @"id")
        cond matchingFiles.len > 0
        resp matchingFiles[0].toJs

      put "/api/files/@id/text":
        let matchingFiles = files.filterIt(it.id == @"id")
        cond matchingFiles.len > 0
        let file = matchingFiles[0]
        saveFile(file, request.body)
        resp ""

      get "/client/@clientFile":
        resp clientFile(@"clientFile")

      get "/":
        resp clientFile("index.html")

  var server = initJester(settings)
  server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
