# Package

version       = "0.1.0"
author        = "nepeckman"
description   = "A serving file editor"
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["ehpedit"]


# Dependencies

requires "nim >= 0.19.9"
requires "jester = 0.4.1"
requires "cligen = 0.9.18"
