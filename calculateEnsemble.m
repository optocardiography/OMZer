function [ ensembleSignal, ensembleSignalLength, pksIndex, pksNumber ] = calculateEnsemble( inputData, anchorIndex, beatStart_to_anchor_length, beatEnd_to_anchor_length, specialOneBeatWindowStartIndex, specialOneBeatWindowEndIndex, minPeakHeight )

% Description - 20211126
% "inputData" - a 3D matrix

%%

% (1) Preparation
[ row, col, ~ ] = size(inputData);

inputData_2D = reshape( inputData, row*col, [] ); % Each row is a pixel's signal

pksIndex = cell( row*col, 1 ); % Peak index (i.e., location) of each pixel
pksNumber = NaN( row*col, 1 ); % Peak numbers of each pixel
specialOneBeatIndex = NaN( row*col, 1 ); % For each pixle, the location of special one beat in multi beats

ensembleSignalLength = beatStart_to_anchor_length + beatEnd_to_anchor_length + 1;
ensembleSignal_2D = nan( row*col, ensembleSignalLength );
ensembleCalculateYesNo = nan( row*col, 1 ); % 1 (or NaN) means successfully calculated (or no)

if iscolumn( anchorIndex )
    anchorIndex_row = anchorIndex';
else
    anchorIndex_row = anchorIndex;
end

% Ensemble for each pixel
for pixelID = 1 : row*col
    
    if ~isnan( inputData_2D(pixelID,1) )
        
        % (1) Find peaks number and peaks location of each pixel
        countID = 1;
        for anchorLocation = anchorIndex_row
            
            sig_section = inputData_2D( pixelID,  (anchorLocation - beatStart_to_anchor_length) : (anchorLocation + beatEnd_to_anchor_length) );
            
            [ ~, index_max ] = max(sig_section);
            
            pksIndex{pixelID}(countID) = (anchorLocation - beatStart_to_anchor_length) + index_max - 1;
            countID = countID + 1;
        end       
        pksNumber(pixelID) = length( pksIndex{pixelID} );
                
        % (2) Ensemble calculation
        if ~isnan( pksNumber(pixelID) )  &&  ( pksNumber(pixelID) == length(anchorIndex_row) )
            
            % (2.1) For each pixle, find the location of special one beat in multi beats. All other beats will be aligned to this special one beat during ensemble
            specialOneBeatIndex(pixelID) = find( anchorIndex_row >= specialOneBeatWindowStartIndex  &  anchorIndex_row <= specialOneBeatWindowEndIndex, 1,'first' );
            
            if isempty( specialOneBeatIndex(pixelID) )
                specialOneBeatIndex(pixelID) = find( anchorIndex_row <= specialOneBeatWindowStartIndex, 1,'last' );
            end
            
            % (2.2) Check each beat in a pixel before ensemble calculation
            sig_beat = cell( 1, pksNumber(pixelID) ); % The signal for each beat
            beatStart_to_50Upstroke_Length = nan( 1, pksNumber(pixelID) ); % Length between beat start and 50% level of upstroke
            overlaySig = zeros( 1, ensembleSignalLength ); % The overlay of all the beats inside that pixel
            
            % Find 50% level of upstroke of all the beats (All the beats will be aligned to that point during ensemble)
            for beatID = 1 : pksNumber(pixelID)
                
                sig_beat{beatID} = inputData_2D( pixelID, (anchorIndex_row(beatID) - beatStart_to_anchor_length) : (anchorIndex_row(beatID) + beatEnd_to_anchor_length) );
                sig_beat{beatID} = rescale( sig_beat{beatID} ); % Signal ranges in [ 0, 1 ]
                
                [ ~, index_max ] = max( sig_beat{beatID} );
                
                if ~isempty( find( sig_beat{beatID}(1:index_max) <= 0.5, 1,'last' ) )
                    
                    beatStart_to_50Upstroke_Length(beatID) = find( sig_beat{beatID}(1:index_max) <= 0.5, 1,'last' );
                else
                    break
                end
            end
            
            % (2.3) Pad sig_beat{beatID} with 'Periodized extension method' because the position of 50% level of upstroke of each beat is different
            if prod( ~isnan(beatStart_to_50Upstroke_Length) ) == 1 % For each beat, the 50% level of upstroke can be found
                
                specialOneBeat_beatStart_to_50Upstroke_Length = beatStart_to_50Upstroke_Length( specialOneBeatIndex(pixelID) ); % The beatStart_to_50Upstroke_Length of the special one beat
                
                for beatID = 1 : pksNumber(pixelID)
                    
                    distDelta = beatStart_to_50Upstroke_Length(beatID) - specialOneBeat_beatStart_to_50Upstroke_Length;
                    
                    if distDelta > 0
                        sig_beat{beatID}( 1 : distDelta ) = [];
                        sig_beat{beatID} = wextend( '1D', 'ppd', sig_beat{beatID}, distDelta, 'r');
                        
                    elseif distDelta < 0
                        sig_beat{beatID} = wextend( '1D', 'ppd', sig_beat{beatID}, abs(distDelta), 'l');
                        sig_beat{beatID}( end-abs(distDelta)+1 : end ) = [];
                    end
                    
                    overlaySig = overlaySig + sig_beat{beatID};
                end
                
                overlaySig = overlaySig / pksNumber(pixelID);
                overlaySig = rescale( overlaySig ); % Signal ranges in [ 0, 1 ]
                overlaySig = round(overlaySig,2);
                
                ensembleSignal_2D( pixelID, : ) = overlaySig;
                
                ensembleCalculateYesNo(pixelID) = 1;
            end     
        end
         
    end
end



if prod( isnan(ensembleCalculateYesNo) ) == 1
    
    ensembleSignal = NaN;
    ensembleSignalLength = NaN;
    pksIndex = NaN;
    pksNumber = NaN;
    
    msg = 'No ensemble signals can be calculated';
    warning(msg)
    fprintf('\n')
    
else
    
    ensembleSignal = reshape( ensembleSignal_2D, row,col,[] ); % 3D matrix
    
    pksIndex = reshape( pksIndex, row ,col ); % 2D matrix
    pksNumber = reshape( pksNumber, row, col ); % 2D matrix
    
    pksIndex( isnan( ensembleSignal(:,:,1) ) ) = {NaN}; % 2D matrix (row-by-col)
    pksNumber( isnan( ensembleSignal(:,:,1) ) ) = NaN; % 2D matrix (row-by-col)
end


%% Calculate ensemble signals
% Apply beatStart_to_anchor_length and beatEnd_to_anchor_length to all anchorIndex
% Find act for all the anchor beats
% Get beatStart_to_act_length and beatEnd_to_act_length for all anchor beats
% Get beatStart_to_act_length and beatEnd_to_act_length for the initial special one beat. For multi beats, use the longest beat
% Adjust beatStart_to_act_length and beatEnd_to_act_length of all anchor beats to that of the initial special one beat
% Calculate average of all anchor beats (i.e., generate ensemble signals)
% Normalise the ensemble signals

end