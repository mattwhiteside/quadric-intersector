

import UCBRecodedFloat::*;

module QuadraticRootFinder(
		input logic clk,
		input logic reset,
		input [internalArgWidth-1:0] discriminant,
		input [internalArgWidth-1:0] A,
		input [internalArgWidth-1:0] B,
		input logic inputsValid,
		output logic ready,
		output reg [internalArgWidth-1:0] leftRoot,
		output reg [internalArgWidth-1:0] rightRoot,
		output reg outputsValid
	);

`ifndef RELEASE
typedef struct packed {
  logic [64:0]  a,b,discriminant;
  
} arg_snapshot_t;

localparam MAX_QUEUE_SIZE = 10;
integer k,queueSize;
arg_snapshot_t queue[MAX_QUEUE_SIZE];
`endif

typedef enum logic [3:0] {
	ReadyForInput = 0,
	LatchNewInputs,
	NewInputsLatched,
	StabilizeArgs,
	StabilizeArgs2,
	SetToGo,	
	AwaitingAckFromDivSqrtUnit,
	ArgsReceivedByDivSqrtUnit,
	SetNextOpcode
} machine_state_t;


machine_state_t  MachineState;

reg [internalArgWidth-1:0] _discriminant;


reg  rightRootUnderway, rightRootFinished,  divSqrtOKToStart, denominatorOkToGo, numeratorOkToGo;

var logic [1:0] index;




wire [internalArgWidth-1:0] denominator_or_discriminant;

typedef enum logic [1:0] {
	NOOP = 2'b00,
	DIVISION = 2'b01,
	SQRT = 2'b10	
} Opcode;

Opcode currentOpcode;



var logic [2:0] numSqrtOpsInFlight,numDivisionOpsInFlight,validSqrtCount;

wire logic [3:0] numOpsInFlight = numSqrtOpsInFlight + numDivisionOpsInFlight;
wire logic outValid_div, outValid_sqrt, inReady_sqrt, inReady_div;


//assign ready = (numSqrtOpsInFlight < 3) && (numOpsInFlight < 4) && (MachineState === ReadyForInput);
assign ready = (MachineState === ReadyForInput) & !reset;

reg [0:2][64:0] validSqrtPipelineRegs, denominatorPipelineRegs, discriminantDebugRegs, B_inputPipelineRegs;


 
wire [64:0] _minus_B = {~B[64], B[63:0]};
wire [64:0] T1,divSqrtOut,denominatorOut;
fma64 numerator(
   .clk,.reset,
   .leftMultiplicand( one ),
   .rightMultiplicand( B_inputPipelineRegs[0]),
   .addend( validSqrtPipelineRegs[0] ),
   .proceed( numeratorOkToGo ),
   .out(T1)
);
   
