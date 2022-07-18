function oldversionTF = versionConverter(fileName,inputData)

maxMapNumber = 10;

% Create the new variable for Vm -----------------------
VmMap = cell(5,3);
VmMap{1,1} = 'Act';
VmMap{2,1} = 'Rep';
VmMap{3,1} = 'APD';
VmMap{4,1} = 'RT';
VmMap{5,1} = 'CV';

actMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) LB', '(6) UB', ...
    '(7) Data Section Time', '(8) Data Section', ...
    '(9) Locs Act', '(10) Act Matrix', ...
    '(11) Ensemble Peaks Number', ...
    '(12) Map User Comment'};
parameterNumber = length( actMapDataTitle );
actMapData = cell(1, parameterNumber, maxMapNumber);
VmMap{1,2} = actMapDataTitle;
VmMap{1,3} = actMapData;


repMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Rep Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', '(9) Data Section', ...
    '(10) Locs Rep', '(11) Rep Matrix', ...
    '(12) Ensemble Peaks Number', ...
    '(13) Map User Comment'};
parameterNumber = length( repMapDataTitle );
repMapData = cell(1, parameterNumber, maxMapNumber);
VmMap{2,2} = repMapDataTitle;
VmMap{2,3} = repMapData;


APDMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) APD Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', '(9) Data Section', ...
    '(10) Locs Act', '(11) Locs Rep', ...
    '(12) APD Matrix', ...
    '(13) Ensemble Peaks Number', ...
    '(14) Map User Comment'};
parameterNumber = length( APDMapDataTitle );
APDMapData = cell(1, parameterNumber, maxMapNumber);
VmMap{3,2} = APDMapDataTitle;
VmMap{3,3} = APDMapData;


RTMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Start Level', '(6) End Level', ...
    '(7) LB', '(8) UB', ...
    '(9) Data Section Time', '(10) Data Section', ...
    '(11) Locs Start', '(12) Locs End', ...
    '(13) RT Matrix', ...
    '(14) Ensemble Peaks Number', ...
    '(15) Map User Comment'};
parameterNumber = length( RTMapDataTitle );
RTMapData = cell(1, parameterNumber, maxMapNumber);
VmMap{4,2} = RTMapDataTitle;
VmMap{4,3} = RTMapData;


CVMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Act Matrix', ...
    '(6) CVVectorMatrix', '(7) CVVectorAngleMatrix', '(8) CVVectorSpeedMatrix', ...
    '(9) CVDirectingLineStartXY', '(10) CVDirectingLineEndXY', ...
    '(11) CVDirectingLineSubVectorMatrix', ...
    '(12) LineAngleDegree', '(13) VectorMembers', ...
    '(14) DistancewithinPixel', '(15) AnglewithinDegree', ...
    '(16) Data Section Time', '(17) Data Section', ...
    '(18) Locs Act', ...
    '(19) Ensemble Peaks Number', ...
    '(20) Map User Comment'};
parameterNumber = length( CVMapDataTitle );
CVMapData = cell(1, parameterNumber, maxMapNumber);
VmMap{5,2} = CVMapDataTitle;
VmMap{5,3} = CVMapData;



% Create the new variable for Ca -----------------------
CaMap = cell(6,3);
CaMap{1,1} = 'Act';
CaMap{2,1} = 'Rep';
CaMap{3,1} = 'CaTD';
CaMap{4,1} = 'RT';
CaMap{5,1} = 'DT';
CaMap{6,1} = 'DTau';

actMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) LB', '(6) UB', ...
    '(7) Data Section Time', '(8) Data Section', ...
    '(9) Locs Act', '(10) Act Matrix', ...
    '(11) Ensemble Peaks Number', ...
    '(12) Map User Comment'};
parameterNumber = length( actMapDataTitle );
actMapData = cell(1, parameterNumber, maxMapNumber);
CaMap{1,2} = actMapDataTitle;
CaMap{1,3} = actMapData;


repMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Rep Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', '(9) Data Section', ...
    '(10) Locs Rep', '(11) Rep Matrix', ...
    '(12) Ensemble Peaks Number', ...
    '(13) Map User Comment'};
parameterNumber = length( repMapDataTitle );
repMapData = cell(1, parameterNumber, maxMapNumber);
CaMap{2,2} = repMapDataTitle;
CaMap{2,3} = repMapData;


CaTDMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) CaTD Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', '(9) Data Section', ...
    '(10) Locs Act', '(11) Locs Rep', ...
    '(12) CaTD Matrix', ...
    '(13) Ensemble Peaks Number', ...
    '(14) Map User Comment'};
parameterNumber = length( CaTDMapDataTitle );
CaTDMapData = cell(1, parameterNumber, maxMapNumber);
CaMap{3,2} = CaTDMapDataTitle;
CaMap{3,3} = CaTDMapData;


RTMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Start Level', '(6) End Level', ...
    '(7) LB', '(8) UB', ...
    '(9) Data Section Time', '(10) Data Section', ...
    '(11) Locs Start', '(12) Locs End', ...
    '(13) RT Matrix', ...
    '(14) Ensemble Peaks Number', ...
    '(15) Map User Comment'};
parameterNumber = length( RTMapDataTitle );
RTMapData = cell(1, parameterNumber, maxMapNumber);
CaMap{4,2} = RTMapDataTitle;
CaMap{4,3} = RTMapData;


DTMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Start Level', '(6) End Level', ...
    '(7) LB', '(8) UB', ...
    '(9) Data Section Time', '(10) Data Section', ...
    '(11) Locs Start', '(12) Locs End', ...
    '(13) DT Matrix', ...
    '(14) Ensemble Peaks Number', ...
    '(15) Map User Comment'};
parameterNumber = length( DTMapDataTitle );
DTMapData = cell(1, parameterNumber, maxMapNumber);
CaMap{5,2} = DTMapDataTitle;
CaMap{5,3} = DTMapData;


DTauMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Start Level', '(6) End Level', ...
    '(7) LB', '(8) UB', ...
    '(9) Data Section Time', '(10) Data Section', ...
    '(11) Fit Data Section', ...
    '(12) Locs Start', '(13) Locs End', ...
    '(14) DTau Matrix', ...
    '(15) Ensemble Peaks Number', ...
    '(16) Map User Comment'};
parameterNumber = length( DTauMapDataTitle );
DTauMapData = cell(1, parameterNumber, maxMapNumber);
CaMap{6,2} = DTauMapDataTitle;
CaMap{6,3} = DTauMapData;



% Create the new variable for Vm-Ca Linked Analysis -----------------------
VmCaLinkedMap = cell(3,3);

VmCaLinkedMap{1,1} = 'Act Linked';
VmCaLinkedMap{2,1} = 'Rep Linked';
VmCaLinkedMap{3,1} = 'Duration Linked';

% Act
actLinkedMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) LB', '(6) UB', ...
    '(7) Data Section Time', ...
    '(8) Data Section Camera 1', '(9) Data Section Camera 2'...
    '(10) Locs Act Camera 1', '(11) Locs Act Camera 2', ...
    '(12) Act Delta (Camera 1 Minus Camera 2) Matrix', ...
    '(13) Ensemble Peaks Number', ...
    '(14) Map User Comment'};
parameterNumber = length( actLinkedMapDataTitle );
actLinkedMapData = cell(1, parameterNumber, maxMapNumber);
VmCaLinkedMap{1,2} = actLinkedMapDataTitle;
VmCaLinkedMap{1,3} = actLinkedMapData;

clear actLinkedMapDataTitle actLinkedMapData

% Rep
repLinkedMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Rep Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', ...
    '(9) Data Section Camera 1', '(10) Data Section Camera 2', ...
    '(11) Locs Rep Camera 1', '(12) Locs Rep Camera 2', ...
    '(13) Rep Delta (Camera 1 Minus Camera 2) Matrix', ...
    '(14) Ensemble Peaks Number', ...
    '(15) Map User Comment'};
parameterNumber = length( repLinkedMapDataTitle );
repLinkedMapData = cell(1, parameterNumber, maxMapNumber);
VmCaLinkedMap{2,2} = repLinkedMapDataTitle;
VmCaLinkedMap{2,3} = repLinkedMapData;
clear repLinkedMapDataTitle repLinkedMapData

