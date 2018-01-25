fclose all;
close all;
clear all;
clc;

addpath('functions');
addpath('functions/simplify');
javaaddpath('java/src');
interestingColumns = {'lat','lon'};	%Column headers for latitude and longitude, respectively
dataPath = 'sampleData/gpsLog';
savePath = 'mapFigs';
keyFile = 'mapsKey.txt';
mapsKey = fileread(keyFile);
%Create folder for figures if required
if ~exist(savePath,'dir')
	mkdir(savePath)
end

fList = dir([dataPath '/*.txt']);

for file = {fList(:).name}
	try
		%Fetch only the ones that have not yet been fetched
		if ~exist([savePath '/' strrep(file{1},'.txt','.png')],'file')
			%Read data	
			data = readLog([dataPath '/' file{1}]);
			%Get latitude and longitude column indices
			columnIndices = cellfun(@(x) getIndice(data.header(1).line,x),interestingColumns);

			%Simplify coordinates
			[simplified, tIndices] = simplifyJava([data.data(:,columnIndices)], 1e-4);
			%Encode coordinates with polyencode
			encodedString = javaMethod('encode','timo.home.polyencode.PolyEncode',simplified(:,1),simplified(:,2));

			%Send data off to Google static maps api
			urlwrite(['https://maps.googleapis.com/maps/api/staticmap?size=640x640&path=weight:3%7Ccolor:red%7Cenc:' encodedString '&key=' mapsKey],[savePath '/' strrep(file{1},'.txt','.png')]);
			disp(['fetched ' file{1}]);
		else
			disp(['EXISTS ' file{1}]);
		end
	catch
		disp(['FAILED ' file{1}]);
	end
end



