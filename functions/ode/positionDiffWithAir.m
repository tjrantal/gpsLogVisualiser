%Consider only x-direction for acceleration, velocity and direction to keep it as simple as possible
function dydt = positionDiffWithAir(t,y,constants)
	%Calculate air drag acceleration on the vector
	%F D = 1/2*ρAv^2*Cd
	velocity = y(1);
	Fd = 1/2*constants.rho*constants.A*velocity^2*constants.Cd;
	aDrag = -Fd/constants.m;	%Divide with mass to get accelerations

	%Calculate support acceleration, contributes to velocity, and sliding friction
	supportAcc = getSupportAcc(getSlope(y(2)));	%Slope in radians, positive for downhill
	au = supportAcc(1)*constants.u;	%Sliding friction, will be negative as g = -9.81
	
	%disp(sprintf('drag %.2f support %.2f friction %.2f',aDrag,supportAcc(2),au));
	
	dydt = [aDrag+supportAcc(2)+au; ... %accelerations, only x considered..
				y(1)]; %velocities
