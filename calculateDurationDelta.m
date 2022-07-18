function [ dataSectionTime, dataSectionCamera1, dataSectionCamera2, locsActCamera1, locsActCamera2, locsRepCamera1, locsRepCamera2, durationMatrixCamera1, durationMatrixCamera2, durationDeltaMatrix ] = calculateDurationDelta( acqFreq, inputDataCamera1, inputDataCamera2, winStartIndex, winEndIndex, mapCalculationROI, repLevel, actDefinition )

% Description - 20211227
% "acqFreq" - acquistion frequency (Hz)
% "inputDataCamera1", "inputDataCamera2" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputDataCamera1" and "inputDataCamera2"
% "mapCalculationROI" - the map area for calculation
% "repLevel" - repolarization level = 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
% "actDefinition" - "max_dv_dt" or "amplitude_50"
% "durationDeltaMatrix" = camera1 - camera2

%%

% (1) Get index of activation and repolarisation for all the cameras. And all the cameras have the same "dataSectionTime"
[ dataSectionTime, dataSectionCamera1, locsActCamera1, locsRepCamera1, durationMatrixCamera1 ] = calculateDuration( acqFreq, inputDataCamera1, winStartIndex, winEndIndex, mapCalculationROI, repLevel, actDefinition );
[ ~, dataSectionCamera2, locsActCamera2, locsRepCamera2, durationMatrixCamera2 ] = calculateDuration( acqFreq, inputDataCamera2, winStartIndex, winEndIndex, mapCalculationROI, repLevel, actDefinition );

% (2) Get "durationDeltaMatrix"
durationDeltaMatrix = durationMatrixCamera1 - durationMatrixCamera2; % Unit in 'ms'. A row-by-col 2D matrix

end