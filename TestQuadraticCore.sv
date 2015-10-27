import UCBRecodedFloat::*;

`ifdef DEBUG

typedef struct {
  real  a,b,c,discriminant,_leftRoot,_rightRoot;
  
} arg_snapshot_t;
localparam MAX_QUEUE_SIZE = 10;

arg_snapshot_t currentArgs;
arg_snapshot_t queue[$:MAX_QUEUE_SIZE];
`endif

integer k;
real a,b,c,_a,_b,_discrim,_leftRoot,_rightRoot,leftNum,rightNum;

var logic [IEEE_argWidth-1:0] _A = '0,_B = '0,_C = '0,_discriminant = '0;
//var logic clk, reset;

UCBFloatEncoder A(.io_in(_A));
UCBFloatEncoder B(.io_in(_B));
UCBFloatEncoder discrim(.io_in(_discriminant));
UCBFloatEncoder _two(.io_in($realtobits(2.0)));
UCBFloatEncoder _four(.io_in($realtobits(4.0)));


reg valid;

//chip_bus bus_if(.clk,.reset);
QuadraticRootFinder qrf(
		.A(A.io_out),
		.B(B.io_out),
		.inputsValid(1'b1),
		.clk,.reset,
		.discriminant(discrim.io_out)
);








initial begin

	a = 3.0;
	b = 8.0;
	c = 4.0;
	valid = 0;

	//currentArgs = {a: a, b: b, c: c, discriminant:  b*b - 4.0 * a * c, 
	//						_leftRoot: (-b-$sqrt(b*b-4.0*a*c))/(2.0*a), _rightRoot: (-b+$sqrt(b*b-4.0*a*c))/(2.0*a)};

	_A = $realtobits(a);
	_B = $realtobits(b);
	_discriminant = $realtobits(b*b - 4*a*c);
	clk = 0;
	#1;
	reset = 1;

	#(5*`CLOCK_PERIOD + 1);
	reset = 0;
	#(`CLOCK_PERIOD + 1);
	valid = 1;

	// @(posedge clk);
	// @(posedge clk);
	$display("finished reset");
end

initial begin 
	
    forever begin

    	@(negedge clk);  	
    	if (!reset && qrf.ready) begin

	 		_A <= $realtobits(a);
	 		_B <= $realtobits(b);
	 		_discriminant <= $realtobits(b*b - 4.0 * a * c);
			
			a <= a + 1.0;
			b <= b + 2.0;
			c <= c + 1.0;
	 		
	 		$display("enqueueing new args");
	 	end else if (qrf.outputsValid) begin
	 		$display("dequeueing new args");
	 		
      	end

		@(posedge clk);
		$display("_discriminant = %f (input at %f)", $bitstoreal(decodeUCBFloat(qrf._discriminant)), $bitstoreal(decodeUCBFloat(discrim.io_out)));
		$display("numerator R = %f (input at %f)", $bitstoreal(decodeUCBFloat(qrf.numerator.r_inputReg)),$bitstoreal(decodeUCBFloat(A.io_out)));
		$display("-B = %f (input at %f)", $bitstoreal(decodeUCBFloat(qrf._minus_B)),$bitstoreal(decodeUCBFloat(B.io_out)));
		
		
		$display("numerator l_inputReg = %f",$bitstoreal(decodeUCBFloat(qrf.numerator.l_inputReg)));
		$display("numerator r_inputReg = %f",$bitstoreal(decodeUCBFloat(qrf.numerator.r_inputReg)));	
		$display("numerator addend_inputReg = %f",$bitstoreal(decodeUCBFloat(qrf.numerator.addendInputReg)));

		$display("denominator l_inputReg = %f",$bitstoreal(decodeUCBFloat(qrf.denominator.l_inputReg)));
		$display("denominator r_inputReg = %f (input at %f)",$bitstoreal(decodeUCBFloat(qrf.denominator.r_inputReg)),
															$bitstoreal(decodeUCBFloat(A.io_out)));	
		$display("denominator.io_out = %f",$bitstoreal(decodeUCBFloat(qrf.denominator.io_out)));
		
		$display("denominatorStagingRegs[0] = %f", $bitstoreal(decodeUCBFloat(qrf.denominatorPipelineRegs[0])));
		$display("denominatorStagingRegs[1] = %f", $bitstoreal(decodeUCBFloat(qrf.denominatorPipelineRegs[1])));
		$display("denominatorStagingRegs[2] = %f", $bitstoreal(decodeUCBFloat(qrf.denominatorPipelineRegs[2])));


		$display("validSqrtCount = %d", qrf.validSqrtCount);
		$display("validSqrtPipelineRegs[0] = %f", $bitstoreal(decodeUCBFloat(qrf.validSqrtPipelineRegs[0])));
		$display("validSqrtPipelineRegs[1] = %f", $bitstoreal(decodeUCBFloat(qrf.validSqrtPipelineRegs[1])));
		$display("validSqrtPipelineRegs[2] = %f", $bitstoreal(decodeUCBFloat(qrf.validSqrtPipelineRegs[2])));

		$display("B_inputPipelineRegsRegs[0] = %f", $bitstoreal(decodeUCBFloat(qrf.B_inputPipelineRegs[0])));
		$display("B_inputPipelineRegsRegs[1] = %f", $bitstoreal(decodeUCBFloat(qrf.B_inputPipelineRegs[1])));
		$display("B_inputPipelineRegsRegs[2] = %f", $bitstoreal(decodeUCBFloat(qrf.B_inputPipelineRegs[2])));



		$display("numerator out = %f",$bitstoreal(decodeUCBFloat(qrf.numerator.io_out)));
		

		$display("sqrt ready = %b",qrf.divSqrt.io_inReady_sqrt);
		$display("div ready = %b",qrf.divSqrt.io_inReady_div);
		
		$display("sqrt Valid = %b", qrf.divSqrt.io_outValid_sqrt);
		$display("div Valid = %b", qrf.divSqrt.io_outValid_div);
		$display("divSqrtOKToStart = %b", qrf.divSqrtOKToStart);
		
		$display("numOpsInFlight = %d", qrf.numOpsInFlight);
		$display("numSqrtOpsInFlight = %d", qrf.numSqrtOpsInFlight);
		$display("numDivisionOpsInFlight = %d", qrf.numDivisionOpsInFlight);
		$display("currentOpcode = %s", qrf.currentOpcode.name);
		$display("machineState = %s", qrf.MachineState.name);
		$display("divSqrt.io_a: %f",$bitstoreal(decodeUCBFloat(qrf.divSqrt.io_a)));
		$display("divSqrt.io_b: %f",$bitstoreal(decodeUCBFloat(qrf.divSqrt.io_b)));	

		$display("divSqrt.out: %f",$bitstoreal(decodeUCBFloat(qrf.divSqrt.io_out)));
		
		$display("outputsValid = %b", qrf.outputsValid);
		$display("ready = %b", qrf.ready);


		$display("_leftRoot = %f", $bitstoreal(decodeUCBFloat(qrf.leftRoot)));
		$display("_rightRoot = %f", $bitstoreal(decodeUCBFloat(qrf.rightRoot)));
		
		
		for (k = 0; k < qrf.queueSize; k++) begin
			_a = $bitstoreal(decodeUCBFloat(qrf.queue[k].a));
			_b = $bitstoreal(decodeUCBFloat(qrf.queue[k].b));
			_discrim = $bitstoreal(decodeUCBFloat(qrf.queue[k].discriminant));
			leftNum = -_b - $sqrt(_discrim);
			rightNum = -_b + $sqrt(_discrim);
			
			_leftRoot = leftNum/(2.0*_a);	
			_rightRoot = rightNum/(2.0*_a);

			$display("(%0d): a = %f, b = %f, d = %f, sqrtD = %f,leftN = %f, rightN = %f, left = %f, right = %f",
								 k,_a, _b, _discrim,$sqrt(_discrim),leftNum,rightNum,_leftRoot,_rightRoot);

		end
	
		$display("");
		$display("");

      
    end
end

