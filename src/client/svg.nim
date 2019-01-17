import jsffi, base64

proc btoa(s: cstring): cstring {. importc .}

let rawSvg = """
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
 "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg version="1.0" xmlns="http://www.w3.org/2000/svg"
 width="908.000000pt" height="1280.000000pt" viewBox="0 0 908.000000 1280.000000"
 preserveAspectRatio="xMidYMid meet">
<g transform="translate(0.000000,1280.000000) scale(0.100000,-0.100000)" fill="#6cb2eb" stroke="none">
<path d="M4526 10235 c-11 -56 -84 -317 -126 -449 -128 -403 -267 -741 -469
-1146 -235 -469 -420 -775 -978 -1620 -176 -267 -369 -565 -428 -664 -229
-381 -363 -692 -420 -976 -22 -107 -29 -368 -16 -550 90 -1217 703 -2015 1726
-2245 230 -52 393 -68 695 -69 281 -1 389 7 608 45 745 129 1291 528 1602
1171 173 359 262 756 277 1233 9 297 -20 482 -113 732 -123 330 -261 572 -754
1318 -575 872 -745 1154 -985 1635 -203 407 -336 731 -465 1136 -42 132 -115
393 -126 449 -3 19 -10 35 -14 35 -4 0 -11 -16 -14 -35z"/>
</g>
</svg>
"""

let dropSvg* = cstring("data:image/svg+xml;base64,") & cstring(encode(rawSvg))
