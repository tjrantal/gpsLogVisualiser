%Run visualiseGPS first to fetch elevations into sampleData/googleElevations. 
%Use this to look for a good epoch for friction evaluation. Needs several seconds of gliding downhill, 
%and a change in velocity to evaluate air drag and friction

fclose all;
close all;
clear all;
clc;
addpath('functions');
addpath('functions/accAna');
dataPath = 'sampleData/';
sensorPaths = {'accLog','gyrLog','magLog'};
accFileName = 'Acc_2018-05-20_085359.txt';	%Change this manually

interestingColumns ={{'tstamp','lat','lon','spee','elevations ['},{'tstamp','x [','y [','z ['}};	%Column headers for interesting columns of data
gyrFileName = getMatchingFile(accFileName,[dataPath sensorPaths{2}]);
magFileName = getMatchingFile(accFileName,[dataPath sensorPaths{3}]);
disp(sprintf('File set %s %s %s',accFileName,gyrFileName,magFileName));

%Read data
accData = readLog([dataPath sensorPaths{1} '/' accFileName]);
gyrData = readLog([dataPath sensorPaths{2} '/' gyrFileName]);
magData = readLog([dataPath sensorPaths{3} '/' magFileName]);


aRes = sqrt(sum(accData.data(:,2:4).^2,2));
gRes = sqrt(sum(gyrData.data(:,2:4).^2,2));
mRes = sqrt(sum(magData.data(:,2:4).^2,2));

%Plot elevations, speed, and acc mads
aStamps = accData.data(:,1);
gStamps = gyrData.data(:,1);
mStamps = magData.data(:,1);
commonTStamps = [max([aStamps(1),gStamps(1),mStamps(1)]), min([aStamps(end),gStamps(end),mStamps(end)])]; 

aIndices = find(aStamps >= commonTStamps(1) & aStamps <= commonTStamps(2));
gIndices = find(gStamps >= commonTStamps(1) & gStamps <= commonTStamps(2));
mIndices = find(mStamps >= commonTStamps(1) & mStamps <= commonTStamps(2));
if 1
	%Find downhill with no pedaling by exploring the data manually
	ah = [];
	figure
	subplot(3,1,1)
	plot((aStamps(aIndices)-commonTStamps(1))./(1000*60),accData.data(aIndices,2:4),'linewidth',3);
	ah(1) = gca();
	subplot(3,1,2)
	plot((gStamps(aIndices)-commonTStamps(1))./(1000*60),gyrData.data(aIndices,2:4),'linewidth',3);
	ah(2) = gca();
	subplot(3,1,3)
	plot((mStamps(aIndices)-commonTStamps(1))./(1000*60),magData.data(aIndices,2:4),'linewidth',3);
	ah(3) = gca();
	linkaxes(ah,'x');
else
	ah = [];
	figure
	subplot(3,1,1)
	plot((aStamps(aIndices)-commonTStamps(1))./(1000*60),aRes(aIndices),'linewidth',3);
	ah(1) = gca();
	subplot(3,1,2)
	plot((gStamps(aIndices)-commonTStamps(1))./(1000*60),gRes(aIndices),'linewidth',3);
	ah(2) = gca();
	subplot(3,1,3)
	plot((mStamps(aIndices)-commonTStamps(1))./(1000*60),mRes(aIndices),'linewidth',3);
	ah(3) = gca();
	linkaxes(ah,'x');
end
