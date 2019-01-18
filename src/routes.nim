import strutils, sequtils, json
import common/file

when defined(release):
  const clientDir = "../build/client"
  const clientFiles = staticExec("ls " & clientDir)
                          .split(Whitespace)
                          .filterIt(not it.endsWith(".gz") and it != "report.html")
                          .mapIt((it, staticRead(clientDir & "/" & it & ".gz")))

when defined(release):
  proc clientFile(clientFileName: string): string =
      result = ""
      for clientFile in clientFiles:
          if clientFile[0] == clientFileName:
              result = clientFile[1]

template devRoutes(): untyped =
  routes:

    get "/api/files":
      var data = newJArray()
      for file in files:
        data.add(file.toJs)
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

template prodRoutes(): untyped =
  routes:

    get "/api/files":
      var data = newJArray()
      for file in files:
        data.add(file.toJs)
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
      var headers = @[("Content-Encoding", "gzip")]
      resp(Http200, headers, clientFile(@"clientFile"))

    get "/":
      var headers = @[("Content-Encoding", "gzip"), ("Content-Type", "text/html; charset=utf-8")]
      resp(Http200, headers, clientFile("index.html"))

when defined(release):
  template routes*() = prodRoutes
else:
  template routes*() = devRoutes
