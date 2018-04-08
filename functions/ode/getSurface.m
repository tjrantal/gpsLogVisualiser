%This is where the surface along which we travel is defined
%@params x x-coordinate
%@returns y y-coordinate corresponding to x
function y = getSurface(x,height)
	y = height-3/10*x;
	if y<0
		y = 0;
	end
	
