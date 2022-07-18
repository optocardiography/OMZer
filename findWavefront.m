function [ wavefrontInfoTitle, wavefrontInfo ] = findWavefront( phaseMapFrame, wavefrontHeight )

% Description - 20220328
%
% 'phaseMapFrame' is a 2D matrix
% 'wavefrontHeight' defines what is wavefront
% 'wavefrontInfo' is a cell. See 'wavefrontInfoTitle' for the meaning of
% each column inside 'wavefrontInfo'
% 
% Wavefronts are defined as the isophase lines along φ = π/2.
% ( Gutbrod SR, Walton R, Gilbert S, et al.
% Quantification of the transmural dynamics of atrial fibrillation by simultaneous endocardial and epicardial optical mapping in an acute sheep model.
% Circ Arrhythm Electrophysiol. 2015;8(2):456-465. doi:10.1161/CIRCEP.114.002545 )

%%

contourMatrix = contourc( phaseMapFrame, [wavefrontHeight, wavefrontHeight] ); % 'contourc' is a MATLAB built-in function

if isempty( contourMatrix )
    
    msg = 'No wavefront (φ = π/2) can be found';
    warning( msg );
    fprintf('\n');
    
    wavefrontInfoTitle = NaN;
    wavefrontInfo = NaN;
    
else
    
    contourMatrix_Copy = contourMatrix;
    
    wavefrontID = 1;
    
    wavefrontInfoTitle = { '(1) Wavefront ID', ...
        '(2) Wavefront Height (Unit in Radian)', ...
        '(3) Wavefront Length (Unit in Pixel)', ...
        '(4) Wavefront Vertex X Coordinate', ...
        '(5) Wavefront Vertex Y Coordinate' };
    wavefrontInfo = cell( size(contourMatrix,2), 5 );
    
    while ~isempty( contourMatrix )
        
        wavefrontInfo{ wavefrontID, 1 } = wavefrontID;
        wavefrontInfo{ wavefrontID, 2 } = pi/2;
        
        vertexNum = contourMatrix( 2, 1 );
        wavefrontInfo{ wavefrontID, 3 } = vertexNum;
        
        X_Coordinate = contourMatrix( 1,  2 : vertexNum+1 );
        Y_Coordinate = contourMatrix( 2,  2 : vertexNum+1 );
        
        X_Coordinate = round( X_Coordinate, 2 );
        Y_Coordinate = round( Y_Coordinate, 2 );
        
        if isrow(X_Coordinate)
            X_Coordinate = X_Coordinate';
        end
        
        if isrow(Y_Coordinate)
            Y_Coordinate = Y_Coordinate';
        end
        
        wavefrontInfo{ wavefrontID, 4 } = X_Coordinate;
        wavefrontInfo{ wavefrontID, 5 } = Y_Coordinate;
        
        contourMatrix( :,  1 : vertexNum+1 ) = [];
        
        wavefrontID = wavefrontID + 1;
    end
    
    
    if wavefrontID <= size(wavefrontInfo,1)
        
        wavefrontInfo( wavefrontID : end, : ) = [];
    end

end

