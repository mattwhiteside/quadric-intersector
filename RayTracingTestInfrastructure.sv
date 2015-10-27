package RayTracingTestInfrastructure;

import UCBRecodedFloat::*;
typedef struct{
	real x,y,z;
} Vec3Real;

function automatic Vec3Real normalize(Vec3Real v);
	Vec3Real ret;
	real norm = $sqrt(v.x**2 + v.y**2 + v.z**2);
	ret.x = v.x/norm;
	ret.y = v.y/norm;
	ret.z = v.z/norm;
	return ret;
endfunction

function Vec3Real crossProduct(Vec3Real left, right);
	return '{x: left.y*right.z - left.z*right.y,
			y: left.z*right.x - left.x*right.z,
			z: left.x*right.y - left.y*right.x
	};
endfunction

class Camera;
	static const int xPixels = 640, yPixels = 480;
	Vec3Real position, lookAt, upVector, LOS, reverseLOS, lateral;
	real fovyRadians, fovxRadians;
	function new(Vec3Real position,lookAt,upVector,
				 real fovyRadians);
		
		this.position = position;
		this.lookAt = lookAt;
		this.upVector = upVector;
		this.fovyRadians = fovyRadians;
		this.fovxRadians = 2.0*$atan($tan(fovyRadians/2.0)*(real'(xPixels)/real'(yPixels)));		
		$display("setting fovy!: %f",this.fovxRadians);
		this.LOS = normalize('{x: position.x - lookAt.x, y: position.y - lookAt.y, z: position.z - lookAt.z});		
		this.reverseLOS = '{x:-1.0*LOS.x,y:-1.0*LOS.y,z:-1.0*LOS.z};
		this.lateral = normalize(crossProduct(this.upVector,this.reverseLOS));

	endfunction
endclass


class QuadricSurface;
	
	// the parameters of the quadric surface;	
	// making it public for simplicity and lack of time
	Vec3Real LCs,//linear coefficients
			 CCs,//cross-coefficients
			 SCs;//square-coefficients
	real offset;
	
	function new(Vec3Real SCs, CCs, LCs,
				 real offset);
	    this.LCs = LCs;
	    this.CCs = CCs;
	    this.SCs = SCs;
	    this.offset = offset;
	endfunction

endclass


class UnrotatedEllipsoid extends QuadricSurface;
	function new(Vec3Real r, Vec3Real c); 
		super.new('{x:1.0/(r.x**2),y:1.0/(r.y**2),z:1.0/(r.z**2)},    //coefficients of degree 2 terms
				  '{x:0.0,y:0.0,z:0.0},								//coefficients of cross-terms
				 	           										//(zero since no rotation)
				  '{x:-c.x/(r.x**2),y:-c.y/(r.y**2),z:-c.z/(r.z**2)},//coefficients of linear terms
				  -1.0 + (c.x/r.x)**2 + (c.y/r.y)**2 + (c.z/r.z)**2); //offset from origin
	endfunction
endclass 

class Sphere extends UnrotatedEllipsoid;
	function new(real radius, Vec3Real c); 

		super.new('{x:radius,y:radius,z:radius},c); 
		$display("hello sphere");
	endfunction	
endclass


class Ray;
	Vec3Real source;
	rand Vec3Real dir;
	static Camera camera;//all rays emanate from the same camera,
						 //hence the static variable. this is just
						 // for simplicity of testing
	
	rand int x,y;//pixel coordinates
	real alpha,beta;//used in calculating the ray direction
	constraint c {
		x < Camera::xPixels && x >= 0;
		y < Camera::yPixels && y >= 0;
	}

	function new();
		// the static variable 'camera' needs to be set
		// before this is called
		source = camera.position;
	endfunction



	function void post_randomize();
        this.beta = $tan(camera.fovyRadians/2.0) * (real'(Camera::xPixels)/2.0 - y - 0.5)/(real'(Camera::xPixels)/2.0);
		this.alpha = $tan(camera.fovxRadians/2.0)*((2.0*x + 1.0 - real'(Camera::xPixels))/real'(Camera::xPixels));
		//$display("post randomize: alpha = %f, beta = %f",alpha,beta);
		this.dir = '{x: alpha * camera.lateral.x + beta*camera.reverseLOS.x - camera.LOS.x,
			   		y: alpha * camera.lateral.y + beta*camera.reverseLOS.y - camera.LOS.y,
			   		z: alpha * camera.lateral.z + beta*camera.reverseLOS.z - camera.LOS.z
		};
	endfunction
endclass


function real _dotProduct(input VecPair vecs);
	return $bitstoreal(vecs.left[0])*$bitstoreal(vecs.right[0]) +  
	       $bitstoreal(vecs.left[1])*$bitstoreal(vecs.right[1]) + 
	       $bitstoreal(vecs.left[2])*$bitstoreal(vecs.right[2]);
endfunction


function real tripleDotProduct(input arg_snapshot_t args);
	return _dotProduct(args.left) + _dotProduct(args.center) + _dotProduct(args.right);
endfunction

function real computeDiscrim(input arg_snapshot_t A,B,C);
	return tripleDotProduct(B)**2 - 4.0*tripleDotProduct(A)*(tripleDotProduct(C)+$bitstoreal(C.k));
//return tripleDotProduct(args[1][0],args[1][1],args[1][2])**2 - 4.0*tripleDotProduct(args[0][0],args[0][1],args[0][2])*tripleDotProduct(args[2][0],args[2][1],args[2][2]);
endfunction


endpackage