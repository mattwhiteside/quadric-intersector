/*

fma64.sv

This is a small wrapper around the Berkeley 
fused multiplier-adder-subtractor unit, to
hide some details I didn't care about, like the
rounding mode.  

Wherever I needed subtraction I just inverted one of the
addends, so I also did not expose the 'Op' input.

*/


module fma64(
    input clk, 
    input reset,
    input [64:0] leftMultiplicand,
    input [64:0] rightMultiplicand,
    input [64:0] addend,//aka, enable
    output[64:0] out,
    input  proceed
);

  reg [64:0] addendInputReg, r_inputReg, l_inputReg;

  mulAddSubRecodedFloatN _fma(
       .io_op( 2'h0 ),//hard-code the operation to addition
       .io_a( l_inputReg ),
       .io_b( r_inputReg ),
       .io_c( addendInputReg ),
       .io_roundingMode( 2'h0 ),
       .io_out( out )
       //.io_exceptionFlags(  )
  );

  always_ff @(posedge clk) begin

    if(reset) begin
      addendInputReg <= 65'h0;
      r_inputReg <= 65'h0;
      l_inputReg <= 65'h0;
    end else if(proceed) begin
      addendInputReg <= addend;
      r_inputReg <= rightMultiplicand;
      l_inputReg <= leftMultiplicand;
    end

  end
endmodule