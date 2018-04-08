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
sensorPaths = {'googleElevationsNew','lainakannylta/accLog'};
%gpsFile = 'GPS_2018-01-06_104612.txt';	%Change this manually
gpsFile = 'GPS_2018-04-02_093842.txt';	%Change this manually

interestingColumns ={{'tstamp','lat','lon','spee','elevations ['},{'tstamp','x [','y [','z ['}};	%Column headers for interesting columns of data
eleFileName = getMatchingFile(gpsFile,[dataPath sensorPaths{1}]);
accFileName = getMatchingFile(gpsFile,[dataPath sensorPaths{2}]);
disp(sprintf('%s %s',eleFileName,accFileName));
%Read data
eleData = readLog([dataPath sensorPaths{1} '/' eleFileName]);
accData = readLog([dataPath sensorPaths{2} '/' accFileName]);

%Get latitude, longitude and speed column indices
eleColumnIndices = cellfun(@(x) getIndice(eleData.header(1).line,x),interestingColumns{1});
accColumnIndices = cellfun(@(x) getIndice(accData.header(1).line,x),interestingColumns{2});

%Calculate mads

resultant = sqrt(sum((accData.data(:,accColumnIndices(2:4))./9.81).^2,2)); %scale to gs
[mads, madStamps] = getMAD(accData.data(:,accColumnIndices(1)),resultant);

%Plot elevations, speed, and acc mads
eleStamps = eleData.data(:,eleColumnIndices(1));
commonTStamps = [max([madStamps(1),eleStamps(1)]), min([madStamps(end),eleStamps(end)])]; 

eleIndices = find(eleStamps >= commonTStamps(1) & eleStamps <= commonTStamps(2));
madIndices = find(madStamps >= commonTStamps(1) & madStamps <= commonTStamps(2));

%Find downhill with no pedaling by exploring the data manually
ah = [];
figure
subplot(3,1,1)
plot((eleStamps(eleIndices)-commonTStamps(1))./(1000*60),eleData.data(eleIndices,eleColumnIndices(5)),'linewidth',3);
ah(1) = gca();
subplot(3,1,2)
plot((eleStamps(eleIndices)-commonTStamps(1))./(1000*60),eleData.data(eleIndices,eleColumnIndices(4)),'linewidth',3);
ah(2) = gca();
subplot(3,1,3)
plot((madStamps(madIndices)-commonTStamps(1))./(1000*60),mads(madIndices),'linewidth',3);
ah(3) = gca();
linkaxes(ah,'x');

