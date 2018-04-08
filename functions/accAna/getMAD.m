%Calculate 1 s epoch mean amplitude deviation
%tStamps = time stamps of the samples in milliseconds
function [mads, initStamps] = getMAD(tStamps,data,epochSeconds)
	if ~exist('epochSeconds','var')
		epochSeconds = 1;
	end
	initStamps = tStamps(1):(epochSeconds*1000):tStamps(end);
	mads = zeros(size(initStamps,1),size(initStamps,2));
	for i = 1:length(initStamps)-1
		mads(i) = calcMad(tStamps,data,[initStamps(i),initStamps(i+1)]);
	end
	%Remove the first time stamp, mad calculate for the preceding epoch
	initStamps = initStamps(2:end);
