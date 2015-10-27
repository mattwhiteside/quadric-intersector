   
import UCBRecodedFloat::*;
`ifdef DEBUG
//non-synthesizable stuff; classes, etc
import RayTracingTestInfrastructure::*;
`endif


module Discriminant(
      input VecPair left, //see 'background.pdf' for an explanation of these args
      input VecPair center,
      input VecPair right,
      input [IEEE_argWidth-1:0] k,//offset of the quadric from the origin
      input logic proceed,
      input logic clk,
      input logic reset,
      output logic [internalArgWidth-1:0] out,//aka, B**2 - 4*A*C
      output logic [internalArgWidth-1:0] B,
      output logic [internalArgWidth-1:0] A,
      output logic valid);

localparam nKStages = 5;
wire logic [internalArgWidth-1:0] zero = 65'h0;
wire logic [internalArgWidth-1:0] one = 65'h8000000000000000;
wire logic [internalArgWidth-1:0] kEncoderOut;
var logic [1:0] state;
var logic [internalArgWidth-1:0] rightDPDelayReg;

`ifdef DEBUG


localparam numPipelineStages = 9;
arg_snapshot_t pastArgs[numPipelineStages];
int proceedCount;
VecPair pastLeftArgs[numPipelineStages];
VecPair pastCenterArgs[numPipelineStages];
VecPair pastRightArgs[numPipelineStages];
genvar debugPipelineStage;
`endif


logic [internalArgWidth-1:0] kRegs[nKStages];
UCBFloatEncoder kEncoder(.io_in(k),.io_out(kEncoderOut));

genvar i;

//k needs pipeline regs, because it is not going through
// the series of fma64s, which have built in registers
generate
   for (i = 0; i < nKStages; i++) begin: _k_regs
      logic [internalArgWidth-1:0] _reg;
      if (i == 0) begin
         always_ff @(posedge clk) begin
            if (reset) begin
               _k_regs[i]._reg <= 0;
            end else begin
               if (proceed) begin
                  _k_regs[i]._reg <= kEncoderOut;
               end
            end
         end
      end else begin
         always_ff @(posedge clk) begin
            if (reset) begin
               _k_regs[i]._reg <= 0;
            end else begin
               if (proceed) begin
                  _k_regs[i]._reg <= _k_regs[i-1]._reg;
               end
            end
         end
      end
   end
endgenerate


wire logic [internalArgWidth-1:0] left_out,A_out,B_out, C_out, 
                                  right_out,center_out,
                                  _4A_out,_4AC_out, B_squared_out;




DotProduct _left(.clk,.reset,.proceed,
                  .left(left.left),
                  .right(left.right),
                  .out(left_out));

DotProduct _center(.clk,.reset,.proceed,
                  .left(center.left),
                  .right(center.right),
                  .out(center_out));

DotProduct _right(.clk,.reset,.proceed,
                  .left(right.left),
                  .right(right.right),
                  .out(right_out));




fma64 _A(.clk, .reset,
   .leftMultiplicand( one ),
   .rightMultiplicand( left_out ),
   .addend( center_out ),
   .out(A_out),
   .proceed
);

fma64 _B(.clk, .reset,
   .leftMultiplicand( one ),
   .rightMultiplicand( A_out ),
   .addend( rightDPDelayReg ),
   .out(B_out),
   .proceed
);

fma64 _C(.clk, .reset,
   .leftMultiplicand( one),
   .rightMultiplicand( _k_regs[nKStages-1]._reg ),
   .addend( B_out),
   .out(C_out),
   .proceed(proceed & (state === 1))
);

fma64 _4A(.clk(clk), .reset(reset),
   .leftMultiplicand( A_out ),
   .rightMultiplicand( 65'h8020000000000000 ),
   .addend( zero),
   .out(_4A_out),
   .proceed( proceed & (state === 1))
);

reg [internalArgWidth-1:0] post_4A_reg,post_BB_reg;

fma64 _B_squared(.clk(clk), .reset(reset),
   .leftMultiplicand( B_out ),
   .rightMultiplicand( B_out),
   .addend( zero ),
   .out(B_squared_out),
   .proceed( proceed & (state === 0) )//latch B 2 ticks after A
);

fma64 _4AC(.clk(clk), .reset(reset),
   .leftMultiplicand( post_4A_reg ),
   .rightMultiplicand( C_out ),
   .addend( zero ),
   .out(_4AC_out),
   .proceed
);

wire [internalArgWidth-1:0] minus_4AC = {~_4AC_out[internalArgWidth-1],_4AC_out[internalArgWidth-2:0]};

fma64 B_squared_minus_4AC(
   .clk,
   .reset,
   .leftMultiplicand( one ),
   .rightMultiplicand( post_BB_reg ),
   .addend( minus_4AC ),
   .out(out),
   .proceed
);

recodedFloatNCompare comparator(
    .io_a(zero),
    .io_b(out),
    .io_a_lt_b(valid)
);

assign B =  B_out;
assign A = A_out;

`ifdef DEBUG


property outputIsCorrect;
  
  @(posedge clk) disable iff (state != 2'b0)
   
      (proceedCount > numPipelineStages)
        
        |=> 
            $realtobits(
               computeDiscrim(
                  pastArgs[numPipelineStages-1],
                  pastArgs[numPipelineStages-2],
                  pastArgs[numPipelineStages-3]
               )
            ) === decodeUCBFloat(out);
endproperty 

assert property(outputIsCorrect) begin 
   $display("success! expected %f, got %f",            
      computeDiscrim(
         pastArgs[numPipelineStages-1],
         pastArgs[numPipelineStages-2],
         pastArgs[numPipelineStages-3]
      ),
      $bitstoreal(decodeUCBFloat(out))
   );

end else begin 
   $error("expected %f, got %f",
      computeDiscrim(
         pastArgs[numPipelineStages-1],
         pastArgs[numPipelineStages-2],
         pastArgs[numPipelineStages-3]
      ),
      $bitstoreal(decodeUCBFloat(out))
   );
end



`endif

always_ff @(posedge clk) begin

   if (reset) begin
      state <= 0;
      rightDPDelayReg <= '0;
      post_4A_reg <= '0;
      post_BB_reg <= '0;
`ifdef DEBUG
      proceedCount <= 0;
`endif

   end else begin
      if (proceed) begin
         post_4A_reg <= _4A_out;
         post_BB_reg <= B_squared_out;
         rightDPDelayReg <= right_out;
         state <= (state + 1) % 3;
`ifdef DEBUG
         proceedCount <= proceedCount + 1;
`endif

      end
   end
end

`ifdef DEBUG
generate
for (debugPipelineStage = 0; debugPipelineStage < numPipelineStages; debugPipelineStage++) begin
   always_ff @(posedge clk) begin : proc_
      if(reset) begin
         pastArgs[debugPipelineStage] = '0;
      end else if (proceed) begin
         if (debugPipelineStage == 0) begin
            pastArgs[0] <= '{left: left, center:center, right:right,k: k};
         end else begin
            pastArgs[debugPipelineStage] <= pastArgs[debugPipelineStage - 1];
         end
      end
   end
end
endgenerate
`endif

endmodule