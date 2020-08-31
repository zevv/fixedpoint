import math
import macros


type
  FixedPoint*[T: SomeInteger, W: static[int]] = object
    val*: T


proc getFloat*[T, W](f: FixedPoint[T, W]): float =
  float(f.val) / pow(2.0, float(W))


proc getInt*[T, W](f: FixedPoint[T, W]): T =
  if f.val == 0:
    result = 0
  elif f.val > 0:
    result = (f.val + (1 shl (W-1))) shr W
  else:
    result = (f.val + (1 shl (W-1)) - 1) shr W


proc `$`*[T, W](f: FixedPoint[T, W]): string =
  $getFloat(f)


proc dump*[T, W](f: FixedPoint[T, W]): string =
  "size: " & $sizeof(f) & ", type: " & $T & ", raw: " & $T(f.val) & ", val: " & $f


proc set*[T, W](f: var FixedPoint[T, W], val: SomeInteger) =
  f.val = T(val shl W)


proc set*[T, W](f: var FixedPoint[T, W], val: static[SomeFloat]) =
  let round = sgn(val).float * 0.5
  f.val = T(val * float64(1 shl W) + round)


proc `==`*[T1, T2, W1, W2](f1: FixedPoint[T1, W1], f2: FixedPoint[T2, W2]): bool =
  when W1 == W2:
    return f1.val == f2.val
  elif W1 > W2:
    return f1.val shr (W1-W2) == f2.val
  elif W2 > W1:
    return f1.val == f2.val shr (W2-W1)


proc `<`*[T1, T2, W1, W2](f1: FixedPoint[T1, W1], f2: FixedPoint[T2, W2]): bool =
  when W1 == W2:
    return f1.val < f2.val
  elif W1 > W2:
    return f1.val shr (W1-W2) < f2.val
  elif W2 > W1:
    return f1.val < f2.val shr (W2-W1)


proc `-`*[T, W](f: FixedPoint[T, W]): FixedPoint[T, W] =
  ## Unary minus
  result.val = -f.val


proc `+`*[T1, T2, W1, W2](f1: FixedPoint[T1, W1], f2: FixedPoint[T2, W2]): FixedPoint[T1, W1] =
  assert sizeof(T1) >= sizeof(T2)
  when W1 == W2:
    result = FixedPoint[T1, W1](val: T1(f1.val) + T1(f2.val))
  when W1 > W2:
    result = FixedPoint[T1, W1](val: T1(f1.val) + (T1(f2.val) shl (W1-W2)))
  when W1 < W2:
    {.warning: "Addition loses precision".}
    result = FixedPoint[T1, W1](val: T1(f1.val) + (T1(f2.val) shl (W2-W1)))


proc `+=`*[T1, T2, W1, W2](f1: var FixedPoint[T1, W1], f2: FixedPoint[T2, W2]) =
  f1 = f1 + f2


proc `+`*[T, W](f1: FixedPoint[T, W], i: SomeInteger): FixedPoint[T, W] =
  var f2: FixedPoint[T, W]
  f2.set(i)
  return f1 + f2


proc `+=`*[T, W](f1: var FixedPoint[T, W], i: int) =
  f1 = f1 + i


proc `-`*[T1, T2, W1, W2](f1: FixedPoint[T1, W1], f2: FixedPoint[T2, W2]): FixedPoint[T1, W1] =
  result = f1 + -f2

proc `-=`*[T1, T2, W1, W2](f1: var FixedPoint[T1, W1], f2: FixedPoint[T2, W2]) =
  f1 = f1 - f2

proc `-=`*[T, W](f1: var FixedPoint[T, W], i: int) =
  f1 = f1 - i


proc `*`*[T, W](f1, f2: FixedPoint[T, W]): FixedPoint[T, W] =
  if T is uint8:
    return FixedPoint[T, W]((uint16(f1) * uint16(f2)) shr W )
  elif T is uint16:
    return FixedPoint[T, W]((uint32(f1) * uint32(f2)) shr W )
  else:
    echo "no can do"



template defFixedPoint*(id: untyped, T: typed, W: static[int]) =

  type id* = FixedPoint[T, W]

  proc `to id`*(val: static[SomeFloat]): id =
    result.set(val)

  proc `to id`*(val: SomeInteger): id =
    result.set(val)

  const
    `sub id steps`* {.inject.} = T(1) shl W
    `lowest id Step`* {.inject.} = id(val: 1)