% Duration
durationLinkedMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Duration Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', ...
    '(9) Data Section Camera 1', '(10) Data Section Camera 2', ...
    '(11) Locs Act Camera 1', '(12) Locs Act Camera 2', ...
    '(13) Locs Rep Camera 1', '(14) Locs Rep Camera 2', ...
    '(15) Duration Matrix Camera 1', '(16) Duration Matrix Camera 2', ...
    '(17) Duration Delta (Camera 1 Minus Camera 2) Matrix', ...
    '(18) Ensemble Peaks Number', ...
    '(19) Map User Comment'};
parameterNumber = length( durationLinkedMapDataTitle );
durationLinkedMapData = cell(1, parameterNumber, maxMapNumber);
VmCaLinkedMap{3,2} = durationLinkedMapDataTitle;
VmCaLinkedMap{3,3} = durationLinkedMapData;
clear durationMapDataTitle durationMapData

VmCaLinkedMeasurement = { 'Camera 1 Minus Camera 2', VmCaLinkedMap };



% ------------------------------------------------------------- %
oldversionTF = 0; % '0' or ('1') - 'new' or ('old') version

totalSectionNum = 1 + 1;



%% ------------------------------------------------------------- %
% Version Check - Add 'Map User Comment'
sectionID = 1;

% Re-Arrange Variables for Single Camera Files -----------------------
if inputData.camTF == 0 % Single cameras
    
    field = { 'VmMeasurement', 'CaMeasurement' };
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    if TF == 1
        
        if size( inputData.VmMeasurement{1,2}{1,3}, 2 ) < length( actMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{2,3}, 2 ) < length( repMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{3,3}, 2 ) < length( APDMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{4,3}, 2 ) < length( RTMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{5,3}, 2 ) < length( CVMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{1,3}, 2 ) < length( actMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{2,3}, 2 ) < length( repMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{3,3}, 2 ) < length( CaTDMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{4,3}, 2 ) < length( RTMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{5,3}, 2 ) < length( DTMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{6,3}, 2 ) < length( DTauMapDataTitle )
            
            oldversionTF = 1;
            msg = [ 'File migrating from the old version to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
            f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
            
            % (1.1) Vm act map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{1,3}, 2 );
            new_parameterNumber = length( actMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap{1,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{1,3}(:, :, :);
            end
            
            % (1.2) Vm rep map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{2,3}, 2 );
            new_parameterNumber = length( repMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap{2,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{2,3}(:, :, :);
            end
            
            % (1.3) Vm APD map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{3,3}, 2 );
            new_parameterNumber = length( APDMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap{3,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{3,3}(:, :, :);
            end
            
            % (1.4) Vm RT map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{4,3}, 2 );
            new_parameterNumber = length( RTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap{4,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{4,3}(:, :, :);
            end
            
            % (1.5) Vm CV map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{5,3}, 2 );
            new_parameterNumber = length( CVMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap{5,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{5,3}(:, :, :);
            end
            
            
            
            % (2.1) Ca act map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{1,3}, 2 );
            new_parameterNumber = length( actMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap{1,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{1,3}(:, :, :);
            end
            
            % (2.2) Ca rep map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{2,3}, 2 );
            new_parameterNumber = length( repMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap{2,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{2,3}(:, :, :);
            end
            
            % (2.3) Ca CaTD map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{3,3}, 2 );
            new_parameterNumber = length( CaTDMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap{3,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{3,3}(:, :, :);
            end
            
            % (2.4) Ca RT map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{4,3}, 2 );
            new_parameterNumber = length( RTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap{4,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{4,3}(:, :, :);
            end
            
            % (2.5) Ca DT map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{5,3}, 2 );
            new_parameterNumber = length( DTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap{5,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{5,3}(:, :, :);
            end
            
            % (2.6) Ca DTau map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{6,3}, 2 );
            new_parameterNumber = length( DTauMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap{6,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{6,3}(:, :, :);
            end
            
            
            
            VmMeasurement = { 'Camera1', VmMap }; % Camera 1
            CaMeasurement = { 'Camera1', CaMap }; % Camera 1
            save(fileName, 'VmMeasurement', 'CaMeasurement',  '-append');
            inputData = load(fileName); % After saving, refresh inputData
            
            if ishandle(f) == 1
                close(f)
            end
        end
    end
    
    
    
    
    
    
else % Re-Arrange Variables for Dual Camera Files -----------------------
    
    field = { 'VmMeasurement', 'CaMeasurement' };
    TF = prod( isfield( inputData, field ) ); % 1 (or 0) - all exist (or at least one does not exist)
    
    if TF == 1
        
        if size( inputData.VmMeasurement{1,2}{1,3}, 2 ) < length( actMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{2,3}, 2 ) < length( repMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{3,3}, 2 ) < length( APDMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{4,3}, 2 ) < length( RTMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{1,2}{5,3}, 2 ) < length( CVMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{1,3}, 2 ) < length( actMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{2,3}, 2 ) < length( repMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{3,3}, 2 ) < length( CaTDMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{4,3}, 2 ) < length( RTMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{5,3}, 2 ) < length( DTMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{1,2}{6,3}, 2 ) < length( DTauMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{2,2}{1,3}, 2 ) < length( actMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{2,2}{2,3}, 2 ) < length( repMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{2,2}{3,3}, 2 ) < length( APDMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{2,2}{4,3}, 2 ) < length( RTMapDataTitle )  ||  ...
                size( inputData.VmMeasurement{2,2}{5,3}, 2 ) < length( CVMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{2,2}{1,3}, 2 ) < length( actMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{2,2}{2,3}, 2 ) < length( repMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{2,2}{3,3}, 2 ) < length( CaTDMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{2,2}{4,3}, 2 ) < length( RTMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{2,2}{5,3}, 2 ) < length( DTMapDataTitle )  ||  ...
                size( inputData.CaMeasurement{2,2}{6,3}, 2 ) < length( DTauMapDataTitle )
            
            oldversionTF = 1;
            msg = [ 'File migrating from the old version to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
            f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
            
            VmMap_1 = VmMap; % Camera 1
            VmMap_2 = VmMap; % Camera 2
            
            CaMap_1 = CaMap; % Camera 1
            CaMap_2 = CaMap; % Camera 2
            
            
            
            % (1.1 camera 1) Vm act map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{1,3}, 2 );
            new_parameterNumber = length( actMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_1{1,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{1,3}(:, :, :);
            end
            
            % (1.2 camera 1) Vm rep map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{2,3}, 2 );
            new_parameterNumber = length( repMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_1{2,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{2,3}(:, :, :);
            end
            
            % (1.3 camera 1) Vm APD map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{3,3}, 2 );
            new_parameterNumber = length( APDMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_1{3,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{3,3}(:, :, :);
            end
            
            % (1.4 camera 1) Vm RT map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{4,3}, 2 );
            new_parameterNumber = length( RTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_1{4,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{4,3}(:, :, :);
            end
            
            % (1.5 camera 1) Vm CV map
            old_parameterNumber = size( inputData.VmMeasurement{1,2}{5,3}, 2 );
            new_parameterNumber = length( CVMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_1{5,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{1,2}{5,3}(:, :, :);
            end
            
            
            
            % (2.1 camera 1) Ca act map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{1,3}, 2 );
            new_parameterNumber = length( actMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_1{1,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{1,3}(:, :, :);
            end
            
            % (2.2 camera 1) Ca rep map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{2,3}, 2 );
            new_parameterNumber = length( repMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_1{2,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{2,3}(:, :, :);
            end
            
            % (2.3 camera 1) Ca CaTD map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{3,3}, 2 );
            new_parameterNumber = length( CaTDMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_1{3,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{3,3}(:, :, :);
            end
            
            % (2.4 camera 1) Ca RT map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{4,3}, 2 );
            new_parameterNumber = length( RTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_1{4,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{4,3}(:, :, :);
            end
            
            % (2.5 camera 1) Ca DT map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{5,3}, 2 );
            new_parameterNumber = length( DTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_1{5,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{5,3}(:, :, :);
            end
            
            % (2.6 camera 1) Ca DTau map
            old_parameterNumber = size( inputData.CaMeasurement{1,2}{6,3}, 2 );
            new_parameterNumber = length( DTauMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_1{6,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{1,2}{6,3}(:, :, :);
            end
            
            
            
            % (1.1 camera 2) Vm act map
            old_parameterNumber = size( inputData.VmMeasurement{2,2}{1,3}, 2 );
            new_parameterNumber = length( actMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_2{1,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{2,2}{1,3}(:, :, :);
            end
            
            % (1.2 camera 2) Vm rep map
            old_parameterNumber = size( inputData.VmMeasurement{2,2}{2,3}, 2 );
            new_parameterNumber = length( repMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_2{2,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{2,2}{2,3}(:, :, :);
            end
            
            % (1.3 camera 2) Vm APD map
            old_parameterNumber = size( inputData.VmMeasurement{2,2}{3,3}, 2 );
            new_parameterNumber = length( APDMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_2{3,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{2,2}{3,3}(:, :, :);
            end
            
            % (1.4 camera 2) Vm RT map
            old_parameterNumber = size( inputData.VmMeasurement{2,2}{4,3}, 2 );
            new_parameterNumber = length( RTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_2{4,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{2,2}{4,3}(:, :, :);
            end
            
            % (1.5 camera 2) Vm CV map
            old_parameterNumber = size( inputData.VmMeasurement{2,2}{5,3}, 2 );
            new_parameterNumber = length( CVMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                VmMap_2{5,3}(:, 1:old_parameterNumber, :) = inputData.VmMeasurement{2,2}{5,3}(:, :, :);
            end
            
            
            
            % (2.1 camera 2) Ca act map
            old_parameterNumber = size( inputData.CaMeasurement{2,2}{1,3}, 2 );
            new_parameterNumber = length( actMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_2{1,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{2,2}{1,3}(:, :, :);
            end
            
            % (2.2 camera 2) Ca rep map
            old_parameterNumber = size( inputData.CaMeasurement{2,2}{2,3}, 2 );
            new_parameterNumber = length( repMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_2{2,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{2,2}{2,3}(:, :, :);
            end
            
            % (2.3 camera 2) Ca CaTD map
            old_parameterNumber = size( inputData.CaMeasurement{2,2}{3,3}, 2 );
            new_parameterNumber = length( CaTDMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_2{3,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{2,2}{3,3}(:, :, :);
            end
            
            % (2.4 camera 2) Ca RT map
            old_parameterNumber = size( inputData.CaMeasurement{2,2}{4,3}, 2 );
            new_parameterNumber = length( RTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_2{4,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{2,2}{4,3}(:, :, :);
            end
            
            % (2.5 camera 2) Ca DT map
            old_parameterNumber = size( inputData.CaMeasurement{2,2}{5,3}, 2 );
            new_parameterNumber = length( DTMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_2{5,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{2,2}{5,3}(:, :, :);
            end
            
            % (2.6 camera 2) Ca DTau map
            old_parameterNumber = size( inputData.CaMeasurement{2,2}{6,3}, 2 );
            new_parameterNumber = length( DTauMapDataTitle );
            if old_parameterNumber < new_parameterNumber
                CaMap_2{6,3}(:, 1:old_parameterNumber, :) = inputData.CaMeasurement{2,2}{6,3}(:, :, :);
            end
            
            
            
            VmMeasurement = { 'Camera1', VmMap_1; 'Camera2', VmMap_2 }; % Camera 1; Camera 2
            CaMeasurement = { 'Camera1', CaMap_1; 'Camera2', CaMap_2 }; % Camera 1; Camera 2
            save(fileName, 'VmMeasurement', 'CaMeasurement',  '-append');
            inputData = load(fileName);% After saving, refresh inputData
            
            if ishandle(f) == 1
                close(f)
            end
        end
    end
end






%% ------------------------------------------------------------- %
% Version Check - Add Vm-Ca Linked Analysis
sectionID = 2;

%{
if inputData.camTF ~= 0 % Dual cameras
    
    field = { 'VmCaLinkedMeasurement' };
    TF = sum( isfield( inputData, field ) ); % 1 (or 0) - exist (or does not exist)
    
    if TF == 0
        
        oldversionTF = 1;
        msg = [ 'File migrating from the old version to the new one (', num2str(sectionID), ' / ', num2str(totalSectionNum), ')' ];
        f = waitbar(0,msg, 'Name','Processing'); % Display a dynamic waitbar indicating saving process
        
        save(fileName, 'VmCaLinkedMeasurement',  '-append');
        inputData = load(fileName); % After saving, refresh inputData
        
        if ishandle(f) == 1
            close(f)
        end
    end
end
%}





end




