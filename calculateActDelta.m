function [ dataSectionTime, dataSectionCamera1, dataSectionCamera2, locsActCamera1, locsActCamera2, actDeltaMatrix ] = calculateActDelta( acqFreq, inputDataCamera1, inputDataCamera2, winStartIndex, winEndIndex, mapCalculationROI, actDefinition )

% Description - 20211227
% "acqFreq" - acquistion frequency (Hz)
% "inputDataCamera1", "inputDataCamera2" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputDataCamera1" and "inputDataCamera2"
% "mapCalculationROI" - the map area for calculation
% "actDefinition" - "max_dv_dt" or "amplitude_50"
% "actDeltaMatrix" = camera1 - camera2

%%

% (1) Get index of activation for all the cameras. And all the cameras have the same "dataSectionTime"
[ dataSectionTime, dataSectionCamera1, locsActCamera1, ~ ] = calculateAct( acqFreq, inputDataCamera1, winStartIndex, winEndIndex, mapCalculationROI, actDefinition );
[ ~, dataSectionCamera2, locsActCamera2, ~ ] = calculateAct( acqFreq, inputDataCamera2, winStartIndex, winEndIndex, mapCalculationROI, actDefinition );

% (2) Get "actDeltaMatrix"
actDeltaMatrix = ( locsActCamera1 - locsActCamera2 ) * (1000/acqFreq); % Unit in 'ms'. A row-by-col 2D matrix

end