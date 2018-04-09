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
pkg load signal

addpath('functions');
addpath('functions/accAna');
addpath('functions/haversine');
addpath('functions/ode');

epochInfo = readLog('interstingEpoch.txt','\t',3);	%Read all lines as header lines
lineOfInterest = 3;	%Which line in the interestingEpoch file to model
epochStamps = cellfun(@str2num, epochInfo.header(lineOfInterest).line(2:3));
eleFileName = epochInfo.header(lineOfInterest).line{1};

%dataPath = 'sampleData/googleElevations';
dataPath = 'sampleData/googleElevationsNew';
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

%Filter distance
[b,a] = butter(2,0.2/0.5);
distanceSmooth = filtfilt(b,a,distance);



distanceVel = eleData.data(eleIndices(2:end),eleColumnIndices(4)).*diff((eleStamps(eleIndices)-eleStamps(eleIndices(1)))./(1000));

dposition =cumtrapz(distance);
dsposition = cumtrapz(distanceSmooth);
velposition =cumtrapz(distanceVel);


figure
plot(dposition,'linewidth',3);
hold on;
plot(velposition,'linewidth',3,'r');
plot(dposition,'linewidth',3,'g');
title('Position')
figure
plot(distance,'linewidth',3);
hold on;
plot(distanceVel,'linewidth',3,'r');
plot(distanceSmooth,'linewidth',3,'g');
title('diffPosition')
%keyboard;

heightSmooth = filtfilt(b,a,eleData.data(eleIndices,eleColumnIndices(5)));

figure
plot(eleData.data(eleIndices,eleColumnIndices(5)),'linewidth',3);
hold on;
plot(heightSmooth,'linewidth',3,'g');
title('heightData');

figure
plot(diff(eleData.data(eleIndices,eleColumnIndices(5))),'linewidth',3);
hold on;
plot(diff(heightSmooth),'linewidth',3,'g');
title('diffHeightData');

%Calc slope profile based on velocity and elevation change
drop = diff(eleData.data(eleIndices,eleColumnIndices(5)));
dropSmooth = diff(heightSmooth);
distanceVel = eleData.data(eleIndices(1:end-1),eleColumnIndices(4)).*diff(eleStamps(eleIndices-1)./1000);
figure
subplot(2,1,1);
plot(drop,'linewidth',3);
hold on
plot(dropSmooth,'linewidth',3,'g');
title('Drop');
subplot(2,1,2);
plot(distanceVel,'linewidth',3);
hold on
plot(distance,'linewidth',3);
plot(distanceSmooth,'linewidth',3,'g');
slopeAngle = asin(drop./distanceVel);
slopeAngle2 = asin(drop./distance);
slopeAngleSmooth = asin(dropSmooth./distanceSmooth);

figure
plot(slopeAngle/pi*180,'linewidth',3);
hold on;
plot(slopeAngle2/pi*180,'linewidth',3);
plot(slopeAngleSmooth/pi*180,'linewidth',3,'g');
title('slopeAngle');


%[b,a] = butter(2,0.2/0.5);
%slopeAngleSmooth = filtfilt(b,a,slopeAngle2);
%plot(slopeAngleSmooth/pi*180,'linewidth',3,'g');
%keyboard;

%Use distance-based slope, which is slopeAngle2
%Model velocity against measured velocity
global constants
constants =struct();
constants.position = dsposition;	%Used to get slope in ODE integral
constants.slope = slopeAngleSmooth;	%Used to get slope in ODE integral
constants.m = 93; %kg mass of the object
constants.A = 1.3*0.5;	%Cross-sectional area of the object m squared (crouched person)
constants.rho = 1.177;	%kg/m3 Air density 
constants.g = -9.81;	%m/s2 gravitational acceleration
constants.u = 0.02;
constants.Cd = 1.0;	%Guess base on cyclists https://www.cyclingpowerlab.com/CyclingAerodynamics.aspx
constants.time = (eleStamps(eleIndices)-eleStamps(eleIndices(1)))./(1000);

%initVel = eleData.data(eleIndices(1),eleColumnIndices(4));
initVel = distanceSmooth(1);
evalInstants = [0:0.1:30];
[evalInstants, modelPosition]= ode45(@(t,y) positionDiffWithAir(t,y,constants),evalInstants,[initVel; 0;]);

%opt = odeset ("InitialStep", 0.001, "MaxStep", 0.1);
%[evalInstants, modelPosition]= ode45(@(t,y) positionDiffWithAir(t,y,constants),evalInstants,[initVel; 0;],opt);

%lsode_options('integration method','stiff');
%[modelPosition]= lsode(@(y,t) lsOdeTest(y,t),[initVel; 0;],evalInstants);

figure
subplot(2,1,1)
plot(evalInstants,interp1([1:length(distanceVel)]-1,distanceSmooth,evalInstants),'k','linewidth',3)
hold on;
plot(evalInstants,modelPosition(:,1),'linewidth',3)
subplot(2,1,2)
plot(evalInstants,interp1([1:length(velposition)]-1,dsposition,evalInstants),'k','linewidth',3)
hold on;
plot(evalInstants,modelPosition(:,2),'linewidth',3)

