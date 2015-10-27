/*
This floating point comparator is from
UC Berkeley's hardfloat repo, and was generated 
by chisel

https://github.com/ucb-bar/berkeley-hardfloat/blob/master/src/main/scala/recodedFloatNCompare.scala 

*/

module recodedFloatNCompare(
    input [64:0] io_a,
    input [64:0] io_b,
    output io_a_eq_b,
    output io_a_lt_b,
    output io_a_eq_b_invalid,
    output io_a_lt_b_invalid
);

  wire T0;
  wire isNaNB;
  wire[2:0] codeB;
  wire[11:0] expB;
  wire isNaNA;
  wire[2:0] codeA;
  wire[11:0] expA;
  wire T1;
  wire isSignalingNaNB;
  wire T2;
  wire T3;
  wire[51:0] sigB;
  wire isSignalingNaNA;
  wire T4;
  wire T5;
  wire[51:0] sigA;
  wire T6;
  wire T7;
  wire T8;
  wire magLess;
  wire T9;
  wire T10;
  wire expEqual;
  wire T11;
  wire T12;
  wire T13;
  wire isZeroB;
  wire T14;
  wire isZeroA;
  wire T15;
  wire signA;
  wire T16;
  wire T17;
  wire magEqual;
  wire T18;
  wire T19;
  wire T20;
  wire signB;
  wire T21;
  wire T22;
  wire T23;
  wire signEqual;
  wire T24;
  wire T25;


  assign io_a_lt_b_invalid = T0;
  assign T0 = isNaNA | isNaNB;
  assign isNaNB = codeB == 3'h7;
  assign codeB = expB[4'hb:4'h9];
  assign expB = io_b[6'h3f:6'h34];
  assign isNaNA = codeA == 3'h7;
  assign codeA = expA[4'hb:4'h9];
  assign expA = io_a[6'h3f:6'h34];
  assign io_a_eq_b_invalid = T1;
  assign T1 = isSignalingNaNA | isSignalingNaNB;
  assign isSignalingNaNB = isNaNB & T2;
  assign T2 = T3 ^ 1'h1;
  assign T3 = sigB[6'h33:6'h33];
  assign sigB = io_b[6'h33:1'h0];
  assign isSignalingNaNA = isNaNA & T4;
  assign T4 = T5 ^ 1'h1;
  assign T5 = sigA[6'h33:6'h33];
  assign sigA = io_a[6'h33:1'h0];
  assign io_a_lt_b = T6;
  assign T6 = T21 & T7;
  assign T7 = signB ? T16 : T8;
  assign T8 = signA ? T12 : magLess;
  assign magLess = T11 | T9;
  assign T9 = expEqual & T10;
  assign T10 = sigA < sigB;
  assign expEqual = expA == expB;
  assign T11 = expA < expB;
  assign T12 = T13 ^ 1'h1;
  assign T13 = isZeroA & isZeroB;
  assign isZeroB = T14 ^ 1'h1;
  assign T14 = codeB != 3'h0;
  assign isZeroA = T15 ^ 1'h1;
  assign T15 = codeA != 3'h0;
  assign signA = io_a[7'h40:7'h40];
  assign T16 = T19 & T17;
  assign T17 = magEqual ^ 1'h1;
  assign magEqual = expEqual & T18;
  assign T18 = sigA == sigB;
  assign T19 = signA & T20;
  assign T20 = magLess ^ 1'h1;
  assign signB = io_b[7'h40:7'h40];
  assign T21 = io_a_lt_b_invalid ^ 1'h1;
  assign io_a_eq_b = T22;
  assign T22 = T24 & T23;
  assign T23 = isZeroA | signEqual;
  assign signEqual = signA == signB;
  assign T24 = T25 & magEqual;
  assign T25 = isNaNA ^ 1'h1;
endmodule

