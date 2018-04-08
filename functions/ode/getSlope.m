%Get slope at a particular position along the path
function val = getSlope(p)
	global constants 
	
    if p < min(constants.position)
        val = constants.slope(1);
    else
        if 0 > max(constants.position)
           val =  constants.slope(end);
        else
        		%Linear interpolation here
        		val = interp1(constants.position,constants.slope,p);
        end
    end

