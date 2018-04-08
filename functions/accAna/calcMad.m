function mad = calcMad(tStamps,data,epoch)
		currentIndices = find(tStamps >=epoch(1) & tStamps < epoch(2));	%Get indices of the current epoch
    	epochData = data(currentIndices); %get the epoch
    	mad = mean(abs(epochData-mean(epochData)));	%Calc MAD
