%An Octave (might work with Matlab as well) script to visualise GPS log data with Google Static Maps
%and to fetch corresponding elevations from Google Elevations API. Google terms of service state
%that the origin of Static Maps figure needs to be explicitly stated, and that elevations have to be
%visualised with a map

fclose all;
close all;
clear all;
clc;

%if exist('OCTAVE_VERSION', 'builtin') > 0
%	graphics_toolkit('gnuplot');	%Try to use the gnuplot graphics toolkit. FLTK seg-faulted
%end

if exist('OCTAVE_VERSION', 'builtin') > 0
	pkg load image
end
addpath('functions');
addpath('functions/simplify');
javaaddpath('build/libs/runAnalyserHelper-1.0.jar');	%Java helper to interface with Google maps and elevations APIs. Saves png images as well to comply with Google Elevations API terms of service
interestingColumns = {'lat','lon'};	%Column headers for latitude and longitude, respectively
dataPath = 'sampleData/lainakannylta/gpsLog';	%reads logged coordinate data from this path
elevationsPath = 'elevationFigsNew';	%Saves google static map and elevations visualisation here
elevationsSavePath = 'sampleData/googleElevationsNew';	%Saves the google elevation to a text file here
keyFile = 'mapsKey.txt';	%Google static maps API key in a text file
elevationsKeyFile = 'elevationsKey.txt';	%Google elevations API key in a text file
mapsKey = strtrim(fileread(keyFile));
elevationsKey = strtrim(fileread(elevationsKeyFile));
elevationRequest = javaObject('timo.home.elevations.ElevationRequest',elevationsKey);

%Create hex colours for static maps here
colourInts = javaMethod('getColourSlide','timo.home.utils.Utils',int32(0x000000FF),int32(0x00FF0000),10);
colours = cellfun(@(x) ['0x' sprintf('%06x',x)], num2cell(colourInts),'uniformoutput',false);

%Create folder for text files and figures if required
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
		if ~exist([elevationsPath '/' strrep(file{1},'.txt','.png')],'file')
			%Read data	
			data = readLog([dataPath '/' file{1}]);
			%Get latitude and longitude column indices
			columnIndices = cellfun(@(x) getIndice(data.header(1).line,x),interestingColumns);
			
			%Simplify coordinates
			[simplified, tIndices] = simplifyJava([data.data(:,columnIndices)], 1e-4);
			
			%Encode coordinates with polyencode
			if size(simplified,1) > 20
				encodedString = {};
				inits = round([0:length(colours)]./length(colours).*size(simplified,1));
				for cc = 1:length(colours)
					currentEpoch = max([1 inits(cc)]):inits(cc+1);
					encodedString = [encodedString; {javaMethod('encode','timo.home.polyencode.PolyEncode',simplified(currentEpoch,1),simplified(currentEpoch,2))}];
				end
			else
				encodedString = {javaMethod('encode','timo.home.polyencode.PolyEncode',simplified(:,1),simplified(:,2))};
			end
			%Send data off to Google static maps api, and get the static map as java BufferedImage
			%urlwrite(['https://maps.googleapis.com/maps/api/staticmap?size=640x640&path=weight:3%7Ccolor:red%7Cenc:' encodedString '&key=' mapsKey],[savePath '/' strrep(file{1},'.txt','.png')]);
			pathString = 'https://maps.googleapis.com/maps/api/staticmap?size=640x640';
			
			for e = 1:length(encodedString)
				pathString = [pathString '&path=weight:3%7Ccolor:' colours{e} '%7Cenc:' encodedString{e}];
			end
			mapString = urlread([pathString '&key=' mapsKey]);
			%Get the map as bufferedImage
			iStream = javaObject('java.io.ByteArrayInputStream',typecast(mapString,'int8'));
			mapBI = javaMethod('read','javax.imageio.ImageIO',iStream);
			
			%Get elevations
			elevationRequest.encode(data.data(:,columnIndices(1)),data.data(:,columnIndices(2)));
			elevations = elevationRequest.getElevations();
			resolution = elevationRequest.getResolution();
			%lat = elevationRequest.getLatitudes();
			%lon = elevationRequest.getLongitudes();

			%Save a combined static map and elevations png
			xChart = javaObject('timo.jyu.PlotXChart','Elevations from Google Elevations API','GPS Data Point Index','Elevation [m]',640,320);
			
			%add elevations using colour slide
			if size(simplified,1) > 20
				encodedString = {};
				inits = round([0:length(colours)]./length(colours).*length(elevations));
				for cc = 1:length(colours)
					currentEpoch = max([1 inits(cc)]):inits(cc+1);
					xChart.addSeries(sprintf('Elevation%02d',cc),currentEpoch,elevations(currentEpoch),colourInts(cc));					
				end
			else
				xChart.addSeries('Elevation',1:length(elevations),elevations);
			end
			
			
			
			xChart.appendAndSavePNG([elevationsPath '/' strrep(file{1},'.txt','.png')],mapBI,true);
			
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
			fclose(fid);
			%write data to end of file
			dlmwrite(eleSaveName,[data.data, elevations, resolution],'\t','-append');
			
			disp(['fetched ' file{1}]);
		else
			disp(['EXISTS ' file{1}]);
		end
	catch
		disp(['FAILED ' file{1}]);
	end
end