divSqrtRecodedFloat64 divSqrt(
  .clk,
  .reset,
  .io_inReady_div(inReady_div),
  .io_inReady_sqrt(inReady_sqrt),
  .io_inValid(divSqrtOKToStart),
  .io_sqrtOp(currentOpcode === SQRT),
  .io_a(T1),
  .io_b(denominator_or_discriminant),//aka, the input used by the sqrt function
  .io_roundingMode(2'h0),
  .io_outValid_div(outValid_div),
  .io_outValid_sqrt(outValid_sqrt),
  .io_out(divSqrtOut)
    //output[4:0] io_exceptionFlags
); 


assign denominator_or_discriminant = currentOpcode === SQRT ? _discriminant : denominatorPipelineRegs[0];

//assign outputsValid = !reset & divSqrt.io_outValid_div & leftRootFinished;

fma64 denominator(
	.clk, .reset,
	.leftMultiplicand(two),//2.0
	.rightMultiplicand(A),
	.addend(zero),
	.proceed(denominatorOkToGo),
	.out(denominatorOut)
);






always_ff @(posedge clk) begin
	if (reset) begin
		currentOpcode <= SQRT;
		validSqrtCount <= 1'b0;
		rightRootUnderway <= 1'b0;
		rightRootFinished <= 1'b0;
		denominatorOkToGo <= 1'b0;
		denominatorPipelineRegs <= '0;
		discriminantDebugRegs <= '0;
		validSqrtPipelineRegs <= '0;
		B_inputPipelineRegs <= '0;
		numeratorOkToGo <= 1'b0;
		numSqrtOpsInFlight <= '0;
		numDivisionOpsInFlight <= '0;
		
		outputsValid <= 1'b0;
		MachineState <= ReadyForInput;
		queueSize <= 0;
		
	end else begin
		assert (numOpsInFlight <= 4) else $error("PIPELINE ABOVE CAPACITY!");
		assert (queueSize === numOpsInFlight) else $error("debug queue out of sync with pipeline");		

		if (outputsValid)
			outputsValid <= outputsValid & outValid_div;

		
		if (outValid_div | outValid_sqrt) begin
		  	
		  	

			if (outValid_div) begin
			 	if (rightRootFinished) begin
			 		rightRootFinished <= 1'b0;
			 		leftRoot <= divSqrtOut;
			 		outputsValid <= 1'b1;		
`ifndef RELEASE

					for(k = 0; k < MAX_QUEUE_SIZE - 1; k++) begin	  		
						queue[k] <= queue[k+1];
				  	end			 			 		
				  	queue[MAX_QUEUE_SIZE-1] <= zero;
				  	queueSize <= queueSize - 1;
`endif					
			 	end else begin
			 		rightRootFinished <= 1'b1;		 		
			 		rightRoot <= divSqrtOut;
			 	end 
			 	numDivisionOpsInFlight <= numDivisionOpsInFlight - 1;
			end else begin		 	
				validSqrtCount <= validSqrtCount + 1;			
				validSqrtPipelineRegs[validSqrtCount] <= divSqrtOut;
				numSqrtOpsInFlight <= numSqrtOpsInFlight - 1;
			end

		end else begin 
			unique case (MachineState)
			  ReadyForInput: begin
			  	//extra cycle for opcode to settle
			  	// if (numSqrtOpsInFlight >= 3 || numOpsInFlight >= 4) begin
			  	// 	$display("pipeline is full");
			  	// end else 

			  	if (currentOpcode === SQRT) begin
				  	if (inputsValid) begin
				  		denominatorOkToGo <= 1'b1;
				  		MachineState <= NewInputsLatched;
				  		_discriminant <= discriminant;
`ifndef RELEASE			
						for(k = 0; k < MAX_QUEUE_SIZE - 1; k++) begin	  		
							queue[k+1] <= queue[k];

				  			
				  		end
				  		queue[0] <= {A,B,discriminant};
				  		queueSize <= queueSize + 1;
`endif
				  	end
				end else begin
					if (validSqrtCount > 0) begin
						numeratorOkToGo <= 1'b1;
						MachineState <= NewInputsLatched;
						
					end
				end
			  end


			  NewInputsLatched: begin			  	
			  	if (currentOpcode === SQRT) begin
			  		denominatorOkToGo <= 1'b0;
			  	end else begin
			  		numeratorOkToGo <= 1'b0;
			  	end
			  	MachineState <= StabilizeArgs;

			  end

			  StabilizeArgs: begin
			  	MachineState <= SetToGo;
			  end

			  // StabilizeArgs2: begin
			  // 	MachineState <= SetToGo;
			  // end



			  SetToGo: begin
				divSqrtOKToStart <= 1'b1;
				MachineState <= AwaitingAckFromDivSqrtUnit;
			  end


			  AwaitingAckFromDivSqrtUnit: begin
			  	if (currentOpcode === SQRT) begin
				  	if (inReady_sqrt) begin
				  		denominatorPipelineRegs[numSqrtOpsInFlight] <= denominatorOut;
				  		B_inputPipelineRegs[numSqrtOpsInFlight] <= _minus_B;
					  	discriminantDebugRegs[numSqrtOpsInFlight] <= _discriminant;
				  		numSqrtOpsInFlight <= numSqrtOpsInFlight + 1;

				  		MachineState <= ArgsReceivedByDivSqrtUnit;
				  		
				  	end
				end else begin
					if (inReady_div) begin
			  			numDivisionOpsInFlight <= numDivisionOpsInFlight + 1;
				  		if (rightRootUnderway) begin
				  			validSqrtCount <= validSqrtCount - 1;			  			
				  			validSqrtPipelineRegs[0] <= validSqrtPipelineRegs[1];
				  			validSqrtPipelineRegs[1] <= validSqrtPipelineRegs[2];
				  			validSqrtPipelineRegs[2] <= zero;
				  			denominatorPipelineRegs[0] <= denominatorPipelineRegs[1];
				  			denominatorPipelineRegs[1] <= denominatorPipelineRegs[2];
				  			denominatorPipelineRegs[2] <= zero;
				  			discriminantDebugRegs[0] <= discriminantDebugRegs[1];
				  			discriminantDebugRegs[1] <= discriminantDebugRegs[2];
				  			B_inputPipelineRegs[0] <= B_inputPipelineRegs[1];
				  			B_inputPipelineRegs[1] <= B_inputPipelineRegs[2];
							B_inputPipelineRegs[2] <= zero;
				  			rightRootUnderway <= 1'b0;
				  		end else begin
				  			validSqrtPipelineRegs[0] <= {~validSqrtPipelineRegs[0][64],validSqrtPipelineRegs[0][63:0]};
				  			rightRootUnderway <= 1'b1;
				  		end

			  		
				  		MachineState <= ArgsReceivedByDivSqrtUnit;
					  		
				    end
				end
			  end

			  ArgsReceivedByDivSqrtUnit: begin
			  	divSqrtOKToStart <= 1'b0;

			  	MachineState <= SetNextOpcode;
			  end

			  SetNextOpcode: begin
				if (validSqrtCount > 0) begin
			  		currentOpcode <= DIVISION;
			  	end else begin
			  		currentOpcode <= SQRT;
			  	end
			  	if (numSqrtOpsInFlight < 3 && numOpsInFlight < 4) begin
			  	 	MachineState <= ReadyForInput;
			  	end  



			  end


			endcase 
		end



	end
end










endmodule