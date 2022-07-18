function CVVectorMatrix = calculateCVVector( actMatrix, xPixelResolution, yPixelResolution )

% Description - 20211202
% 
% CVVectorMatrix - Conduction velocity vector (i.e., direction, speed) of each pixel. Data is in the form of complex number (real - x component, image - y component)
%
% METHOD
%
% (1) The method used for calculating conduction velocity is fully described by
% Bayly et al in "Estimation of Conduction Velocity Vecotr Fields from Epicardial Mapping Data".
%
% (2) Briefly, this function calculates the conduction velocity for a region of interest (ROI) 
% for a single optical action potential.
%
% (3) 1st an activation map is calculated for the ROI by identifying the time
% of maximum derivative of each ROI pixel.
%
% (4) 2nd a third-order polynomial surface is fit to the activation map and the
% surface derivative of the fitted surface is calculated.
%
% (5) 3rd, the x and y components of conduction velocity are calculated per pixel (pixel/msec).
%
%
% REFERENCES <--------
% Bayly PV, KenKnight BH, Rogers JM, Hillsley RE, Ideker RE, Smith WM.
% "Estimation of COnduction Velocity Vecotr Fields from Epicardial Mapping
% Data". IEEE Trans. Bio. Eng. Vol 45. No 5. 1998.
% https://ieeexplore.ieee.org/document/668746
%
%
% ADDITIONAL NOTES
% The conduction velocity vectors are highly dependent on the goodness of
% fit of the polynomial surface.  In the Balyly paper, a 2nd order polynomial
% surface is used.  We found this polynomial to be insufficient and thus increased
% the order to 3.  MATLAB's intrinsic fitting functions might do a better
% job fitting the data and should be more closely examined if velocity
% vectors look incorrect.


%%

actMatrixTemporary = actMatrix;

gridSize = 19; % 'grid' is a 'gridSize-by-gridSize' square matrix
halfGridSize = (gridSize-1) / 2;

minPointsNumber = 20; % The min number of useable data points inside a 'gridSize-by-gridSize' matrix

% Speed unit conversion: 1 mm/msec == 1000 mm/sec == 100 cm/sec == 1 m/sec
% http://www.vhlab.umn.edu/atlas/conduction-system-tutorial/overview-of-cardiac-conduction.shtml
maxConductionSpeed_Threshold = 1; % Unit of mm/msec
AdjRSquared_Threshold = 0.60; % The threshold for adjusted R-squared

CVVectorMatrix = nan( size(actMatrixTemporary) );


polyOrder = 3; % ---------------


