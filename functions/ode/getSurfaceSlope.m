%This is where the surface along which we travel is defined
%@params x x-coordinate
%@returns y slope in radians at x
function dy = getSurfaceSlope(x,height)
	y = getSurface(x,height);
	dy = tan(-3/10);
	if y<=0
		dy = 0;
	end
	
