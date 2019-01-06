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
  mkdir("./build/css")
  mkdir("./build/dist")
  mkdir("./build/bin")

proc client() =
  folderSetup()
  exec "./node_modules/.bin/tailwind build client/tailwind/styles.css -c client/tailwind/tailwind.js > build/css/styles.css"
  exec "node build.js"

proc bin() =
  folderSetup()
  if not existsFile("./build/dist/index.html"):
    client()
  exec "nim c -o:build/bin/ehpedit src/ehpedit.nim"

task client, "Builds client code":
  client()

task bin, "Builds the binary":
  bin()

task all, "Builds the project":
  client()
  bin()
