import math
import macros


type

  OverflowHandling* = enum
    Ignore, Throw, Saturate

  FP*[T: SomeInteger, W: static[int], O: static[OverflowHandling]] = object
    val*: T


proc getFloat*[T,W,O](f: FP[T,W,O]): float =
  float(f.val) / pow(2.0, float(W))


proc getInt*[T,W,O](f: FP[T,W,O]): T =
  if f.val == 0:
    result = 0
  elif f.val > 0:
    result = (f.val + (1 shl (W-1))) shr W
  else:
    result = (f.val + (1 shl (W-1)) - 1) shr W


proc `$`*[T,W,O](f: FP[T,W,O]): string =
  $getFloat(f)


proc dump*[T,W,O](f: FP[T,W,O]): string =
  "size: " & $sizeof(f) & ", type: " & $T & ", raw: " & $T(f.val) & ", val: " & $f


proc set*[T,W,O](f: var FP[T,W,O], val: SomeInteger) =
  f.val = T(val shl W)


proc set*[T,W,O](f: var FP[T,W,O], val: static[SomeFloat]) =
  when val < low(FP[T,W,O]).getFloat() or
       val > high(FP[T,W,O]).getFloat():
    {.error: "Overflow, " & $val & " does not fit in a " & $typeof(f).}

  let round = sgn(val).float * 0.5
  f.val = T(val * float64(1 shl W) + round)


# Some helper stuff

proc shrIfPos[T: SomeInteger](v: T, n: static[int]): T =
  ## Shift right if n > 0, otherwise keep as is
  when n > 0:
    v shr n
  else:
    v

proc shift[T: SomeInteger](v: T, left, right: static[int]): T =
  ## Shift left and/or right
  when left > right:
    v shl (left - right)
  elif left < right:
    v shr (right - left)
  else:
    v


# These templates expect `T1` and `T2` to be in scope, and return the largest
# of the two. This is needed for converting both operands to the largest of the
# two types before acting on them.
#
# TODO: Why can't I give toWT and WT the same name, they have different
# signatures?

template WT(): untyped =
  ## Return the wides type of [T1, T2]
  when sizeof(T1) >= sizeof(T2): T1 else: T2

template toWT(val: SomeInteger): untyped =
  ## Convert `val` to the widest of [T1, T2]
  when sizeof(T1) >= sizeof(T2): T1(val) else: T2(val)



# Comparison operators

template makeCmpOp(op: untyped) =
  proc op*[T1,W1,O1, T2,W2,O2](f1: FP[T1,W1,O1], f2: FP[T2,W2,O2]): bool =
    return op(f1.val.toWT.shrIfPos(W1-W2), f2.val.toWT.shrIfPos(W2-W1))

makeCmpOp `<`
makeCmpOp `<=`
makeCmpOp `==`
makeCmpOp `!=`
makeCmpOp `>=`
makeCmpOp `>`


# Math stuff


proc `-`*[T,W,O](f: FP[T,W,O]): FP[T,W,O] =
  ## Unary minus
  when T is SomeSignedInt:
    result.val = -f.val
  else:
    {.error: "Can not do unary minus on unsigned int".}


proc `+`*[T1,W1, T2,W2, O](f1: FP[T1, W1, O], f2: FP[T2, W2, O]): auto =
  return FP[WT, W1, O](val: f1.val.toWT + f2.val.toWT.shift(W1, W2))

proc `+=`*[T1,W1, T2,W2, O](f1: var FP[T1, W1, O], f2: FP[T2, W2, O]) =
  f1 = f1 + f2

proc `+`*[T,W,O](f1: FP[T,W,O], i: SomeInteger): FP[T,W,O] =
  var f2: FP[T,W,O]
  f2.set(i)
  return f1 + f2

proc `+=`*[T,W,O](f1: var FP[T,W,O], i: int) =
  f1 = f1 + i


proc `-`*[T1,W1, T2,W2, O](f1: FP[T1, W1, O], f2: FP[T2, W2, O]): auto =
  return FP[WT, W1, O](val: f1.val.toWT - f2.val.toWT.shift(W1, W2))

proc `-=`*[T1,W1, T2,W2, O](f1: var FP[T1, W1, O], f2: FP[T2, W2, O]) =
  f1 = f1 - f2

proc `-=`*[T,W,O](f1: var FP[T,W,O], i: int) =
  f1 = f1 - i


# TODO such overflow!

proc `*`*[T,W,O](f1, f2: FP[T,W,O]): auto =

  template aux(T2: untyped): untyped =
    let val = (f1.val.T2 * f2.val.T2) shr W
    return FP[T2,W,O](val: val)

  when T is int8: aux(int16)
  elif T is uint8: aux(uint16)
  elif T is int16: aux(int32)
  elif T is uint16: aux(uint32)


# Type information

proc low*[T,W,O](x: typedesc[FP[T,W,O]]): auto =
  ## Returns the lowest possible value for this type
  FP[T,W,O](val: T.low)

proc high*[T,W,O](x: typedesc[FP[T,W,O]]): auto =
  ## Returns the highest possible value for this type
  FP[T,W,O](val: T.high)

proc step*[T,W,O](x: typedesc[FP[T,W,O]]): auto =
  ## Returns the smallest step size for this type
  FP[T,W,O](val: 1)


# Type 'constructor'

template defFixedPoint*(id: untyped, T: typed, W: static[int], O: static[OverflowHandling]) =

  type id* = FP[T,W,O]

  proc `to id`*(val: static[SomeFloat]): id =
    result.set(val)

  proc `to id`*(val: SomeInteger | FP[T,W,O]): id =
    result.set(val)

  const
    `sub id steps`* {.inject.} = T(1) shl W
    `lowest id Step`* {.inject.} = id(val: 1)


