function [ anchorIndex, beatStart_to_anchor_length, beatEnd_to_anchor_length, specialOneBeatWindowStartIndex, specialOneBeatWindowEndIndex, varargout ] = calculateAnchorIndex( methodName, varargin )

% Description - 20211126
% anchorIndex - the index for locating all the beats (required for ensemble calculation) in one pixel
% For "varargin", see (https://www.mathworks.com/help/matlab/ref/varargin.html)
% For "varargout", see (https://www.mathworks.com/help/matlab/ref/varargout.html)
% "beatStart_to_anchor_length" - the distance between start of initial special one beat and its anchor
% "beatEnd_to_anchor_length" - the distance between end of initial special one beat and its anchor
% specialOneBeatWindowStartIndex - All other beats will be aligned to this beat by its activation point
% specialOneBeatWindowEndIndex - All other beats will be aligned to this beat by its activation point

%%

% Get anchorIndex
% Get initial special one beat. For multi beats, use the longest beat
% Get beatStart_to_anchor_length and beatEnd_to_anchor_length

showFigure = 0;

anchorIndex = NaN;

specialOneBeatWindowStartIndex = NaN;
specialOneBeatWindowEndIndex = NaN;

if isequal( methodName, 'One Beat & Pacing 1' )  ||  isequal( methodName, 'One Beat & Pacing 2' )
    
    % (1) Get all the input
    pacingSig = varargin{1}; % "pacingSig" includes 0 or 1
    signalTime = varargin{2};
    winStartIndex = varargin{3};
    winEndIndex = varargin{4};
    
    % (2) Get pacing index
    index_pacingSig = find( pacingSig == 1 );
    
    % (3) Generate "beatStart_to_anchor_length" and "beatEnd_to_anchor_length"
    index_pacingSig_insideWin = find(  (index_pacingSig >= winStartIndex)  &  (index_pacingSig <= winEndIndex), 1, 'first'  );
    
    if ~isempty( index_pacingSig_insideWin )
        
        beatStart_to_anchor_length = index_pacingSig(index_pacingSig_insideWin) - winStartIndex;
        beatEnd_to_anchor_length = winEndIndex - index_pacingSig(index_pacingSig_insideWin);
        
    else
        
        specialIndex = find( index_pacingSig <= winStartIndex, 1, 'last' );
        
        beatStart_to_anchor_length = 0;
        beatEnd_to_anchor_length = winEndIndex - index_pacingSig(specialIndex);
    end
    
    % (4) Under the current "beatStart_to_anchor_length" and "beatEnd_to_anchor_length", check if the 1st and/or last anchor beat will exceed signal length
    if index_pacingSig(end) + beatEnd_to_anchor_length > length(signalTime)
        index_pacingSig(end) = [];
    end
    
    if ~isempty( index_pacingSig )
        
        if index_pacingSig(1) - beatStart_to_anchor_length < 1
            index_pacingSig(1) = [];
        end
        
        if ~isempty( index_pacingSig )
            anchorIndex = index_pacingSig;
            if isrow(anchorIndex)
                anchorIndex = anchorIndex';
            end
        end
    end
    
    specialOneBeatWindowStartIndex = winStartIndex;
    specialOneBeatWindowEndIndex = winEndIndex;
    
    % (5) Warning
    if isnan( anchorIndex )
        
        msg = 'No anchor index can be found';
        warning(msg)
        fprintf('\n')
    end
    
    % (6) Plot for debugging purpose
    if ( showFigure == 1 )  &&  ( prod(~isnan( anchorIndex )) == 1 )
        
        figure
        title( gca, { 'Pacing Signals & Anchor For Ensemble'; ''} )
        hold( gca, 'on' )
        stem( gca, signalTime, pacingSig, 'Color','Black', 'LineWidth',2 )
        plot( gca, signalTime(anchorIndex), pacingSig(anchorIndex), 'Color','Red', 'LineStyle','none', 'LineWidth',2, 'Marker','^', 'MarkerSize',10)
        
        xLeft = signalTime(winStartIndex);
        xRight = signalTime(winEndIndex);
        yBottom = min(pacingSig);
        yTop = max(pacingSig);
        typeWindowSelectionPatchColor = [0.89, 0.47, 0.58]; % Pink
        patch( gca, [xLeft, xRight, xRight, xLeft], [yBottom, yBottom, yTop, yTop], typeWindowSelectionPatchColor, 'FaceAlpha',0.3, 'EdgeColor','none')
        
        hold( gca, 'off' )
        xlim( gca, [0, signalTime(end)] )
        legend( 'Pacing Signals', 'Anchor For Ensemble', 'User Selected Beat', 'Location','northeastoutside' )
    end
    
    
    
elseif isequal( methodName, 'One Beat & Peak Detection' )
    
    % (1) Get all the input
    minPeakHeight = varargin{1}; % For peak detection
    inputData = varargin{2}; % 3D matrix
    row = varargin{3};
    col = varargin{4};
    signalTime = varargin{5};
    winStartIndex = varargin{6};
    winEndIndex = varargin{7};
    
    % (2) Preparation before peak detection
    sig = squeeze( inputData(row,col,:) ); % For peak detection
    sig_beat = sig( winStartIndex : winEndIndex );
    
    beatStart_to_anchor_length = find( sig_beat == max(sig_beat), 1,'first' ) - 1;
    beatEnd_to_anchor_length = length(sig_beat) - find( sig_beat == max(sig_beat), 1,'first' );
    
    minPeakDistance = max( beatStart_to_anchor_length, beatEnd_to_anchor_length ); % For peak detection
    
    % (3) Peak detection
    [ ~, peakIndex] = findpeaks( sig, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance',minPeakDistance );
    
    if ~isempty( peakIndex )
        
        % (4) Under the current "beatStart_to_anchor_length" and "beatEnd_to_anchor_length", check if the 1st and/or last anchor beat will exceed signal length
        if peakIndex(end) + beatEnd_to_anchor_length > length(signalTime)
            peakIndex(end) = [];
        end
        
        if ~isempty( peakIndex )
            
            if peakIndex(1) - beatStart_to_anchor_length < 1
                peakIndex(1) = [];
            end
            
            if ~isempty( peakIndex )
                anchorIndex = peakIndex;
                if isrow(anchorIndex)
                    anchorIndex = anchorIndex';
                end
            end
        end
    end
    
    specialOneBeatWindowStartIndex = winStartIndex;
    specialOneBeatWindowEndIndex = winEndIndex;
    
    % (5) Warning
    if isnan( anchorIndex )
        
        msg = 'No anchor index can be found';
        warning(msg)
        fprintf('\n')
    end
    
    % (6) Plot for debugging purpose
    if ( showFigure == 1 )  &&  ( prod(~isnan( anchorIndex )) == 1 )
        
        figure
        title( gca, { [ 'Signals X=', num2str(col), ' Y=', num2str(row), ' & Anchor For Ensemble' ]; '' } )
        hold( gca, 'on' )
        plot( gca, signalTime, sig, 'Color','Black', 'LineWidth',2 )
        plot( gca, signalTime(anchorIndex), sig(anchorIndex), 'Color','Red', 'LineStyle','none', 'LineWidth',2, 'Marker','^', 'MarkerSize',10)
        
        xLeft = signalTime(winStartIndex);
        xRight = signalTime(winEndIndex);
        yBottom = min(sig);
        yTop = max(sig);
        typeWindowSelectionPatchColor = [0.89, 0.47, 0.58]; % Pink
        patch( gca, [xLeft, xRight, xRight, xLeft], [yBottom, yBottom, yTop, yTop], typeWindowSelectionPatchColor, 'FaceAlpha',0.3, 'EdgeColor','none')
        hold( gca, 'off' )
        xlim( gca, [0, signalTime(end)] )
        legend( 'Signals', 'Anchor For Ensemble', 'User Selected Beat', 'Location','northeastoutside' )
    end
    
    
    
elseif isequal( methodName, 'Multi Beats' )
    
    % (1) Get all the input
    inputData = varargin{1}; % 3D matrix
    row = varargin{2};
    col = varargin{3};
    signalTime = varargin{4};
    multiBeatsWindowStartIndex = varargin{5};
    multiBeatsWindowEndIndex = varargin{6};
    
    % (2) Preparation before peak detection
    sig = squeeze( inputData(row,col,:) ); % For peak detection
    beatNumber = length( multiBeatsWindowStartIndex );
    beatLength = multiBeatsWindowEndIndex - multiBeatsWindowStartIndex + 1; % The length of each beats
    index_beat_maxLength = find( beatLength == max(beatLength), 1,'first' ); % The index of beat with max beat length
    
    % (3) Generate anchorIndex
    for ID = 1 : beatNumber
        sig_beat = sig( multiBeatsWindowStartIndex(ID) : multiBeatsWindowEndIndex(ID) );
        peakIndex(ID) = find( sig_beat == max(sig_beat), 1,'first' ) + multiBeatsWindowStartIndex(ID) - 1;
    end
    
    % (4) Generate "beatStart_to_anchor_length" and "beatEnd_to_anchor_length"
    beatStart_to_anchor_length = abs( peakIndex(index_beat_maxLength) - multiBeatsWindowStartIndex(index_beat_maxLength) ); % Use the longest beat
    beatEnd_to_anchor_length = abs( multiBeatsWindowEndIndex(index_beat_maxLength) - peakIndex(index_beat_maxLength) ); % Use the longest beat
    
    % (5) Under the current "beatStart_to_anchor_length" and "beatEnd_to_anchor_length", check if the 1st and/or last anchor beat will exceed signal length
    if peakIndex(end) + beatEnd_to_anchor_length > length(signalTime)
        
        peakIndex(end) = [];
        
        multiBeatsWindowStartIndex(end) = [];
        multiBeatsWindowEndIndex(end) = [];
    end
    
    if ~isempty( peakIndex )
        
        if peakIndex(1) - beatStart_to_anchor_length < 1
            
            peakIndex(1) = [];
            
            multiBeatsWindowStartIndex(1) = [];
            multiBeatsWindowEndIndex(1) = [];
        end
        
        if ~isempty( peakIndex )
            
            anchorIndex = peakIndex;
            if isrow(anchorIndex)
                anchorIndex = anchorIndex';
            end
            
            % Update "beatLength", "index_beat_maxLength", % "specialOneBeatWindowStartIndex", % "specialOneBeatWindowEndIndex"
            beatLength = multiBeatsWindowEndIndex - multiBeatsWindowStartIndex + 1; % The length of each beats
            index_beat_maxLength = find( beatLength == max(beatLength), 1,'first' ); % The index of beat with max beat length
            
            specialOneBeatWindowStartIndex = multiBeatsWindowStartIndex(index_beat_maxLength);
            specialOneBeatWindowEndIndex = multiBeatsWindowEndIndex(index_beat_maxLength);
        end
    end
    
    % (6) Warning
    if isnan( anchorIndex )
        
        msg = 'No anchor index can be found';
        warning(msg)
        fprintf('\n')
    end
    
    % (7) Plot for debugging purpose
    if ( showFigure == 1 )  &&  ( prod(~isnan( anchorIndex )) == 1 )
        
        figure
        title( gca, { [ 'Signals X=', num2str(col), ' Y=', num2str(row), ' & Anchor For Ensemble' ]; '' } )
        hold( gca, 'on' )
        plot( gca, signalTime, sig, 'Color','Black', 'LineWidth',2 )
        plot( gca, signalTime(anchorIndex), sig(anchorIndex), 'Color','Red', 'LineStyle','none', 'LineWidth',2, 'Marker','^', 'MarkerSize',10)
        
        xLeft = signalTime( multiBeatsWindowStartIndex(index_beat_maxLength) );
        xRight = signalTime( multiBeatsWindowEndIndex(index_beat_maxLength) );
        yBottom = min(sig);
        yTop = max(sig);
        typeWindowSelectionPatchColor = [0.89, 0.47, 0.58]; % Pink
        patch( gca, [xLeft, xRight, xRight, xLeft], [yBottom, yBottom, yTop, yTop], typeWindowSelectionPatchColor, 'FaceAlpha',0.3, 'EdgeColor','none')
        hold( gca, 'off' )
        xlim( gca, [0, signalTime(end)] )
        legend( 'Signals', 'Anchor For Ensemble', 'The Longest Beat Among Multi Beats', 'Location','northeastoutside' )
    end
end

end