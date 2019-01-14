import jsffi
import ../common/file
let monaco* = require("./editor.js")
proc updateEditor*(editor: JsObject, file: FileData) {. importcpp: "#.updateEditor(@)", nodecl .}
