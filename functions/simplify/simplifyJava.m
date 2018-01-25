function [simplified, indices] = simplifyJava(polygonIn, tolerance)
	simplifier = javaObject ("timo.home.seriesreducer.RDPReducer", polygonIn(:,1),polygonIn(:,2), tolerance);
	simplified = [simplifier.getX(), simplifier.getY()];
	indices = simplifier.getIndices()+1;
	
