// Create Date: 05/10/2015 05:11:18 PM

/*

This files tests the Discriminant unit with randomized 
test vectors (generated using classes & constraints) 
that simulate a raytracing scenario.


Note: this testbench is note synthesizable;

*/


import UCBRecodedFloat::*;
import RayTracingTestInfrastructure::*;



module TestDiscriminant;

  localparam NStages = 11;

  parameter clk_length = `CLOCK_PERIOD;
  var logic [IEEE_argWidth-1:0] a,b,c;

  reg [63:0] k;
  VecPair left, center,right;
  
  reg reset;
  reg clk = 1;

  bench _bench(clk);

  always #clk_length clk = ~clk;
  reg proceed;
  Discriminant DUT(
        .clk,
        .proceed,
        .reset,
        .left,
        .center,
        .right,        
        .k
  );



endmodule

program bench(input clk);
  localparam reset_period = `CLOCK_PERIOD * 4;
  import UCBRecodedFloat::*;
  
  int j;
  wire logic [1:0] i;

  assign i = TestDiscriminant.DUT.state;
  Camera camera;
  Sphere sphere;
  //QuadricSurface sphere;
  Vec3Real c = {2.0,-4.0,7.1};
  Vec3Real r = {x:3.0,y:3.0,z:3.0};

  Vec3Real v1,v2,v3,v4,v5,v6,v7,v8;//used in raytracing tests

  Ray ray;

  int numCyclesProceedHasBeenAsserted = 0;
  int checkPoint = 0;
  

  initial begin: _startup
    TestDiscriminant.reset = 1;
    #reset_period;
    camera = new({x:-5.0,y:0.0,z:5.0},//position
                 {x:0.0,y:0.0,z:0.0},//lookAt
                 {x:1.0,y:0.0,z:4.0},//upVector
                 1.047//about 60 degree field of view
    );
    
    sphere = new(1.2, {x:2.0,y:0.0,z:-3.0});

    
    Ray::camera = camera;     
    ray = new();

    TestDiscriminant.reset = 0;
    $display("finished reset");
    TestDiscriminant.proceed = 1;

  end
  initial begin

    forever begin: randomized_tests
      if (TestDiscriminant.reset) begin
        #`CLOCK_PERIOD;
      end else begin
        
        @(posedge clk);
        TestDiscriminant.proceed <= $urandom_range(1,0);
        // this block sets up the parameters for the ray-tracing simulation;
        // see: http://users.wowway.com/~phkahler/quadrics.pdf

        TestDiscriminant.left.left[0]    <= $realtobits(sphere.SCs.x);//square coefficients
        TestDiscriminant.left.left[1]    <= $realtobits(sphere.SCs.y);
        TestDiscriminant.left.left[2]    <= $realtobits(sphere.SCs.z);

        TestDiscriminant.center.left[0]  <= $realtobits(sphere.CCs.x);//cross-coefficients
        TestDiscriminant.center.left[1]  <= $realtobits(sphere.CCs.y);
        TestDiscriminant.center.left[2]  <= $realtobits(sphere.CCs.z);

        TestDiscriminant.right.left[0]   <= $realtobits(sphere.LCs.x);//linear coefficients
        TestDiscriminant.right.left[1]   <= $realtobits(sphere.LCs.y);
        TestDiscriminant.right.left[2]   <= $realtobits(sphere.LCs.z);
        if (TestDiscriminant.DUT.proceed) begin
          if (i == 0) begin
            assert(ray.randomize());  

            v1 <= {x:ray.dir.x**2, y:ray.dir.y**2, z: ray.dir.z**2};
            v2 <= {x:2.0*ray.dir.x*ray.dir.y, y:2.0*ray.dir.y*ray.dir.z, z: 2.0*ray.dir.x*ray.dir.z};
            v3 <= {x:2.0*ray.source.x*ray.dir.x, y:ray.source.y*ray.dir.y, z: ray.source.z*ray.dir.z};
            v4 <= {x:2.0*(ray.dir.x*ray.source.y + ray.source.x*ray.dir.y), 
                   y:2.0*(ray.source.y*ray.dir.z + ray.dir.y*ray.source.z),
                   z:2.0*(ray.source.x*ray.dir.z + ray.dir.x*ray.source.z)};
            v5 <= {x:2.0*ray.dir.x, y: 2.0*ray.dir.y, z:2.0*ray.dir.z};
            v6 <= {x:ray.source.x**2, y:ray.source.y**2, z: ray.source.z**2};
            v7 <= {x:2.0*ray.source.x*ray.source.y, y: 2.0*ray.source.y*ray.source.z, z: 2.0*ray.source.x*ray.source.z};
            v8 <= {x:2.0*ray.source.x, y: 2.0*ray.source.y, z: 2.0*ray.source.z};
            //$display("ray.x = %d, ray.y = %d",ray.x,ray.y);
            TestDiscriminant.left.right[0]   <= $realtobits(v1.x);
            TestDiscriminant.left.right[1]   <= $realtobits(v1.y);
            TestDiscriminant.left.right[2]   <= $realtobits(v1.z);

            TestDiscriminant.center.right[0] <= $realtobits(v2.x);
            TestDiscriminant.center.right[1] <= $realtobits(v2.y);
            TestDiscriminant.center.right[2] <= $realtobits(v2.z);
            

            TestDiscriminant.right.right[0]  <= $realtobits(0.0);
            TestDiscriminant.right.right[1]  <= $realtobits(0.0);
            TestDiscriminant.right.right[2]  <= $realtobits(0.0);
            
            TestDiscriminant.k <= $realtobits(0.0);
            
          end else if (i == 1) begin 
            TestDiscriminant.left.right[0]   <= $realtobits(v3.x);
            TestDiscriminant.left.right[1]   <= $realtobits(v3.y);
            TestDiscriminant.left.right[2]   <= $realtobits(v3.z);

            TestDiscriminant.center.right[0] <= $realtobits(v4.x);
            TestDiscriminant.center.right[1] <= $realtobits(v4.y);
            TestDiscriminant.center.right[2] <= $realtobits(v4.z);
            
            TestDiscriminant.right.right[0]  <= $realtobits(v5.x);
            TestDiscriminant.right.right[1]  <= $realtobits(v5.y);
            TestDiscriminant.right.right[2]  <= $realtobits(v5.z);
            
            TestDiscriminant.k <= $realtobits(0.0);

            
          end else begin //i == 0
            TestDiscriminant.left.right[0]   <= $realtobits(v6.x);
            TestDiscriminant.left.right[1]   <= $realtobits(v6.y);
            TestDiscriminant.left.right[2]   <= $realtobits(v6.z);

            TestDiscriminant.center.right[0] <= $realtobits(v7.x);
            TestDiscriminant.center.right[1] <= $realtobits(v7.y);
            TestDiscriminant.center.right[2] <= $realtobits(v7.z);
            
            TestDiscriminant.right.right[0]  <= $realtobits(v8.x);
            TestDiscriminant.right.right[1]  <= $realtobits(v8.y);
            TestDiscriminant.right.right[2]  <= $realtobits(v8.z);
            
            TestDiscriminant.k <= $realtobits(sphere.offset);
            
          end    
        end
      end
      
    end


  end
  
  
  
endprogram