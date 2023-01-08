import system
import strutils
import strformat

var c: int
var a: int

echo "divisor: "
c = readLine(stdin).parseInt()

echo "dividend: "
a = readLine(stdin).parseInt()


let b = c div a
let d = c mod a
echo fmt"{c} div {a} = {b}"
echo fmt"{c} mod {a} = {d}"
