function [f0s, mads] = getMADandF0(data,constants)
	 f0s = zeros(length(constants.msStamps),1);
    mads = zeros(length(constants.msStamps),1);
    accStamps = data(:,1)-constants.initMs;
    if constants.debugFigs
		 fh = figure;
		 subplot(2,1,1)
		 axis();
		 ah(1) =gca();
		 subplot(2,1,2);
		  axis();
		  ah(2) =gca();
     end
    for s = 1:length(constants.msStamps)
    	currentIndices = find(accStamps >=constants.msStamps(s) & accStamps < constants.msStamps(s)+constants.epochLengths(1)*1000);%+(constants.epochLengths(1)-1)*1000);
    	currentSeconds = accStamps(currentIndices)/1000;   	
    	resultant = sqrt(sum((data(currentIndices,2:4)./9.81).^2,2)); %scale to gs
    	meanSubtracted = resultant-mean(resultant);
    	mads(s) = mean(abs(meanSubtracted));	%Get MAD
    	if constants.debugFigs
		 	set(fh,'currentaxes',ah(1));
		 	plot(currentSeconds,meanSubtracted,'linewidth',3);
		 	set(gca,'ylim',[-3 3]);
		 	title(sprintf("MaD %.2f",mads(s)));
    	end
    	
    	%Get f0
    	hannWindowed = meanSubtracted.*hanning(length(meanSubtracted));%Use hann window
		if 0
			ah = [];
			figure('position',[40 40 950 550]);
			subplot(2,1,1)
			%plot(resultant,'linewidth',3);
			plot(meanSubtracted,'linewidth',3);
			title('getMADandF0 orig');
			ah(1) = gca();
			subplot(2,1,2)
			plot(hannWindowed,'linewidth',3);
			ah(2) = gca();
			linkaxes(ah,'x');		
				 	
		 	keyboard;
    	end
    	currentSeconds = currentSeconds-currentSeconds(1);	%start from zero for the LSS
    	staticCoeffs = javaMethod('lsqspectrum', 'timo.home.leastsqspectrum.LeastSqSpectrum', currentSeconds,hannWindowed,constants.lssFreq{1},5);
    	
		jdcOffset = staticCoeffs(1);
		jsinCoeffs = staticCoeffs(2:2:end);
		jcosCoeffs = staticCoeffs(3:2:end);
		jlsspower = sqrt(sum([jsinCoeffs, jcosCoeffs].^2,2));
	
		if 1
			figure('position',[40 40 950 550]);
			plot(constants.lssFreq{1},[0; jlsspower],'linewidth',3);
			title(sprintf('lsqspectrum getMad length, %d',length(jlsspower)));
			%keyboard;
		end		
				
		f0s(s) = estimateBareF0Java([],[],constants.stepLims,constants.lssFreq{1},[0; jlsspower]);
		if constants.debugFigs
			set(fh,'currentaxes',ah(2));
		 	plot(lssFreq{1},[0;jlsspower],'linewidth',3);
		 	title(f0s(s));
		 	set(gca,'xlim',[0 5]);
		 	drawnow();
    	end
    	%pause(0.5);
    end
    
