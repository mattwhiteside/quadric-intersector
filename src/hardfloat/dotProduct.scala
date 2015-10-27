package hardfloat

import Chisel._

/**
 * Created by matt on 5/16/15.
 */

trait MyBase {
  val sigWidth:Int = 52
  val expWidth:Int = 12
  val IEEE_argWidth:Int = 64
  val internalArgWidth:Int = IEEE_argWidth + 1
}

class fma64 extends Module with MyBase{
  val io = new Bundle{
    val leftMultiplicand = UInt(INPUT, internalArgWidth)
    val rightMultiplicand = UInt(INPUT, internalArgWidth)
    val addend = UInt(INPUT, internalArgWidth)
    //val roundingMode = UInt(INPUT, 2)
    val out = UInt(OUTPUT,internalArgWidth)
    //val exceptionFlags = UInt(OUTPUT, 5)//punting on this for now
    val ready = Bool(INPUT)
    //val ieee_out = UInt(OUTPUT,IEEE_argWidth)
  }
  val _fma = Module(new mulAddSubRecodedFloatN(sigWidth, expWidth))

  val l_inputReg = Reg(init = UInt(0,internalArgWidth))
  val r_inputReg = Reg(init = UInt(0,internalArgWidth))
  val addendInputReg = Reg(init = UInt(0,internalArgWidth))
  //val output_reg = Reg(init = UInt(0,internalArgWidth))

  when (io.ready){
    l_inputReg := io.leftMultiplicand
    r_inputReg := io.rightMultiplicand
    addendInputReg := io.addend
    //output_reg := _fma.io.out
  }
  _fma.io.a := l_inputReg
  _fma.io.b := r_inputReg
  _fma.io.c := addendInputReg
  _fma.io.roundingMode := UInt(0,2)//nearest even, seems good
  _fma.io.op := UInt(0) //addition
  //io.out := output_reg//registered output
  //_fma.io.out := output_reg

  io.out := _fma.io.out//unregistered output
}

class InnerProduct(val dim:Int = 3) extends Module with MyBase{

  val io = new Bundle{
    val left = Vec.fill(dim){UInt(INPUT, internalArgWidth)}
    val right = Vec.fill(dim){UInt(INPUT, internalArgWidth)}
    val out = UInt(OUTPUT, internalArgWidth)
    val ready = Bool(INPUT)
  }

  val fmas = Vec.fill(dim){Module(new fma64()).io}//new Array[fma64](dim)
  for (i <- 0 until dim){

    fmas(i).ready := io.ready
    val left_pipeline_regs = Vec.fill(i){Reg(init = UInt(0,width=internalArgWidth))}
    val right_pipeline_regs = Vec.fill(i){Reg(init = UInt(0,width=internalArgWidth))}

    for (j <- (i - 1) to 0 by -1){
      if (j == 0){
        when (io.ready){
          left_pipeline_regs(j) := io.left(i)
          right_pipeline_regs(j) := io.right(i)
        }
      } else{
        when(io.ready){
          left_pipeline_regs(j) := left_pipeline_regs(j-1)
          right_pipeline_regs(j) := right_pipeline_regs(j-1)
        }
      }
    }

    if (i == 0){
      fmas(i).leftMultiplicand := io.left(i)
      fmas(i).rightMultiplicand := io.right(i)
      fmas(i).addend := UInt(0)
    } else{
      fmas(i).addend := fmas(i-1).out
      fmas(i).leftMultiplicand := left_pipeline_regs(i-1)
      fmas(i).rightMultiplicand := right_pipeline_regs(i-1)
    }

    if (i == dim - 1){
      io.out := fmas(i).out
    }

  }
}