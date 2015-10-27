discrim:
	vlog +define+CLOCK_PERIOD=5 +define+DEBUG=1 -source UCBRecodedFloat.sv UCBFloatEncoder.v Discriminant.sv DotProduct.sv TestDiscriminant.sv recodedFloatNCompare.v fma64.sv mulAddSubRecodedFloatN.v RayTracingTestInfrastructure.sv
	#vsim -c TestDiscriminant

quadratic:
	vlog +define+CLOCK_PERIOD=5 +define+DEBUG=1 -source UCBRecodedFloat.sv UCBFloatEncoder.v fma64.sv mulAddSubRecodedFloatN.v QuadraticRootFinder.sv TestQuadratic.sv divSqrtRecodedFloat64.v


integration:
	vlog +define+CLOCK_PERIOD=5 +define+DEBUG=1 -source UCBRecodedFloat.sv UCBFloatEncoder.v QuadraticRootFinder.sv Discriminant.sv fma64.sv mulAddSubRecodedFloatN.v IntegrationTester.sv divSqrtRecodedFloat64.v	QuadricIntersector.sv IntegrationTestHarness.sv DotProduct.sv recodedFloatNCompare.v RayTracingTestInfrastructure.sv