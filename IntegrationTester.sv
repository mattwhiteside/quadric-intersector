/*

A synthesizable test bench for Veloce.

*/


import UCBRecodedFloat::*;


`ifndef CLOCK_PERIOD
`define CLOCK_PERIOD 10
`endif

module IntegrationTester #(parameter clock_length = `CLOCK_PERIOD)(
		input logic clk, 
		input logic reset, 
		output logic rootsValid, 
		output logic [IEEE_argWidth-1:0] leftRoot, 
		output logic [IEEE_argWidth-1:0] rightRoot
);   	

  	reg [63:0] offset = '0;
  	VecPair left = '0,center = '0,right = '0;
 
	wire logic [1:0] i;
	wire [internalArgWidth-1:0] leftRootOut, rightRootOut;

  	QuadricIntersector DUT(
	    .left, 
        .center,
        .right,
        .k(offset),
        .clk,
        .reset,
        .leftRoot (leftRootOut),
        .rightRoot(rightRootOut)
	);

  	assign i = DUT.discriminant.state;


  	

  	assign leftRoot = decodeUCBFloat(leftRootOut);
  	assign rightRoot = decodeUCBFloat(rightRootOut);
  	
	initial begin: _setup
		
		//we'll simulate intersecting the same
		// surface for the whole simulation, so these
		// don't need to change
        left.left[0]    <= $realtobits(real'($urandom_range(40,0)));//square coefficients
        left.left[1]    <= $realtobits(real'($urandom_range(40,0)));
        left.left[2]    <= $realtobits(real'($urandom_range(40,0)));

        center.left[0]  <= $realtobits(real'($urandom_range(40,0)));//cross-coefficients
        center.left[1]  <= $realtobits(real'($urandom_range(40,0)));
        center.left[2]  <= $realtobits(real'($urandom_range(40,0)));

        right.left[0]   <= $realtobits(real'($urandom_range(40,0)));//linear coefficients
        right.left[1]   <= $realtobits(real'($urandom_range(40,0)));
        right.left[2]   <= $realtobits(real'($urandom_range(40,0)));

		

	end

  	initial begin

    	forever begin: main_tests
      		if (reset) begin
      			left <= '0;
      			center <= '0;
      			right <= '0;
      			offset <= '0;
        		#`CLOCK_PERIOD;
      		end else begin
        
		        @(negedge clk);
		        
		        //simulate that we're intersecting a quadric...
		        if (DUT.ready) begin

					left.right[0]   <= $realtobits(real'($urandom_range(50,0)));
		            left.right[1]   <= $realtobits(real'($urandom_range(50,0)));
		            left.right[2]   <= $realtobits(real'($urandom_range(50,0)));

		            center.right[0] <= $realtobits(real'($urandom_range(50,0)));
		            center.right[1] <= $realtobits(real'($urandom_range(50,0)));
		            center.right[2] <= $realtobits(real'($urandom_range(50,0)));
		            
		            if (i == 0) begin
			            right.right[0]  <= '0;
			            right.right[1]  <= '0;
			            right.right[2]  <= '0;		            	
		            end else begin
		            	if (i == 2) begin
		            		offset <= $realtobits(real'($urandom_range(25,0)));
		            	end else begin
		            		offset <= '0;
		            	end
			            right.right[0]  <= $realtobits(real'($urandom_range(50,0)));
			            right.right[1]  <= $realtobits(real'($urandom_range(50,0)));
			            right.right[2]  <= $realtobits(real'($urandom_range(50,0)));
		            end

		        end//if ready
		    end//if reset	
		end//forever
  	end//initial
endmodule