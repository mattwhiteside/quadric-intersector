package hardfloat

import Chisel._
/**
 * Created by matt on 5/16/15.
 */

class Discriminant extends Module with MyBase{

  val io = new Bundle{
    val left = new Bundle{
      val left = Vec.fill(3){UInt(INPUT, IEEE_argWidth)}
      val right = Vec.fill(3){UInt(INPUT, IEEE_argWidth)}
    }

    val center = new Bundle{
      val left = Vec.fill(3){UInt(INPUT, IEEE_argWidth)}
      val right = Vec.fill(3){UInt(INPUT, IEEE_argWidth)}
    }

    val right = new Bundle{
      val left = Vec.fill(3){UInt(INPUT, IEEE_argWidth)}
      val right = Vec.fill(3){UInt(INPUT, IEEE_argWidth)}
    }

    val k = UInt(INPUT,IEEE_argWidth)
    val out = UInt(OUTPUT, internalArgWidth)
    val ready = Bool(INPUT)
  }

  val one = UInt("b_0_1000000000000000_0000000000000000_0000000000000000_0000000000000000", internalArgWidth)
  //val one = floatNToRecodedFloatN(io.debug,sigWidth,expWidth)
  val left = Module(new InnerProduct(3))
  for (i <- 0 until 3){
    left.io.left(i) := floatNToRecodedFloatN(io.left.left(i),sigWidth,expWidth);
    left.io.right(i) := floatNToRecodedFloatN(io.left.right(i),sigWidth,expWidth);
  }
  left.io.ready := io.ready

  val center = Module(new InnerProduct(3))
  for (i <- 0 until 3){
    center.io.left(i) := floatNToRecodedFloatN(io.center.left(i),sigWidth, expWidth);
    center.io.right(i) := floatNToRecodedFloatN(io.center.right(i),sigWidth, expWidth);
  }
  center.io.ready := io.ready

  val right = Module(new InnerProduct(3))
  for (i <- 0 until 3){
    right.io.left(i) := floatNToRecodedFloatN(io.right.left(i),sigWidth,expWidth);
    right.io.right(i) := floatNToRecodedFloatN(io.right.right(i),sigWidth, expWidth);
  }
  right.io.ready := io.ready

  val fma1 = Module(new fma64)

  fma1.io.leftMultiplicand := one
  fma1.io.rightMultiplicand := left.io.out
  fma1.io.addend := center.io.out
  fma1.io.ready := io.ready


  val right_dp_delay = Reg(init=UInt(0,width=internalArgWidth))

  val fma2 = Module(new fma64)
  fma2.io.leftMultiplicand := one
  fma2.io.rightMultiplicand := fma1.io.out
  fma2.io.ready := io.ready
  fma2.io.addend := right_dp_delay

  val kRegs = Vec.fill(5){Reg(init=UInt(0,width=internalArgWidth))}

  when (io.ready){
    right_dp_delay := right.io.out
    kRegs(0) := floatNToRecodedFloatN(io.k,sigWidth,expWidth)
    for (i <- (kRegs.size - 1) to 1 by -1){
      kRegs(i) := kRegs(i-1)
    }
  }



  val fma3 = Module(new fma64)
  fma3.io.leftMultiplicand := one
  fma3.io.rightMultiplicand := kRegs(kRegs.size-1)
  fma3.io.addend := fma2.io.out
  fma3.io.ready := io.ready
  io.out := fma3.io.out

}
