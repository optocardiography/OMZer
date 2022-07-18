function [ dataSectionTime, dataSectionCamera1, dataSectionCamera2, locsRepCamera1, locsRepCamera2, repDeltaMatrix ] = calculateRepDelta( acqFreq, inputDataCamera1, inputDataCamera2, winStartIndex, winEndIndex, mapCalculationROI, repLevel )

% Description - 20211227
% "acqFreq" - acquistion frequency (Hz)
% "inputDataCamera1", "inputDataCamera2" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputDataCamera1" and "inputDataCamera2"
% "mapCalculationROI" - the map area for calculation
% "repLevel" - repolarization level = 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
% "repDeltaMatrix" = camera1 - camera2

%%

% (1) Get index of repolarisation for all the cameras. And all the cameras have the same "dataSectionTime"
[ dataSectionTime, dataSectionCamera1, locsRepCamera1, ~ ] = calculateRep( acqFreq, inputDataCamera1, winStartIndex, winEndIndex, mapCalculationROI, repLevel );
[ ~, dataSectionCamera2, locsRepCamera2, ~ ] = calculateRep( acqFreq, inputDataCamera2, winStartIndex, winEndIndex, mapCalculationROI, repLevel );

% (2) Get "repDeltaMatrix"
repDeltaMatrix = ( locsRepCamera1 - locsRepCamera2 ) * (1000/acqFreq); % Unit in 'ms'. A row-by-col 2D matrix

end