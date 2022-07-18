function [ dataSectionTime, dataSection, phaseMapDataSection, hilbertDataSection, wavefrontDataSectionTitle, wavefrontDataSection, readMe ] = calculatePhase( acqFreq, inputData, mapCalculationROI)

% Description - 20220328
% 
% "acqFreq" - acquistion frequency (Hz)
% "inputData" - a 3D matrix
%
% 'Wavefronts are defined as the isophase lines along φ = π/2.'
% ( Gutbrod SR, Walton R, Gilbert S, et al. 
% Quantification of the transmural dynamics of atrial fibrillation by simultaneous endocardial and epicardial optical mapping in an acute sheep model. 
% Circ Arrhythm Electrophysiol. 2015;8(2):456-465. doi:10.1161/CIRCEP.114.002545 )
%
% Several recommended papers for introduction to and application of 'phase dynamics analysis' are
% (1) 


%% Initial Conditioning

% inputData = inputData(:, :, winStartIndex:winEndIndex) .* mapCalculationROI;

inputData = inputData .* mapCalculationROI;


% (1) Get "dataSectionTime"
[ row, col, frameNumber ] = size(inputData);
dataSectionTime = (0 : frameNumber-1) * (1 / acqFreq); % Unit in 'sec'

% (2) Get normalised "dataSection". Data ranges in [0,1]
pixelMin = min( inputData, [], 3 ); % Min value of each pixel's signal
pixelMax = max( inputData, [], 3 ); % Max value of each pixel's signal
dataSection = rescale( inputData, 'InputMin',pixelMin, 'InputMax',pixelMax );

dataSection = round(dataSection,2); % 'dataSection' is a 3D matrix. Each pixel's signal is along the 3rd dimnension

% (2) Remove mean from each pixel's signal
% 'Phase maps' are created using the Hilbert transform approach. 
% The VF segments are preprocessed to remove the mean from the VF segments. 
% The signals are then filtered and converted by Hilbert transform.' from paper
% Umapathy, K., Masse, S., Sevaptsidis, E., Asta, J., Krishnan, S., & Nanthakumar, K. (2009). 
% Spatiotemporal Frequency Analysis of Ventricular Fibrillation in Explanted Human Hearts. 
% IEEE Transactions on Biomedical Engineering, 56(2), 328–335. https://doi.org/10.1109/tbme.2008.2006031
dataSection_mean = mean( dataSection, 3 ); % 'dataSection_mean' is a 2D matrix. Each element is the 'mean' value of each pixel's signal
dataSection_zeroMean = dataSection - dataSection_mean; % 'dataSection_zeroMean' is a 3D matrix


%% Conversion to Phase Space (hilbert is MATLAB Built-In Function)

% https://www.mathworks.com/help/signal/ug/hilbert-transform.html
% (1) The Hilbert transform facilitates the formation of the analytic signal. 
% (2) The toolbox function hilbert computes the Hilbert transform for a real input sequence x and returns a complex result of the same length, y = hilbert(x), 
% where the real part of y is the original real data and the imaginary part is the actual Hilbert transform. 
% (3) IMPORTANT - The Hilbert transform is related to the actual data by a '90-degree phase shift'; sines become cosines and vice versa.
%
% 'hilbert' MATLAB description
% x = hilbert(xr) returns the analytic signal, x, from a real data sequence, xr. If xr is a matrix, then hilbert finds the analytic signal corresponding to each column.

dataSection_zeroMean_2D = reshape( dataSection_zeroMean, row*col, [] ); % Each row is a pixel's signal
dataSection_zeroMean_2D = dataSection_zeroMean_2D'; % Each column is a pixel's signal

hdata_2D = hilbert(dataSection_zeroMean_2D); % 'hdata_2D' is a complex matrix. Each column is the hilbert-transform of a pixel's orignal signal


phaseMapDataSection_2D = -1 * angle(hdata_2D); % For a matrix, 'angle' finds the phase angle (i.e., in radian) corresponding to each column
phaseMapDataSection_2D = phaseMapDataSection_2D'; % Now, each row of 'phaseMapDataSection_2D' corresponds to a  pixel. Column number = frameNumber. Row number = pixel number

