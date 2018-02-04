%An Octave (might work with Matlab as well) script to visualise GPS log data with Google Static Maps
%and to fetch corresponding elevations from Google Elevations API. Google terms of service state
%that the origin of Static Maps figure needs to be explicitly stated, and that elevations have to be
%visualised with a map

fclose all;
close all;
clear all;
clc;

addpath('functions');
addpath('functions/simplify');
javaaddpath('java/src');
interestingColumns = {'lat','lon'};	%Column headers for latitude and longitude, respectively
dataPath = 'sampleData/gpsLog';	%reads logged coordinate data from this path
savePath = 'mapFigs';		%Saves google static map figures here
elevationsPath = 'elevationFigs';	%Saves google static map and elevations visualisation here
elevationsSavePath = 'sampleData/googleElevations';	%Saves the google elevation to a text file here
keyFile = 'mapsKey.txt';	%Google static maps API key in a text file
elevationsKeyFile = 'elevationsKey.txt';	%Google elevations API key in a text file
mapsKey = strtrim(fileread(keyFile));
elevationsKey = strtrim(fileread(elevationsKeyFile));
%Create folder for figures if required
if ~exist(savePath,'dir')
	mkdir(savePath)
end

if ~exist(elevationsPath,'dir')
	mkdir(elevationsPath)
end

if ~exist(elevationsSavePath,'dir')
	mkdir(elevationsSavePath)
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

			%Get elevations
			elevationsArray = javaObject('timo.home.elevations.ElevationRequest',data.data(:,columnIndices(1)),data.data(:,columnIndices(2)),elevationsKey);
			elevations = elevationsArray.getElevations();
			resolution = elevationsArray.getResolution();
			lat = elevationsArray.getLatitudes();
			lon = elevationsArray.getLongitudes();
			
			%Write the elevations to a file
			eleSaveName = [elevationsSavePath '/' strrep(file{1},'GPS_','ELE_')];
			%write header to file
			fid = fopen(eleSaveName,'w'); 
			textHeader = data.header.line;
			textHeader(end+1) = 'Elevations [m]';
			textHeader(end+1) = 'Elevations Resolution';
			
			fprintf(fid,'%s',textHeader{1});
			for t = textHeader(2:end)
				fprintf(fid,'\t%s',t{1});
			end
			fprintf(fid,'\n');
			fclose(fid)
			%write data to end of file
			dlmwrite(eleSaveName,[data.data, elevations, resolution],'\t','-append');
			
			%Simplify coordinates
			[simplified, tIndices] = simplifyJava([data.data(:,columnIndices)], 1e-4);
			%Encode coordinates with polyencode
			encodedString = javaMethod('encode','timo.home.polyencode.PolyEncode',simplified(:,1),simplified(:,2));

			%Send data off to Google static maps api
			urlwrite(['https://maps.googleapis.com/maps/api/staticmap?size=640x640&path=weight:3%7Ccolor:red%7Cenc:' encodedString '&key=' mapsKey],[savePath '/' strrep(file{1},'.txt','.png')]);
			
			%Produce a combined file elevations and map
			[tempData, mapping] = imread([savePath '/' strrep(file{1},'.txt','.png')]);
			imData = ind2rgb(tempData,mapping);
			fh = figure('position',[10 10 1024 1365]);
			subplot(4,1,[1:3]);
			imshow(imData);
			title([strrep(file{1},'.txt','.png') ' from Google Static Maps']);
			subplot(4,1,4);
			plot(elevations,'k','linewidth',2);
			title('Elevations from Google Elevations API');
			ylabel('[m]')
			xlabel('Coordinate index');
			if exist('OCTAVE_VERSION', 'builtin') > 0
				print(fh,[elevationsPath '/' strrep(file{1},'.txt','.png')]);
			else
				print('-dpng','-r200',[elevationsPath '/' strrep(file{1},'.txt','.png')]);			
			end
			close();
			disp(['fetched ' file{1}]);
		else
			disp(['EXISTS ' file{1}]);
		end
	catch
		disp(['FAILED ' file{1}]);
	end
end



