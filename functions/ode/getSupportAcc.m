function supportAcc = getSupportAcc(theta)
	global constants
	gravitationalForce = [constants.g; 0];
	rotMat = [cos(theta), -sin(theta); sin(theta), cos(theta)];
	supportAcc = rotMat*gravitationalForce;

