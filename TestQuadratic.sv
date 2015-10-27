
// `ifndef _UCB_RECODED_FLOAT
// `include "UCBRecodedFloat.sv"
// `endif

`ifndef CLOCK_PERIOD
`define CLOCK_PERIOD 5
`endif

module TestQuadratic; 



var logic clk, reset;


always #`CLOCK_PERIOD clk = ~clk;

`include "TestQuadraticCore.sv"


endmodule