phaseMapDataSection = reshape( phaseMapDataSection_2D, row, col, [] ); % Now 'phaseMapDataSection' is a 3D matrix. Each pixel's phase information is along the 3rd dimnension

hdata_2D = hdata_2D'; % Now, each row of 'hdata_2D' corresponds to a  pixel. Column number = frameNumber. Row number = pixel number
hilbertDataSection = reshape( hdata_2D, row, col, [] ); % Now 'hilbertDataSection' is a 3D matrix. Each pixel's hilbert transform is along the 3rd dimnension


%% Calculate Wavefront

% Wavefronts are defined as the isophase lines along φ = π/2.
% ( Gutbrod SR, Walton R, Gilbert S, et al.
% Quantification of the transmural dynamics of atrial fibrillation by simultaneous endocardial and epicardial optical mapping in an acute sheep model.
% Circ Arrhythm Electrophysiol. 2015;8(2):456-465. doi:10.1161/CIRCEP.114.002545 )

wavefrontDataSectionTitle = { '(1) Wavefront ID', ...
    '(2) Wavefront Height (Unit in Radian)', ...
    '(3) Wavefront Length (Unit in Pixel)', ...
    '(4) Wavefront Vertex X Coordinate', ...
    '(5) Wavefront Vertex Y Coordinate' };

wavefrontDataSection = cell( frameNumber, 1 );

readMe = { '"wavefrontDataSection" is a cell column. Its element number = frame number'; ...
    'Each element of the "wavefrontDataSection" is another cell variable, that is, "wavefront information" of a frame.'; ...
    '"wavefront information" is a 5 column cell. See "wavefrontDataSectionTitle" for the meaning of each column' };


wavefrontHeight = pi/2; 

% (0) Various threshold
wavefrontLength_Thres = 10; % Unit in pixel
spaceGradient_Thres = 1;
distance_Thres = 5; % Unit in pixel

