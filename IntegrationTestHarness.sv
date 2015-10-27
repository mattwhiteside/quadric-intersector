`define CLOCK_PERIOD 10

module IntegrationTestHarness;
	
	reg clk = 0;
	reg reset = 1;
	IntegrationTester #(.clock_length(`CLOCK_PERIOD)) bench(.clk,.reset);
		
	always #(`CLOCK_PERIOD/2) clk = ~clk;

	initial begin 
		#(3*`CLOCK_PERIOD);
		reset = 0;
		$display("finished reset");
		// forever begin
		// end
	end
endmodule