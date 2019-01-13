import strutils, sequtils, json
import common/file

when defined(release):
  const clientDir = "../build/client"
  const clientFiles = staticExec("ls " & clientDir)
                          .split(Whitespace)
                          .mapIt((it, staticRead(clientDir & "/" & it)))

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

template prodRoutes(): untyped =
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

when defined(release):
  template routes*() = prodRoutes
else:
  template routes*() = devRoutes
