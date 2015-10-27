
// `ifndef _UCB_RECODED_FLOAT
// `include "UCBRecodedFloat.sv"
// `endif

`ifndef CLOCK_PERIOD
`define CLOCK_PERIOD 5
`endif

`define HELLO_VELOCE 1
module TestQuadratic_Veloce(input logic clk, input logic reset, output logic rootsValid, output logic [64:0] leftRoot, output logic [64:0] rightRoot); 

 
`include "TestQuadraticCore.sv"
assign leftRoot = decodeUCBFloat(qrf.leftRoot);
assign rightRoot = decodeUCBFloat(qrf.rightRoot);

endmodule

