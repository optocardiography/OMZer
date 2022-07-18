function [ dataSectionTime, dataSection, locsRep, repMatrix ] = calculateRep( acqFreq, inputData, winStartIndex, winEndIndex, mapCalculationROI, repLevel )

% Description - 20211127
% "acqFreq" - acquistion frequency (Hz)
% "inputData" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputData"
% "mapCalculationROI" - the map area for calculation
% "repLevel" - repolarization level = 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9

%%

inputData = inputData(:, :, winStartIndex:winEndIndex) .* mapCalculationROI;

% (1) Get "dataSectionTime"
[ row, col, frameNumber ] = size(inputData);
dataSectionTime = (0 : frameNumber-1) * (1 / acqFreq); % Unit in 'sec'

% (2) Get normalised "dataSection". Data ranges in [0,1]
pixelMin = min( inputData, [], 3 ); % Min value of each pixel's signal
pixelMax = max( inputData, [], 3 ); % Max value of each pixel's signal
dataSection = rescale( inputData, 'InputMin',pixelMin, 'InputMax',pixelMax );

dataSection = round(dataSection,2);

% (3) Reshape "inputData" to a 2D matrix
dataSection_2D = reshape( dataSection, row*col, [] ); % Each row is a pixel's signal

% (4) Get index of maximum value of each row. Caution: if the n-th row of "dataSection_2D" is NaN, "indexMax(n)" will be 1
[ ~, indexMax ] = max( dataSection_2D, [], 2 ); % "indexMax" is a column vector containing the index of maximum value of each row
indexMax = ~isnan( dataSection_2D(:,1) ) .* indexMax;
indexMax( indexMax==0 ) = NaN; % Now, if the n-th row of "dataSection_2D" is NaN, "indexMax(n)" will be NaN as well

% (5) Find the index of repolarization
locsRep = nan( row*col, 1 ); % Index of repolarisation time for each pixel relative to window start
repMatrix = nan( row*col, 1 ); % Repolarization time map

for pixelID = 1 : row*col
    
    if ~isnan( indexMax(pixelID) )
        
        if min( dataSection_2D(pixelID, indexMax(pixelID):end) ) <= (1-repLevel) % Suppose "(1-repLevel)=0.2", then to check whether the repolarization falls below 0.2
            
            locsRep(pixelID) = find( dataSection_2D(pixelID, indexMax(pixelID):end) <= (1-repLevel), 1,'first' ); % At this moment, "locsRep(pixelID)" is the index relative to indexMax(pixelID)
            locsRep(pixelID) = indexMax(pixelID) + ( locsRep(pixelID) - 1 ); % Now, "locsRep(pixelID)" is the repolarization index relative to window start
            
            repMatrix(pixelID) = (locsRep(pixelID)-1) * (1000/acqFreq); % Unit in 'ms'. This is the time lag of repolarisation level relative to window start
        end
    end
end

locsRep = reshape( locsRep, row,col,1 ); % A row-by-col 2D matrix
repMatrix = reshape( repMatrix, row,col,1 ); % A row-by-col 2D matrix

repMatrix = repMatrix - nanmin( repMatrix(:) );

end