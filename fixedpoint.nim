import math

type
  FixedPoint[T: SomeInteger, W: static(int)] = distinct T


proc toFloat*[T, W](f: FixedPoint[T, W]): float =
  float(f) / pow(2.0, float(W))

converter conv*[T, W](f: FixedPoint[T, W]): float =
  toFloat(f)

proc `$`*[T, W](f: FixedPoint[T, W]): string =
  $toFloat(f)


proc dump[T, W](f: FixedPoint[T, W]): string =
  "type: " & $T & ", raw: " & $T(f) & " val: " & $f


proc `+`*[T1, T2, W1, W2](f1: FixedPoint[T1, W1], f2: FixedPoint[T2, W2]): FixedPoint[T1, W1] =
  assert sizeof(T1) >= sizeof(T2)
  when W1 == W2:
    result = FixedPoint[T1, W](T1(f1) + T1(f2))
  when W1 > W2:
    result = FixedPoint[T1, W1](T1(f1) + (T1(f2) shl (W1-W2)))
  when W1 < W2:
    {.warning: "Addition loses precision".}
    result = FixedPoint[T1, W1](T1(f1) + (T1(f2) shl (W2-W1)))


proc `+=`*[T1, T2, W1, W2](f1: var FixedPoint[T1, W1], f2: FixedPoint[T2, W2]) =
  f1 = f1 + f2


proc `*`*[T, W](f1, f2: FixedPoint[T, W]): FixedPoint[T, W] =
  if T is uint8:
    return FixedPoint[T, W]((uint16(f1) * uint16(f2)) shr W )
  else:
    echo "no can do"


proc set*[T, W](f: var FixedPoint[T, W], val: static(float)) =
  let round = sgn(val).float * 0.5
  f = FixedPoint[T, W](val * float64(1 shl W) + round)


when isMainModule:

  type Speed = FixedPoint[int8, 3]
  type Position = FixedPoint[uint16, 4]

  var dx, dy: Speed
  var x, y: Position

  dx.set(1.4)
  dy.set(0.6)

  echo dx.dump()
  echo dy.dump()

  for i in 0..10:
    x += dx
    echo x.dump()
