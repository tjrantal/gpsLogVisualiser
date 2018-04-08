function dydt = positionDiffWithAir(t,y,constants)
	%Calculate air drag acceleration on the vector
	%F D = 1/2*ρAv^2*Cd
	velocityVector = [y(1), y(2), y(3)];
	velocity = norm(velocityVector);
	Fd = 1/2*constants.rho*constants.A*velocity^2*constants.Cd;
	aRes = Fd/constants.m;	%Divide with mass to get accelerations
	
	%Calculate rolling friction
	
	surfaceHeight = getSurface(y(4),constants.height);	%Traveling along X-axis, y(4) = x-position
	slope = getSurfaceSlope(y(4),constants.height);	%Slope in radians, positive for downhill
	%Calculate support force, cannot go through the surface, calculate upwards force based on penetration depth
	gravitationalForce = [-1 0 0]*9.81*constants.m;
	penetrationDepth = surfaceHeight-y(5);
	%disp(sprintf('Slope x %.2f angle %.2f',y(4),slope/pi*180));
	if penetrationDepth > 0 
		rotQuat = [cos(slope/2), sin(slope/2)*[0 0 1] ];
		supportDirectionVector = quaternProd(quaternProd(rotQuat,[0 0 1 0]),quaternConj(rotQuat));
		supportForce = penetrationDepth*constants.k*supportDirectionVector(2:4);
		dampingForce = -y(2)*constants.b; %Opposite to centre of mass velocity
	else
		supportForce = [0, 0, 0];
		dampingForce = 0;
		
	end
	supportAcc = supportForce/constants.m;
	dampingAcc = dampingForce/constants.m;
	%disp(sprintf('x %.2f penevel %.2f support acc %.2f damping %.2f',y(4),y(7)*1000,supportAcc(2),dampingAcc));
	%sliding friction
	au = -supportForce(2)*constants.u/constants.m;
	
	%calculate direction of velocity with quaternions, air drag direction is always opposite to velocity
	xAxis = [1, 0, 0];
	if norm(velocityVector) ~= 0	%Replace with epsilon
		vUnit = velocityVector./norm(velocityVector);
		qRot = quaternProd([0,-1,0,0],[0,vUnit]);
		qRot = qRot./norm(qRot);
	else
		qRot = [1, 0, 0, 0];
	end
	aVec = [-aRes, 0, 0]; %negative value for resultant (drag never accelerates the object)
	a = quaternProd([0, aVec],qRot);	
	a = a(2:4);
	%disp(sprintf('Air drag acc x %.2f y %.2f',a(1),a(2)));
	
	
	dydt = [a(1)+supportAcc(1)-abs(supportAcc(2)*constants.u); a(2)+supportAcc(2)+dampingAcc+constants.g; a(3); ... %accelerations
				y(1); y(2); y(3)]; %velocities
