# Package

version       = "0.1.0"
author        = "nepeckman"
description   = "A serving file editor"
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["ehpedit"]


# Dependencies

requires "nim >= 0.19.9"
requires "jester 0.4.1"
requires "cligen 0.9.18"

proc folderSetup() =
  mkdir("./build")
  mkdir("./build/client")
  mkdir("./build/server")

proc client() =
  folderSetup()
  exec "./node_modules/.bin/parcel build client/index.html --no-source-maps -d build/client --public-url ./client"

proc server() =
  folderSetup()
  if not existsFile("./build/client/index.html"):
    client()
  exec "nim c -o:build/server/ehpedit src/ehpedit.nim"

task client, "Builds client code":
  client()

task server, "Builds the server":
  server()

task all, "Builds the project":
  client()
  server()
