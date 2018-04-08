function distance = calcDistance(lat,lon,pointLength)
	if ~exist('pointLength','var')
		pointLength = 2;
	end
	R = 6371e3; %Earth radius metres
	phi = lat/180*pi;
	lambda = lon/180*pi;
	%deltaphi = diff(phi);%phi(2:end)-phi(1:end-1);
	%deltalambda = diff(lambda);%lambda(2:end)-lambda(1:end-1);
	%deltaT = diff(t);%(2:end)-t(1:end-1);
	deltaphi = phi(pointLength:end)-phi(1:end-(pointLength-1));
	deltalambda = lambda(pointLength:end)-lambda(1:end-(pointLength-1));
	a = sin(deltaphi/2).^2+ ...
		(cos(phi(1:end-(pointLength-1))).*cos(phi(pointLength:end))).*sin(deltalambda/2).^2;
	c = 2*atan2(sqrt(a),sqrt(1-a));
	distance = R*c;
	
