/*

UCBRecodedFloat.sv

By Matthew Whiteside
June 4th, 2015

This package was originally intended to be the place for stuff
related to Berkeley FP format, but it did accumulate some other 
stuff that isn't especially related to Berkeley FP.  

I manually hand coded 'decodeUCBFloat' function from the equivalent
scala code here:

https://github.com/ucb-bar/berkeley-hardfloat/blob/master/src/main/scala/recodedFloatNToFloatN.scala

I would have liked to do the encoding  using a system verilog function
as well, but it was more complicated going the other direction, so 
I abandoned that due to other priorities.

*/


package UCBRecodedFloat;



  parameter expWidth = 12;
  parameter sigWidth = 52;
  localparam internalArgWidth = expWidth + sigWidth + 1;
  localparam IEEE_argWidth = internalArgWidth - 1;

  // wire logic [64:0] one; 
  // wire logic [64:0] two; 
  // wire logic [64:0] four; 
  // wire logic [64:0] zero;

  // const bit [64:0] one = 65'h8000000000000000;
  // const bit [64:0] two = 65'h8010000000000000;
  // const bit [64:0] four = 65'h8020000000000000;
  // const bit [64:0] zero = '0;
  
  `define one 65'h8000000000000000;
  `define two 65'h8010000000000000;
  `define four 65'h8020000000000000;
  `define zero 65'b0;

  typedef logic [64:0] UCBFloat;
  typedef logic [0:2][IEEE_argWidth-1:0] Vec3;
  typedef struct packed{
    Vec3 left,right;
  } VecPair;

  typedef struct packed{
    VecPair left,center,right;
    logic [IEEE_argWidth-1:0] k;
  }  arg_snapshot_t;



  function automatic logic [IEEE_argWidth-1:0] decodeUCBFloat(logic [internalArgWidth-1:0] in);
    logic sign,isHighSubnormalIn,isSubnormal,isNormal,isSpecial,isNaN;

    logic [sigWidth-1:0] fractIn,stuff,subnormal_fractOut,fractOut;
    logic [expWidth-1:0] expIn;
    logic [expWidth-2:0] normal_expOut,expOut;

    integer denormShiftDist;

    sign = in[64];
    expIn = in[63:52];
    fractIn = in[51:0];

    isHighSubnormalIn = (expIn[expWidth-3: 0] < 2);
    isSubnormal = expIn[expWidth-1: expWidth-3] === 1 || expIn[expWidth-1:expWidth-2] === 1 && isHighSubnormalIn;
    isNormal = expIn[expWidth-1:expWidth-2] === 1 && !isHighSubnormalIn || expIn[expWidth-1:expWidth-2] === 2;
    isSpecial = expIn[expWidth-1:expWidth-2] === 3;
    isNaN = isSpecial && expIn[expWidth-3];

    denormShiftDist = 2 - expIn[5:0];//this line is hardcoded for 52 bit significand
    stuff = {1'b1,fractIn} >> denormShiftDist;
    subnormal_fractOut = stuff[sigWidth-1:0];
    normal_expOut = expIn[expWidth-2:0] - ((1 << (expWidth-2))+1);

    expOut = isNormal ? normal_expOut : {(expWidth-1){isSpecial}};
    fractOut = isNormal || isNaN ?  fractIn : isSubnormal ? subnormal_fractOut : '0;

    return {sign, expOut, fractOut};

  endfunction

endpackage