for rowID = 1 : size(actMatrixTemporary, 1) % Go through each row. rowID in matlab matrix = y in Cartesian system
    for colID = 1 : size(actMatrixTemporary, 2) % Go through each column. colID in matlab matrix = x in Cartesian system
        
        % 'gridRow' and 'gridCol' have unit of 'pixel'
        gridRow = rowID - halfGridSize : rowID + halfGridSize; % 'gridRow' - grid row range
        gridRow( gridRow < 1  |  gridRow > size(actMatrixTemporary,1) ) = []; % A grid can only be a subset of 'actMatrixTemporary'
        gridCol = colID - halfGridSize : colID + halfGridSize; % 'gridCol' - grid column range
        gridCol( gridCol < 1  |  gridCol > size(actMatrixTemporary,2) ) = []; % A grid can only be a subset of 'actMatrixTemporary'
        
        gridArea = actMatrixTemporary( gridRow, gridCol ); % A grid is a square area that centred at (rowID,ColID) in 'actMatrixTemporary'
        goodPixelNumberInGrid = sum( ~isnan( gridArea(:) ) ); % There can be 'NaN' inside the 'actMatrixTemporary' and 'grid', we only need real value
        
        
        if goodPixelNumberInGrid >= minPointsNumber    &&    ~isnan( actMatrixTemporary(rowID,colID) ) % The centre of a grid should be real value. The grid should have enough data points
            
            % PART I - Shift the grid such that it is centred at (0,0). So far we are still in 'Matlab row-col system'.
            % 'gridRowShifted' and 'gridColShifted' have unit of 'pixel'
            gridRowShifted = gridRow - rowID; % The result is interger
            gridColShifted = gridCol - colID; % The result is interger
            
            % PART II - Convert the grid position from 'Matlab row-col system' to 'Cartesian system'
            % 'gridX' and 'gridY' have unit of 'mm'
            gridX = gridColShifted * xPixelResolution; % colID in matlab matrix = x in Cartesian system
            gridY = gridRowShifted * yPixelResolution; % rowID in matlab matrix = y in Cartesian system
            
            % PART III - Prepare 'xData', 'yData', 'tData' for surface fitting.
            [xData,yData] = meshgrid( gridX, gridY );
            xData = reshape(xData, [],1); % x coordinate. Unit of 'mm'
            yData = reshape(yData, [],1); % y coordinate. Unit of 'mm'
            tData = reshape(gridArea,  [],1); % activation time at point(x,y)
            % There can be 'NaN' inside the grid, remove those pixel points
            xData( isnan(tData) ) = [];
            yData( isnan(tData) ) = [];
            tData( isnan(tData) ) = [];
            
            
            % PART IV - Get the coefficients of fitting
            % Read page 570 in REFERENCE PAPER (see information at the end of this function) for matrix configuration
            if polyOrder == 2
                % f22 = A*x^2 + B*y^2 + C*x*y + D*x + E*y + F;
                polyFit22 = [ xData.^2,  yData.^2,  xData.*yData,  xData,  yData,  ones(size(tData,1),1) ]; % 'polyFit22' represents a 6-columns matrix. '22' means 2nd-order in both x and y.
                coefficient22 = polyFit22 \ tData; % Get coefficients for 2nd-order polynomial surface fitting. 'coefficient22' is a column vector
                
                % Calculate R-Squared
                tHat22 = polyFit22 * coefficient22; % 'tHat22 - predicted value using 2nd-order fit'. 'tHat22' is a column vector
                SSR22 = sum( (tData - tHat22).^2 ); % Sum of squared residuals (SSR) == Residual sum of squares (RSS) == Sum of squared estimate of errors (SSE)
                SST22 = sum( (tData - mean(tData)).^2 ); % Sum of squares total (SST) == Total sum of squares (TSS)
                RSquared22 = 1 - SSR22/SST22; % The 'R-Squared' from 2nd-order polynomial surface fitting
                
                % Calculate Adjusted R-Squared
                n22 = length(tData); % The number of data points used for fitting a 2nd-order polynomial surface
                p22 = length(coefficient22); % The number of coefficients in a 2nd-order polynomial surface
                AdjRSquared22 = RSquared22 - (1-RSquared22)*p22 / (n22-p22-1); % The 'Adjusted R-Squared' from 2nd-order polynomial surface fitting
                
                % ------- Below for testing purpose ---------------------
                %   AdjRSquared22 = RSquared22;
                
                %   AdjRSquared22 = sqrt( SSR22 / sum( tData.^2 ) ); % Sharon-Rhythm   Unexplained part <= 0.25
                
                %   AdjRSquared22 = sqrt( SSR22/SST22 ); % Electro Map
                % ------- Above for testing purpose ---------------------
                
                
            elseif polyOrder == 3
                % f33 = A*x^3 + B*y^3 + C*x*y^2 + D*x^2*y + E*x^2 + F*y^2 + G*x*y + H*x + I*y + J
                polyFit33 = [ xData.^3,  yData.^3,  xData.*(yData.^2), (xData.^2).*yData,  xData.^2,  yData.^2,  xData.*yData,  xData,  yData,  ones(size(tData,1),1)  ]; % 'polyFit33' represents a 10-columns matrix. '33' means 3rd-order in both x and y.
                coefficient33 = polyFit33 \ tData; % Get coefficients for 3rd-order polynomial surface fitting. 'coefficient33' is a column vector
                
                % Calculate R-Squared
                tHat33 = polyFit33 * coefficient33; % 'tHat33 - predicted value using 3rd-order fit'. 'tHat33' is a column vector
                SSR33 = sum( (tData - tHat33).^2 ); % Sum of squared residuals (SSR) == Residual sum of squares (RSS) == Sum of squared estimate of errors (SSE)
                SST33 = sum( (tData - mean(tData)).^2 ); % Sum of squares total (SST) == Total sum of squares (TSS)
                RSquared33 = 1 - SSR33/SST33; % The 'R-Squared' from 3rd-order polynomial surface fitting
                
                % Calculate Adjusted R-Squared
                n33 = length(tData); % The number of data points used for fitting a 3rd-order polynomial surface
                p33 = length(coefficient33); % The number of coefficients in a 3rd-order polynomial surface
                AdjRSquared33 = RSquared33 - (1-RSquared33)*p33 / (n33-p33-1); % The 'Adjusted R-Squared' from 3rd-order polynomial surface fitting
            end
            
            
            % PART V A - Get conduction velocity vectors
            if polyOrder == 2
                
                if AdjRSquared22 >= AdjRSquared_Threshold % Check if adjusted R-Squared reaches threshold requirement
                    % Calculate 'Tx_0' and 'Ty_0' using mathematic equation manually
                    % (22-1) f22 = A*x^2 + B*y^2 + C*x*y + D*x + E*y + F;
                    % (22-2) f22x = 2*A*x + C*y + D - partial derivative of x
                    % (22-3) f22y = 2*B*y + C*x + E - partial derivative of y
                    % (22-4) Tx_0 = D
                    % (22-5) Ty_0 = E
                    Tx_0 = coefficient22(4); % 'Tx_0' is a partial derivative 'delta.T / delta.x' at (x=0, y=0) of function 't.hat = f(xData,yData)'
                    Ty_0 = coefficient22(5); % 'Ty_0' is a partial derivative 'delta.T / delta.y' at (x=0, y=0) of function 't.hat = f(xData,yData)'
                    
                    % PART V B - Calculate conduction velolcity vector at point (x=0, y=0) (i.e., the centre of the grid)
                    if Tx_0^2 + Ty_0^2 ~= 0
                        
                        % 'CVx_0' and 'CVy_0' in unit of 'mm/msec' so as the conduction speed
                        CVx_0 = Tx_0 / (Tx_0^2 + Ty_0^2); % 'CVx_0' is the x-component of conduction velocity vector at point (x=0, y=0)
                        CVy_0 = Ty_0 / (Tx_0^2 + Ty_0^2); % 'CVy_0' is the y-component of conduction velocity vector at point (x=0, y=0)
                        
                        % PART V C - Check if the conduction speed exceeds threshold
                        % Speed unit conversion: 1 mm/msec == 1000 mm/sec == 100 cm/sec == 1 m/sec
                        if sqrt(CVx_0^2 + CVy_0^2) <= maxConductionSpeed_Threshold % Only keep CVs less than conductionSpeed_Threshold mm/sec
                            
                            CVVectorMatrix(rowID,colID) = CVx_0  +  CVy_0 * 1i; % Store conudction velocity vector in complex number form
                        end
                    end
                end
                
                
                
            elseif polyOrder == 3
                
                if AdjRSquared33 >= AdjRSquared_Threshold % Check if adjusted R-Squared reaches threshold requirement
                    % (33-1) f33 = A*x^3 + B*y^3 + C*x*y^2 + D*x^2*y + E*x^2 + F*y^2 + G*x*y + H*x + I*y + J
                    % (33-2) ff3x = 3*A*x^2 + C*y^2 + 2*D*x*y + 2*E*x + G*y + H - partial derivative of x
                    % (33-3) ff3y = 3*B*y^2 + 2*C*x*y + D*x^2 + 2*F*y + G*x + I - partial derivative of y
                    % (33-4) Tx_0 = H
                    % (33-5) Ty_0 = I
                    Tx_0 = coefficient33(8); % 'Tx_0' is a partial derivative 'delta.T / delta.x' at (x=0, y=0) of function 't.hat = f(xData,yData)'
                    Ty_0 = coefficient33(9); % 'Ty_0' is a partial derivative 'delta.T / delta.y' at (x=0, y=0) of function 't.hat = f(xData,yData)'
                    
                    % PART V B - Calculate conduction velolcity vector at point (x=0, y=0) (i.e., the centre of the grid)
                    if Tx_0^2 + Ty_0^2 ~= 0
                        
                        % 'CVx_0' and 'CVy_0' in unit of 'mm/msec' so as the conduction speed
                        CVx_0 = Tx_0 / (Tx_0^2 + Ty_0^2); % 'CVx_0' is the x-component of conduction velocity vector at point (x=0, y=0)
                        CVy_0 = Ty_0 / (Tx_0^2 + Ty_0^2); % 'CVy_0' is the y-component of conduction velocity vector at point (x=0, y=0)
                        
                        % PART V C - Check if the conduction speed exceeds threshold
                        % Speed unit conversion: 1 mm/msec == 1000 mm/sec == 100 cm/sec == 1 m/sec
                        if sqrt(CVx_0^2 + CVy_0^2) <= maxConductionSpeed_Threshold % Only keep CVs less than conductionSpeed_Threshold 'mm/msec'
                            
                            CVVectorMatrix(rowID,colID) = CVx_0  +  CVy_0 * 1i; % Store conudction velocity vector in complex number form
                        end
                    end
                end
            end
            
            
            % METHOD
            % The method used for calculating conduction velocity is fully described by
            % Bayly et al in "Estimation of Conduction Velocity Vecotr Fields from
            % Epicardial Mapping Data".  Briefly, this function calculates the
            % conduction velocity for a region of interest (ROI) for a single optical
            % action potential.
            % 1st an activation map is calculated for the ROI by identifying the time
            % of maximum derivative of each ROI pixel.
            % 2nd a third-order polynomial surface is fit to the activation map and the
            % surface derivative of the fitted surface is calculated.
            % 3rd, the x and y components of conduction velocity are calculated per
            % pixel (pixel/msec).
            
            
            % REFERENCES <--------
            % Bayly PV, KenKnight BH, Rogers JM, Hillsley RE, Ideker RE, Smith WM.
            % "Estimation of COnduction Velocity Vecotr Fields from Epicardial Mapping
            % Data". IEEE Trans. Bio. Eng. Vol 45. No 5. 1998.
            % https://ieeexplore.ieee.org/document/668746
            
            % ADDITIONAL NOTES
            % The conduction velocity vectors are highly dependent on the goodness of
            % fit of the polynomial surface.  In the Balyly paper, a 2nd order polynomial
            % surface is used.  We found this polynomial to be insufficient and thus increased
            % the order to 3.  MATLAB's intrinsic fitting functions might do a better
            % job fitting the data and should be more closely examined if velocity
            % vectors look incorrect.
        end
    end
end

end