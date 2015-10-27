/*

DotProduct.sv

By Matthew Whiteside
June 3rd, 2015

Takes in 2 floating point 3-vectors, in 64-bit IEEE 754 format, 
and outputs a single floating point number in the Berkeley recoded
format.

The reason the inputs and outputs are in different formats is
that it was more convenient (in the context of this project) to do the conversion
in this module than anywhere else.

*/

import UCBRecodedFloat::*;

module DotProduct(
		input Vec3 left,
		input Vec3 right,
		input proceed,
		input clk,
		input reset,
		output UCBFloat out
	);


//it wouldn't be too much work to 
// make this an n-dimensional dot-product; however the
// module inputs are hardcoded for 3 dimensions to 
// suit present purposes 
localparam dim = 3;

genvar i,j;

generate

	//in 3 dimensions, we need 3 fmas
	// which are generated along with pipeline regs here
	for (i = 0; i < dim; i++) begin: fmas

		wire UCBFloat encodedLeft, encodedRight;
		UCBFloatEncoder l(.io_in(left[i]),.io_out(encodedLeft));
		UCBFloatEncoder r(.io_in(right[i]),.io_out(encodedRight));


		for (j = 0; j < i; j++) begin: pipeline_regs
			var UCBFloat _left,_right;
			if (j == 0) begin

				always_ff @(posedge clk) begin 
					if(reset) begin
						_left <= 0;
						_right <= 0;
					end else begin
						if (proceed) begin
							_left <= encodedLeft;
							_right <= encodedRight;
						end
					end
				end
			end	else begin
				always_ff @(posedge clk) begin : proc_
					if(reset) begin
						_left <= '0;
						_right <= '0;
					end else begin
						if (proceed) begin
							_left <= pipeline_regs[j-1]._left;
							_right <= pipeline_regs[j-1]._right;
						end
					end
				end
			end
		end

		fma64 fma(.clk,.proceed,.reset);

		if (i == 0) begin
			assign fma.addend = '0;
			assign fma.leftMultiplicand = encodedLeft;
			assign fma.rightMultiplicand = encodedRight;			
		end else begin
			assign fma.addend = fmas[i-1].fma.out;
			assign fma.leftMultiplicand = pipeline_regs[i-1]._left;
			assign fma.rightMultiplicand = pipeline_regs[i-1]._right;			

			if (i == dim - 1) begin 
				assign out = fma.out;
			end
			 
		end

	end
endgenerate


endmodule // DotProduct