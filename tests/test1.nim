import unittest
import fixedpoint

defFixedPoint(FP_U8_0, uint8, 0, Ignore)
defFixedPoint(FP_U8_2, uint8, 2, Ignore)
defFixedPoint(FP_U8_4, uint8, 4, Ignore)
defFixedPoint(FP_U8_8, uint8, 8, Ignore)

defFixedPoint(FP_S8_2, int8, 2, Ignore)
defFixedPoint(FP_S16_4, int16, 4, Ignore)



suite "fixedpoint":

  test "FP_U8_0":
    var a = toFP_U8_0(255)
    check(a.val == 255)
    check(a.getFloat == 255.0)

  test "FP_U8_2":
    var a = toFP_U8_2(63.75)
    check(a.val == 255)
    check(a.getFloat == 63.75)

  test "FP_U8_8":
    var a = toFP_U8_8(0.99609375)
    check(a.val == 255)
    check(a.getFloat == 0.99609375)

  test "- uni":
    var a = toFP_S8_2(3.5)
    var b = -a
    check b == toFP_S8_2(-3.5)

  test "+ signed":
    block:
      var a = toFP_S8_2(1.5)
      var b = toFP_S8_2(3.5)
      check a + b == toFP_S8_2(5.0)

    block:
      var a = toFP_S8_2( 1.5)
      var b = toFP_S8_2(-3.5)
      check a + b == toFP_S8_2(-2.0)
    
    block:
      var a = toFP_S8_2(1.5)
      var b = toFP_S16_4(3.5)
      check a + b == toFP_S16_4(5.0)
      check b + a == toFP_S16_4(5.0)

  test "- signed":
    block:
      var a = toFP_S8_2(3.5)
      var b = toFP_S8_2(1.5)
      check a - b == toFP_S8_2(2.0)

  test "getint unsigned":
    var a: FP_U8_2
    a.set(1.25); check a.getInt == 1.uint8
    a.set(1.25); check a.getInt == 1.uint8
    a.set(1.50); check a.getInt == 2.uint8
    a.set(1.75); check a.getInt == 2.uint8
    a.set(2.00); check a.getInt == 2.uint8
    a.set(2.25); check a.getInt == 2.uint8
    a.set(2.50); check a.getInt == 3.uint8
    a.set(2.75); check a.getInt == 3.uint8

  test "getint signed":
    var b: FP_S8_2
    b.set( 1.00); check b.getInt ==  1.int8
    b.set(-1.00); check b.getInt == -1.int8
    b.set(-1.25); check b.getInt == -1.int8
    b.set(-1.50); check b.getInt == -2.int8
    b.set(-1.75); check b.getInt == -2.int8
    b.set(-2.00); check b.getInt == -2.int8

  test "==":
    check to_FP_U8_2(10.25) == to_FP_U8_2(10.25)
    check to_FP_U8_2(10.25) == to_FP_U8_4(10.25)
    check to_FP_U8_4(10.25) == to_FP_U8_2(10.25)
    check to_FP_S16_4(10.25) == to_FP_U8_2(10.25)
    check to_FP_U8_2(10.25) == to_FP_S16_4(10.25)

  test "<":
    check to_FP_U8_2(10) < to_FP_U8_2(10.25)
    check to_FP_U8_4(10) < to_FP_U8_2(10.25)
    check to_FP_U8_2(10) < to_FP_U8_4(10.25)
    check to_FP_S16_4(10) < to_FP_U8_4(10.25)
  
  test ">":
    check to_FP_U8_2(10.5) > to_FP_U8_2(10.25)
    check to_FP_U8_4(10.5) > to_FP_U8_2(10.25)
    check to_FP_U8_2(10.5) > to_FP_U8_4(10.25)
    check to_FP_S16_4(100.5) > to_FP_U8_4(10.25)

  test "FP_U8_2 +":
    check toFP_U8_2(5.25) + toFP_U8_2(4.75) == toFP_U8_2(10.0)
    check toFP_U8_2(5.5) + 10 == toFP_U8_2(15.5)

  test "iterate steps":
    var
      FP8_2 = toFP_U8_2(1.0)
      FP8_4 = toFP_U8_4(1.0)

    for i in 0.uint8..<subFPU8_2Steps:
      FP8_2 += lowestFPU8_2Step

    for i in 0.uint8..<subFPU8_4Steps:
      FP8_4 += lowestFPU8_4Step

    check FP8_2 == toFP_U8_2(2.0)
    check FP8_4 == toFP_U8_4(2.0)



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