for frameID = 1 : frameNumber
    
    % (1) Locate wavefronts
    [ wavefrontInfoTitle, wavefrontInfo ] = findWavefront( phaseMapDataSection(:,:,frameID), [wavefrontHeight, wavefrontHeight] );
    
    if ~iscell(wavefrontInfo)  &&  isnan( wavefrontInfo )
        
        wavefrontDataSection{ frameID } = NaN;
        
        continue
    end
    
    
    % (2) Remove any wavefronts whose length is < 10 pixels (i.e., noise filter)
    wavefrontLength = cell2mat( wavefrontInfo( :,3 ) ); % 'wavefrontLength' is a column vector
    
    wavefrontInfo( wavefrontLength <= wavefrontLength_Thres, : ) = []; % Remove short wavefronts
    
    wavefrontID = [ 1 : size( wavefrontInfo,1 ) ]';
    
    wavefrontInfo( :, 1 ) = num2cell( wavefrontID );
    
    
    % (3.1) Remove and separate wavefronts based on large spatial gradient
    % Algorithms of 'grdient' function of MATLAB ----------
    % gradient calculates the central difference for interior data points. 
    % 
    % For example, consider a matrix with unit-spaced data, A, that has horizontal gradient G = gradient(A). 
    % The interior gradient values, G(:,j) = 0.5 * ( A(:,j+1) - A(:,j-1) );
    % The subscript j varies between 2 and N-1, with N = size(A,2).
    % 
    % gradient calculates values along the edges of the matrix with single-sided differences:
    % G(:,1) = A(:,2) - A(:,1);
    % G(:,N) = A(:,N) - A(:,N-1);
    
    [ px, py ] = gradient( phaseMapDataSection(:,:,frameID) ); % 'px' and 'py' are partial derivative in x and y direction. Both 'px' and 'py' are 2D matrix (row-by-col)
    spaceGradient = max( abs(px), abs(py) ); % 'spaceGradient' is a 2D matrix (row-by-col)
    
    [ rowIdx, colIdx ] = find( spaceGradient > spaceGradient_Thres ); % 'rowIdx' and 'colIdx' are column vectors
    
    %%%largeSpaceGradient_X = colIdx; % 'x' (or 'y') in Cartesian system is 'col' (or 'row') in MATLAB matrix
    %%%largeSpaceGradient_Y = rowIdx; % 'x' (or 'y') in Cartesian system is 'col' (or 'row') in MATLAB matrix
    
    largeSpaceGradient_XY = [ colIdx, rowIdx ]; % 'x' (or 'y') in Cartesian system is 'col' (or 'row') in MATLAB matrix
    
    
    pseudoRowNum = sum( cell2mat( wavefrontInfo( :,3 ) ) );
    wavefrontInfo_TemporaryHolder = cell( pseudoRowNum, 5 );
    wavefrontInfo_TemporaryHolder( : , 1 ) = num2cell( [1:pseudoRowNum]' ); % (1) Wavefront ID
    wavefrontInfo_TemporaryHolder( : , 2 ) = num2cell( ones(pseudoRowNum,1)*(pi/2) ); % (2) Wavefront Height (Unit in Radian)
    
    index = 1;
    
    wavefrontNumber = size( wavefrontInfo, 1 );
    
    for wavefrontCheckID = 1 : wavefrontNumber % Remove and separate wavefronts based on large spatial gradient
        
        wavefront_XY = [ wavefrontInfo{ wavefrontCheckID, 4 },  wavefrontInfo{ wavefrontCheckID, 5 } ]; % 'wavefront_XY' is a 2-column matrix. 'Column 1 (or 2)' means 'X (or Y)'
        
        wavefront_XY_Ceil = ceil( wavefront_XY );
        wavefront_XY_Floor = floor( wavefront_XY );
        
        XY_Ceil_Yes = ismember( wavefront_XY_Ceil, largeSpaceGradient_XY, 'rows' ); % '1 (or 0)' means 'is (or not)' a member
        XY_Floor_Yes = ismember( wavefront_XY_Floor, largeSpaceGradient_XY, 'rows' ); % '1 (or 0)' means 'is (or not)' a member
        
        XY_To_Exclude = logical( XY_Ceil_Yes + XY_Floor_Yes ); % 'XY_To_Exclude' is a column vector. '0' means NO need to exclude
        
        wavefront_SmallGradient_XY = wavefront_XY( ~XY_To_Exclude, : ); % Only keep wavefronts with small gradient. 'wavefront_SmallGradient_XY' is a 2-column matrix. 'Column 1 (or 2)' means 'X (or Y)'
        
        wavefront_SmallGradient_X = wavefront_SmallGradient_XY( :, 1 );
        wavefront_SmallGradient_Y = wavefront_SmallGradient_XY( :, 2 );
        
        
        % (3.2) Separate non-connected vectors.
        % Previously some X Y  was discarded because large gradient. An initial single wavefront can therefore be cut into several wavefront parts        
        % Distance between two points = √[ (x2−x1)^2 + (y2-y1)^2 ]
        XX_Part = ( wavefront_SmallGradient_X( 2 : end ) - wavefront_SmallGradient_X( 1 : end-1 ) ).^2;
        YY_Part = ( wavefront_SmallGradient_Y( 2 : end ) - wavefront_SmallGradient_Y( 1 : end-1 ) ).^2;
        distance = sqrt( XX_Part + YY_Part );
        
        segmentPart = find( distance > distance_Thres );
        
        if isempty(segmentPart)
            
            wavefrontInfo_TemporaryHolder{ index, 3 } = length( wavefront_SmallGradient_X ); % (3) Wavefront Length (Unit in Pixel)
            wavefrontInfo_TemporaryHolder{ index, 4 } = wavefront_SmallGradient_X; % (4) Wavefront Vertex X Coordinate
            wavefrontInfo_TemporaryHolder{ index, 5 } = wavefront_SmallGradient_Y; % (5) Wavefront Vertex Y Coordinate
            
            index = index + 1;
            
        else
            
            wavefrontInfo_TemporaryHolder{ index, 3 } = segmentPart(1);
            wavefrontInfo_TemporaryHolder{ index, 4 } = wavefront_SmallGradient_X( 1 : segmentPart(1) );
            wavefrontInfo_TemporaryHolder{ index, 5 } = wavefront_SmallGradient_Y( 1 : segmentPart(1) );
            
            index = index + 1;
            
            if length(segmentPart) > 1
                
                for ID = 1 : length(segmentPart) - 1
                    
                    wavefrontInfo_TemporaryHolder{ index, 3 } = segmentPart(ID+1) - segmentPart(ID);
                    wavefrontInfo_TemporaryHolder{ index, 4 } = wavefront_SmallGradient_X( segmentPart(ID)+1 : segmentPart(ID+1) );
                    wavefrontInfo_TemporaryHolder{ index, 5 } = wavefront_SmallGradient_Y( segmentPart(ID)+1 : segmentPart(ID+1) );
                    
                    index = index + 1;
                end
            end
            
            wavefrontInfo_TemporaryHolder{ index, 4 } = wavefront_SmallGradient_X( segmentPart(end)+1 : end );
            wavefrontInfo_TemporaryHolder{ index, 5 } = wavefront_SmallGradient_Y( segmentPart(end)+1 : end );
            wavefrontInfo_TemporaryHolder{ index, 3 } = length( wavefrontInfo_TemporaryHolder{ index, 4 } );
            
            index = index + 1;
        end       
    end
    
    if index <= pseudoRowNum
        
        wavefrontInfo_TemporaryHolder( index : end, : ) = [];
    end
    
    
    wavefrontDataSection{ frameID } = wavefrontInfo_TemporaryHolder; % 'wavefrontDataSection' is a cell that includes another cell (i.e., 'wavefrontInfo_TemporaryHolder')
end


%% Plot results

plotRequest = 0; % 0 or 1

if plotRequest == 1
    
    directory = '/Users/lin/Desktop';
    phasename = 'testFile';
    
    screenSize = get( groot, 'ScreenSize' );
    figureObject =  figure('Name', 'Phase Map' );
    figureObject.Position = [ 1, 20, 0.9*screenSize(4), 0.9*screenSize(4) ];
    ax_Figure = axes;
    
    writerObj = VideoWriter( [directory, '/', phasename] );
    writerObj.FrameRate = 20;
    open(writerObj);
    movegui( figureObject, 'center' );
    set( gcf, 'color', [1 1 1] );
    
    for frameID = 1 : 1 : 200 % size(phaseMapDataSection,3)
        
        % Plot the phase map
        h = imagesc( ax_Figure, phaseMapDataSection(:, :, frameID) ); % 'phaseMapDataSection' is a 3D matrix. The 3rd dimension is frame
        set( h, 'AlphaData', ~isnan( phaseMapDataSection(:,:,frameID) ) );
        
        colormap( ax_Figure, jet )
        
        colorbar( ax_Figure, ...
            'Ticks', [ -pi, -pi/2, 0, pi/2, pi ],...
            'TickLabels', {'-\pi', '-\pi/2', '0', 'pi/2 (Wavefront)', '\pi'})
        
        caxis( ax_Figure, [ -pi, pi ] ) %
        
        axis image
        axis off
        
        
        % Plot wavefront
        wavefrontInfo_TemporaryHolder = wavefrontDataSection{ frameID }; % 'wavefrontDataSection' is a cell that includes another cell (i.e., 'wavefrontInfo_TemporaryHolder')
        
        if iscell( wavefrontInfo_TemporaryHolder )
            
            for ID = 1 : size( wavefrontInfo_TemporaryHolder, 1 )
                
                wavefront_X = wavefrontInfo_TemporaryHolder{ ID,4 };
                wavefront_Y = wavefrontInfo_TemporaryHolder{ ID,5 };
                
                line( ax_Figure, wavefront_X, wavefront_Y, 'Color','White', 'LineWidth',4 );               
            end
        end
        
        pause( 0.001 )
        
        frame = getframe(gcf);
        writeVideo(writerObj,frame);
    end
    
    close(figureObject);
    close(writerObj);
end

end