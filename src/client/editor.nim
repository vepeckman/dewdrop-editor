import jsffi
import ../common/file
let Editor* = require("./editor.js")
proc updateEditor*(editor: JsObject, file: FileData) {. importcpp: "#.updateEditor(@)", nodecl .}
