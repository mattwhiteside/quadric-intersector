

import UCBRecodedFloat::*;

module QuadricIntersector(
      input VecPair left, 
      input VecPair center,
      input VecPair right,
      input [IEEE_argWidth-1:0] k,
      input logic clk,
      input logic reset,
      output reg [internalArgWidth-1:0] leftRoot,
      output reg [internalArgWidth-1:0] rightRoot,
      output logic ready
);

wire valid;
wire [internalArgWidth-1:0] _discrim_out;


Discriminant discriminant(.clk,
                          .reset,
                          .proceed(ready),
                          .left,
                          .center,
                          .right,
                          .k,
                          .valid,
                          .out(_discrim_out));

QuadraticRootFinder qrf(.clk,
                        .reset,
                        .ready(ready),
                        .discriminant(_discrim_out),
                        .inputsValid(valid));




endmodule