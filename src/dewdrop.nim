import jester, asyncdispatch, asyncnet, sequtils, os
import routes, common/file

var files: seq[FileData]

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

  routes()

  var server = initJester(settings)
  server.serve()

when isMainModule:
    import cligen
    dispatch(serveFile)
