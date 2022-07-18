function [ dataSectionTime, dataSection, locsStart, locsEnd, tauMatrix, decayFitData ] = calculateDTau( acqFreq, inputData, winStartIndex, winEndIndex, mapCalculationROI, startLevel, endLevel )

% Description - 20211128
% "acqFreq" - acquistion frequency (Hz)
% "inputData" - a 3D matrix
% "windStartIndex" and "winEndIndex" - define a single beat from "inputData"
% "mapCalculationROI" - the map area for calculation
% "startLevel" - start level for decay time = 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2
% "endLevel" - end level for decay time = 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1

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
dataSection_2D = reshape(dataSection, row*col, []); % Each row is a pixel's signal

% (4) Get index of maximum value of each row. Caution: if the n-th row of "dataSection_2D" is NaN, "indexMax(n)" will be 1
[ ~, indexMax ] = max( dataSection_2D, [], 2 ); % "indexMax" is a column vector containing the index of maximum value of each row
indexMax = ~isnan( dataSection_2D(:,1) ) .* indexMax;
indexMax( indexMax==0 ) = NaN; % Now, if the n-th row of "dataSection_2D" is NaN, "indexMax(n)" will be NaN as well

% (5) Preparation
locsStart = nan( row*col , 1 ); % Index of start level for each pixel relative to window start
locsEnd = nan( row*col , 1 ); % Index of end level for each pixel relative to window start
tauMatrix = nan( row*col, 1 ); % Decay time map
decayFitData = nan( row*col, frameNumber ); % The fitted data for decay

% (6) Find location of start and end. Calculate duration
for pixelID = 1 : row*col
    
    if ~isnan( indexMax(pixelID) )
        
        if ( max( dataSection_2D(pixelID, indexMax(pixelID):end) ) >= startLevel )  &&  ( min( dataSection_2D(pixelID, indexMax(pixelID):end) ) <= endLevel )
            
            startPoint = find( dataSection_2D(pixelID, indexMax(pixelID):end) <= startLevel,  1,'first' ); % The start level. For example, "startLevel" is 0.8 for 80%.
            endPoint = find( dataSection_2D(pixelID, indexMax(pixelID):end) <= endLevel,  1,'first' ); % The end level. For example, "endLevel" is 0.2 for 20%.
            
            if startPoint < endPoint % Start index shoud be earlier than end index
                
                locsStart(pixelID) = indexMax(pixelID) + ( startPoint - 1 );
                locsEnd(pixelID) = indexMax(pixelID) + ( endPoint - 1 );
                
                % (6.1 - A) Calculate 'tau' in exponential equation: Y = A * exp(-t/tau). Note: in MATLAB, Y = exp(X) returns the exponential e^x for each element in array X.
                % (6.1 - B) "Y" is the observed signal, "t" is the time. "A" and "tau" need to be calculated
                % (6.1 - C) The natural logarithm of the 'exponential equation' is a linear equation: lnY = (-1/tau)*t + lnA
                sig_observed = dataSection_2D( pixelID, locsStart(pixelID):locsEnd(pixelID) ); % "sig_observed" (a row vector) - the observed signal to be fitted by the exponential equation
                ln_sig_observed = log( sig_observed ); % "ln_sig_observed" (a row vector) - the natural logarithm of "sig_observed"
                t_observed = dataSectionTime( locsStart(pixelID):locsEnd(pixelID) ); % "t_observed" (a row vector) unit in 'sec' - time for the observed signal
                
                % (6.2) Linear fitting ( lnY = (-1/tau)*t + lnA )
                fitCoefficients = polyfit( t_observed, ln_sig_observed, 1); % 'fitCoefficients(1) = (-1/tau)', 'fitCoefficients(2) = lnA'
                
                tau = ( -1 / fitCoefficients(1) ); % Unit in 'sec'
                
                % maxThreshold = ( dataSectionTime(end) - dataSectionTime(indexMax(i)) ); % Unit in 'sec'
                if ( tau > 0 )  % &&  ( tau <= maxThreshold )
                    
                    tauMatrix(pixelID) = tau; % Unit in 'sec'
                    tauMatrix(pixelID) = tauMatrix(pixelID) * 1000; % Unit in 'ms'
                    
                    tauMatrix(pixelID) = round( tauMatrix(pixelID), 2 );
                    
                    lnY = polyval( fitCoefficients, t_observed ); % 'lnY' is a row vector
                    decayFitData( pixelID, locsStart(pixelID):locsEnd(pixelID) ) = round( exp(lnY), 2 );
                    
                else
                    
                    tauMatrix(pixelID) = NaN;
                    locsStart(pixelID) = NaN;
                    locsEnd(pixelID) = NaN;
                end
            end
        end
    end
end

locsStart = reshape( locsStart, row, col, 1 ); % A row-by-col 2D matrix
locsEnd = reshape( locsEnd, row, col, 1 ); % A row-by-col 2D matrix
tauMatrix = reshape( tauMatrix, row, col, 1 ); % A row-by-col 2D matrix
decayFitData = reshape( decayFitData, row, col, frameNumber );  % A row*col*frameNumber 3D matrix

end