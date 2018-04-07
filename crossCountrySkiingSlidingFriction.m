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
%FiLTERING
%signal, depends on specfun (and optim, which was installed for non/linear optimisation)
%pkg install -forge signal specfun

%Run visualiseGPS first to fetch elevations into sampleData/googleElevations. 

fclose all;
close all;
clear all;
clc;
addpath('functions');
addpath('functions/accAna');
addpath('functions/haversine');

epochInfo = readLog('interstingEpoch.txt','\t',2);
epochStamps = cellfun(@str2num, epochInfo.header(2).line(2:3));
eleFileName = epochInfo.header(2).line{1};

dataPath = 'sampleData/googleElevations';
interestingColumns ={{'tstamp','lat','lon','spee','elevations ['},{'tstamp','x [','y [','z ['}};	%Column headers for interesting columns of data

%Read data
eleData = readLog([dataPath '/' eleFileName]);

%Get elevation and speed column indices
eleColumnIndices = cellfun(@(x) getIndice(eleData.header(1).line,x),interestingColumns{1});

%Plot elevations and speed
eleStamps = eleData.data(:,eleColumnIndices(1));
eleIndices = find(eleStamps >= epochStamps(1) & eleStamps <= epochStamps(2));
%eleIndices = [eleIndices(2):eleIndices(2)+18];
%disp(sprintf('%d\t %d',eleStamps(eleIndices(1)),eleStamps(eleIndices(2))))

%Find downhill with no pedaling by exploring the data manually
ah = [];
figure
subplot(2,1,1)
plot((eleStamps(eleIndices)-eleStamps(eleIndices(1)))./(1000),eleData.data(eleIndices,eleColumnIndices(5)),'linewidth',3);
ah(1) = gca();
subplot(2,1,2)
plot((eleStamps(eleIndices)-eleStamps(eleIndices(1)))./(1000),eleData.data(eleIndices,eleColumnIndices(4)),'linewidth',3);
ah(2) = gca();

linkaxes(ah,'x');

%Plot coordinates
figure
plot(eleData.data(eleIndices,eleColumnIndices(2)),eleData.data(eleIndices,eleColumnIndices(3)),'linewidth',3)

%Plot distance
distance = calcDistance(eleData.data(eleIndices,eleColumnIndices(2)),eleData.data(eleIndices,eleColumnIndices(3)));
distanceVel = eleData.data(eleIndices(2:end),eleColumnIndices(4)).*diff((eleStamps(eleIndices)-eleStamps(eleIndices(1)))./(1000));

figure


plot(distance,'linewidth',3);
hold on;
plot(distanceVel,'linewidth',3,'r');

%Calc slope profile based on velocity and elevation change
drop = diff(eleData.data(eleIndices,eleColumnIndices(5)));
distanceVel = eleData.data(eleIndices(1:end-1),eleColumnIndices(4)).*diff(eleStamps(eleIndices-1)./1000);
figure
subplot(2,1,1);
plot(drop,'linewidth',3);
subplot(2,1,2);
plot(distanceVel,'linewidth',3);
slopeAngle = asin(drop./distanceVel);
figure
plot(slopeAngle/pi*180,'linewidth',3);



