%Used latest stable Octave 4.2.1 from Octave repository
%https://launchpad.net/~octave/+archive/ubuntu/stable
%Depends on non-linear optimisation and ode solving
%ODE
%https://wiki.octave.org/Odepkg
%At the writing of this file had to use developmental source
% [fname, success] = urlwrite ("https://bitbucket.org/odepkg/odepkg/get/default.tar.gz", [P_tmpdir "/odepkg.tar.gz"]);
 %assert (success)
 %pkg ("install", fname)
%Takes a fair while  but did work in Ubuntu 16.04 Octave version 4.2.1 on 2018/02/03
%NON-LINEAR OPTIMISATION
%Optim is not in the latest repo, install from forge - depends on liboctave-dev (to compile) 
%sudo aptitude install liboctave-dev
%On octave command line 
%pkg install -forge struct optim
%Takes a fair while but did work in Ubuntu 16.04 Octave version 4.2.1 on 2018/02/03

%Run visualiseGPS first to fetch elevations into sampleData/googleElevations. 

fclose all;
close all;
clear all;
clc;
addpath('functions');
addpath('functions/accAna');
dataPath = 'sampleData/';
sensorPaths = {'googleElevations','accLog'};
gpsFile = 'GPS_2018-01-06_104612.txt';	%Look through visualisations to find interesting data
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

%Downhill at around 4 to 5 min. Looks good


