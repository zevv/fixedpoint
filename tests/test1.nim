import unittest
import fixedpoint

defFixedPoint(FP_8_0, uint8, 0)
defFixedPoint(FP_8_2, uint8, 2)
defFixedPoint(FP_8_4, uint8, 4)
defFixedPoint(FP_8_8, uint8, 8)

defFixedPoint(Speed, uint8, 3)
defFixedPoint(Position, uint16, 4)



suite "fixedpoint":

  test "FP_8_0":
    var a = toFP_8_0(255)
    check(a.val == 255)
    check(a.toFloat == 255.0)
  
  test "FP_8_2":
    var a = toFP_8_2(63.75)
    check(a.val == 255)
    check(a.toFloat == 63.75)
  
  test "FP_8_8":
    var a = toFP_8_8(0.99609375)
    check(a.val == 255)
    check(a.toFloat == 0.99609375)

  test "==":
    check to_FP_8_2(10.25) == to_FP_8_2(10.25)
    check to_FP_8_2(10.25) == to_FP_8_4(10.25)
    check to_FP_8_4(10.25) == to_FP_8_2(10.25)
  
  test "<":
    check to_FP_8_2(10) < to_FP_8_2(10.25)
    check to_FP_8_4(10) < to_FP_8_2(10.25)
    check to_FP_8_2(10) < to_FP_8_4(10.25)

  test "FP_8_2 +":
    check toFP_8_2(5.25) + toFP_8_2(4.75) == toFP_8_2(10.0)
    check toFP_8_2(5.5) + 10 == toFP_8_2(15.5)



#  test "1":
#
#
#    var dx = toSpeed(1.375)
#    var dy = toSpeed(0.625)
#
#    dx += 1
#
#    var x, y: Position
#
#    for i in 0..10:
#      x += dx
#      y += dy
#      echo x, ", ", y
#
