function [ dataSectionTime, dataSection, locsStart, locsEnd, durationMatrix ] = calculateRT( acqFreq, inputData, winStartIndex, winEndIndex, mapCalculationROI, startLevel, endLevel )

% Description - 20211128
% "acqFreq" - acquistion frequency (Hz)
% "inputData" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputData"
% "mapCalculationROI" - the map area for calculation
% "startLevel" - start level for rise time = 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
% "endLevel" - end level for rise time = 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0

%%

inputData = inputData(:, :, winStartIndex:winEndIndex) .* mapCalculationROI;

risePartSmoothYesNo = 0; % 1 (or 0) - no peaks inside (or there can be peaks) the rise part

% (1) Get "dataSectionTime"
[ row, col, frameNumber ] = size(inputData);
dataSectionTime = (0 : frameNumber-1) * (1 / acqFreq); % Unit in 'sec'

% (2) Get normalised "dataSection". Data ranges in [0,1]
pixelMin = min( inputData, [], 3 ); % Min value of each pixel's signal
pixelMax = max( inputData, [], 3 ); % Max value of each pixel's signal
dataSection = rescale( inputData, 'InputMin',pixelMin, 'InputMax',pixelMax );

dataSection = round(dataSection,2);

% (3) Reshape "inputData" to a 2D matrix
dataSection_2D = reshape(dataSection, row*col, []); % Each row is a pixel's signal

% (4) Get index of maximum value of each row. Caution: if the n-th row of "dataSection_2D" is NaN, "indexMax(n)" will be 1
[ ~, indexMax ] = max( dataSection_2D, [], 2 ); % "indexMax" is a column vector containing the index of maximum value of each row
indexMax = ~isnan( dataSection_2D(:,1) ) .* indexMax;
indexMax( indexMax==0 ) = NaN; % Now, if the n-th row of "dataSection_2D" is NaN, "indexMax(n)" will be NaN as well

% (5) Preparation
locsStart = nan( row*col , 1 ); % Index of start level for each pixel relative to window start
locsEnd = nan( row*col , 1 ); % Index of end level for each pixel relative to window start
durationMatrix = nan( row*col, 1 ); % Rise time map

% (6) Find location of start and end. Calculate duration
for pixelID = 1 : row*col
    
    if ~isnan( indexMax(pixelID) )
        
        if ( min( dataSection_2D(pixelID, 1:indexMax(pixelID)) ) <= startLevel )  &&  ( max( dataSection_2D(pixelID, 1:indexMax(pixelID)) ) >= endLevel )
            
            startPoint = find( dataSection_2D(pixelID, 1:indexMax(pixelID)) <= startLevel,  1,'last' );
            endPoint = find( dataSection_2D(pixelID, 1:indexMax(pixelID)) <= endLevel,  1,'last' );
            
            if startPoint < endPoint % Start index shoud be earlier than end index
                
                if risePartSmoothYesNo == 1
                    
                    pks = findpeaks( dataSection_2D(pixelID, startPoint:endPoint) );
                    if isempty(pks)
                        
                        locsStart(pixelID) = startPoint;
                        locsEnd(pixelID) = endPoint;
                        
                        durationMatrix(pixelID) = (locsEnd(pixelID)-locsStart(pixelID)) * (1000/acqFreq); % Unit in 'ms'                     
                    end
                    
                else
                    
                    locsStart(pixelID) = startPoint;
                    locsEnd(pixelID) = endPoint;
                    
                    durationMatrix(pixelID) = (locsEnd(pixelID)-locsStart(pixelID)) * (1000/acqFreq); % Unit in 'ms'
                end
            end
        end
    end
end

locsStart = reshape( locsStart, row, col, 1 ); % A row-by-col 2D matrix
locsEnd = reshape( locsEnd, row, col, 1 ); % A row-by-col 2D matrix
durationMatrix = reshape( durationMatrix, row, col, 1 ); % A row-by-col 2D matrix

end