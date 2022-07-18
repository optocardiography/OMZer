function [ dataSectionTime, dataSection, locsAct, actMatrix ] = calculateAct( acqFreq, inputData, winStartIndex, winEndIndex, mapCalculationROI, actDefinition )

% Description - 20211126
%
% "acqFreq" - acquistion frequency (Hz)
% "inputData" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputData"
% "mapCalculationROI" - the map area for calculation
% "actDefinition" - "max_dv_dt" or "amplitude_50"

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

% (5) Find the index of activation
index_90 = nan( row*col, 1 ); % 90% level of upstroke
index_50 = nan( row*col, 1 ); % 50% level of upstore
index_median_start_to_50 = nan( row*col, 1 ); % The median of values from start of the window to 50% level of upstroke

locsAct = nan( row*col, 1 ); % Index of activation time for each pixel relative to window start
actMatrix = nan( row*col, 1 ); % Activation time map

for pixelID = 1 : row*col
    
    if ~isnan( indexMax(pixelID) )
        
        if ( min( dataSection_2D(pixelID, 1:indexMax(pixelID)) ) <= 0.50 )  &&  ( max( dataSection_2D(pixelID, 1:indexMax(pixelID)) ) >= 0.90 )
            
            index_90(pixelID) = find( dataSection_2D(pixelID, 1:indexMax(pixelID)) <= 0.90,  1,'last' );
            index_50(pixelID) = find( dataSection_2D(pixelID, 1:indexMax(pixelID)) <= 0.50,  1,'last' );
            
            median_start_to_50 = median( dataSection_2D(pixelID, 1:index_50(pixelID)) );
            index_median_start_to_50(pixelID) = find( dataSection_2D(pixelID, 1:index_50(pixelID)) <= median_start_to_50,  1,'last' );
            
            if ( ~isempty(index_median_start_to_50(pixelID)) )  &&  ( index_median_start_to_50(pixelID) < index_90(pixelID) )
                
                if isequal( actDefinition, 'max_dv_dt' ) % (5.1) Activation time definition - the index of maximal slope of the optical upstroke
                    
                    diffResult = diff( dataSection_2D( pixelID, index_median_start_to_50(pixelID):index_90(pixelID) ) );
                    locsAct(pixelID) = index_median_start_to_50(pixelID) + find(diffResult == max(diffResult), 1,'first') - 1;
                    
                elseif isequal( actDefinition, 'amplitude_50' ) % (5.2) Activation time definition - at 50% amplitude of the optical upstroke
                    
                    locsAct(pixelID) = index_50(pixelID);
                end
                
                actMatrix(pixelID) = (locsAct(pixelID)-1) * (1000/acqFreq); % Unit in 'ms'
            end
            
        end
    end
end

locsAct = reshape( locsAct, row, col, [] ); % A row-by-col 2D matrix
actMatrix = reshape( actMatrix, row, col, [] ); % A row-by-col 2D matrix

actMatrix = actMatrix - nanmin( actMatrix(:) );

end