import math
import macros


type

  OverflowHandling* = enum
    Ignore, Throw, Saturate

  FixedPoint*[T: SomeInteger, W: static[int], O: static[OverflowHandling]] = object
    val*: T


proc getFloat*[T, W, O](f: FixedPoint[T, W, O]): float =
  float(f.val) / pow(2.0, float(W))


proc getInt*[T, W, O](f: FixedPoint[T, W, O]): T =
  if f.val == 0:
    result = 0
  elif f.val > 0:
    result = (f.val + (1 shl (W-1))) shr W
  else:
    result = (f.val + (1 shl (W-1)) - 1) shr W


proc `$`*[T, W, O](f: FixedPoint[T, W, O]): string =
  $getFloat(f)


proc dump*[T, W, O](f: FixedPoint[T, W, O]): string =
  "size: " & $sizeof(f) & ", type: " & $T & ", raw: " & $T(f.val) & ", val: " & $f


proc set*[T, W, O](f: var FixedPoint[T, W, O], val: SomeInteger) =
  f.val = T(val shl W)


proc set*[T, W, O](f: var FixedPoint[T, W, O], val: static[SomeFloat]) =
  let round = sgn(val).float * 0.5
  f.val = T(val * float64(1 shl W) + round)


proc shrIfPos[T: SomeInteger](v: T, n: static[int]): T =
  ## Shift right if n > 0, otherwise keep as is
  if n > 0:
    v shr n
  else:
    v

template makeCmpOp(op: untyped) =
  proc op*[T1, T2, W1, W2, O1, O2](f1: FixedPoint[T1, W1, O1], f2: FixedPoint[T2, W2, O2]): bool =
    template aux(T: typed) =
      return op(f1.val.T.shrIfPos(W1-W2), f2.val.T.shrIfPos(W2-W1))
    when sizeof(T1) >= sizeof(T2):
      aux(T1)
    else:
      aux(T2)

makeCmpOp `<`
makeCmpOp `<=`
makeCmpOp `==`
makeCmpOp `>=`
makeCmpOp `>`


proc `-`*[T, W, O](f: FixedPoint[T, W, O]): FixedPoint[T, W, O] =
  ## Unary minus
  result.val = -f.val


proc shift[T: SomeInteger](v: T, left, right: static[int]): T =
  ## Shift left and/or right
  when left > right:
    v shl (left - right)
  elif left < right:
    v shr (right - left)
  else:
    v



proc `+`*[T1, T2, W1, W2, O](f1: FixedPoint[T1, W1, O], f2: FixedPoint[T2, W2, O]): auto =
  template aux(T: typed) =
    return FixedPoint[T, W1, O](val: f1.val.T + f2.val.T.shift(W1, W2))
  when sizeof(T1) >= sizeof(T2):
    aux(T1)
  else:
    aux(T2)


proc `+=`*[T1, T2, W1, W2, O](f1: var FixedPoint[T1, W1, O], f2: FixedPoint[T2, W2, O]) =
  f1 = f1 + f2


proc `+`*[T, W, O](f1: FixedPoint[T, W, O], i: SomeInteger): FixedPoint[T, W, O] =
  var f2: FixedPoint[T, W, O]
  f2.set(i)
  return f1 + f2


proc `+=`*[T, W, O](f1: var FixedPoint[T, W, O], i: int) =
  f1 = f1 + i


proc `-`*[T1, T2, W1, W2, O](f1: FixedPoint[T1, W1, O], f2: FixedPoint[T2, W2, O]): auto =
  template aux(T: typed) =
    return FixedPoint[T, W1, O](val: f1.val.T - f2.val.T.shift(W1, W2))
  when sizeoF(T1) >= sizeof(T2):
    aux(T1)
  else:
    aux(T2)

proc `-=`*[T1, T2, W1, W2, O](f1: var FixedPoint[T1, W1, O], f2: FixedPoint[T2, W2, O]) =
  f1 = f1 - f2

proc `-=`*[T, W, O](f1: var FixedPoint[T, W, O], i: int) =
  f1 = f1 - i


proc `*`*[T, W, O](f1, f2: FixedPoint[T, W, O]): FixedPoint[T, W, O] =
  if T is uint8:
    return FixedPoint[T, W, O]((uint16(f1) * uint16(f2)) shr W )
  elif T is uint16:
    return FixedPoint[T, W, O]((uint32(f1) * uint32(f2)) shr W )
  else:
    echo "no can do"



template defFixedPoint*(id: untyped, T: typed, W: static[int], O: static[OverflowHandling]) =

  type id* = FixedPoint[T, W, O]

  proc `to id`*(val: static[SomeFloat]): id =
    result.set(val)

  proc `to id`*(val: SomeInteger): id =
    result.set(val)

  const
    `sub id steps`* {.inject.} = T(1) shl W
    `lowest id Step`* {.inject.} = id(val: 1)


