
Fixed point math lib, very much work in progress.  Might or might not work.



## Usage

Define your custom fixed point types with the `defFixedPoint()` template:

``` Nim
defFixedPoint(<name>, <basetype>, <fracBits>)
```

This will create a type with the given name which can be used with some math
operations. Mixing different fixed point types in operations is someimes
supported.

Fixed point variables can be initialzed with floating point values at compile
time with the generated template `to` concatenated with the name of your type.


## Example

``` Nim
defFixedPoint(Speed, int8, 2)
defFixedPoint(Position, int16, 4)

var dx = toSpeed(1.25)
var x: toPosition(3.0)

x = x + dx
```
