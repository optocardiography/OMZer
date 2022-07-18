
function CMOSconverter(oldFileName)

% Description - Last updated on May.20.2020 - Shubham G, Zexu L
%
% (1.1) CMOSconverter is a function for "Dummy System".
% (1.2) CMOSconverter extracts raw data from SciMedia's
% proprietary file format (i.e., .rsd, .gsd) and saves them to .mat files
% for future use.
%
% (2.1) CMOSconverter(oldFileName) uses ".rsh" files as its input.
% (2.2) There is ONE input to this function, oldFileName, which should
% include (a) file path, (b) file name, and (c) file extension. Also,
% oldFileName should be included in pair of single quotes. For example,
% 'C:\work\my_data.txt' (on Microsoft® Windows® platforms). Or
% '/usr/work/my_data.txt' (on Linux® or Mac platforms).
%
% (3) To read other support information, please open the .m file of
% CMOSconverter function and scroll all the way down.

%%

tic
% profile on % Show function execution time (go to line )


%% Get file path and file name of .rsd or .gsd files

[filepath,name,~] = fileparts(oldFileName); % Get the path name, file name, and extension?~?for the specified file.
newFileName = [filepath, '/', name, '.mat']; % Define the name of .mat file, and its file path.


%% Read file information from .rsh file

% Read ".rsh" file
fileID = fopen([filepath, '/', name, '.rsh'],'r','b'); % Open the specified file in binary (i.e., 'b') for reading (i.e., 'r').

textInfo = textscan( fileID, '%s', 'Delimiter','');
textInfo = textInfo{1}; % 'textInfo' is a column cell. Each row is one text line in the loaded .rsh file

comment = {}; % To store user comment

systemSetupComment = cell(5,2);
systemSetupComment{1,1} = 'Camera Mode (or Number)';
systemSetupComment{2,1} = 'View Mode';
systemSetupComment{3,1} = 'Signal Type';
systemSetupComment{4,1} = 'Camera 1 Signal Type';
systemSetupComment{5,1} = 'Camera 2 Signal Type';
systemSetupComment{1,2} = 'N/A';
systemSetupComment{2,2} = 'N/A';
systemSetupComment{3,2} = 'N/A';
systemSetupComment{4,2} = 'N/A';
systemSetupComment{5,2} = 'N/A';


% Set the initial values for the following 3 variables
acquisitionDate = 'N.A.';
sampleMode = 'N.A.';
shutterDelay = 'N.A.';

for i = 1 : size(textInfo,1)
        
    if contains( textInfo{i}, 'acquisition_date' )
        charIndex = strfind( textInfo{i}, '='); % 'charIndex' the index of the character we are searching for
        acquisitionDate = textInfo{i}( charIndex+1 : end ); % A character
    end
        
    if contains( textInfo{i}, 'page_frames' )  ||  contains( textInfo{i}, 'frame_number' ) % 'PageFrames' + 'sampleTime' can be used to calculate 'acquisition duration'
        charIndex = strfind( textInfo{i}, '=');        
        pageFrames = textInfo{i}( charIndex+1 : end );
        pageFrames( isspace(pageFrames) ) = [];
        pageFrames = str2double( pageFrames );
    end
    
    if contains( textInfo{i}, 'sample_time' )
        charIndex = strfind( textInfo{i}, '=');
        sampleTime = textInfo{i}( charIndex+1 : end-4 );
        sampleTime( isspace(sampleTime) ) = [];
        sampleTime = str2double( sampleTime ); % Unit in 'msec'
    end
    
    if contains( textInfo{i}, 'sample_mode' )
        charIndex = strfind( textInfo{i}, '=');
        sampleMode = textInfo{i}( charIndex+1 : end ); % A character
    end
    
    if contains( textInfo{i}, 'shutter_delay' )
        charIndex = strfind( textInfo{i}, '=');
        shutterDelay = textInfo{i}( charIndex+1 : end ); % A character
    end
    
    if contains( textInfo{i}, 'dual_cam' ) % Check 'single camera' or 'dual cameras'. For single camera, 'dual_cam' can be 0 or 1
        camTF = ~ any( [contains(textInfo{i},'dual_cam=0'), contains(textInfo{i},'dual_cam=1')] ); % True (i.e., dual cameras) if answer is 1. False (i.e., single camera) if answer is 0.        
    end
    
    if contains( textInfo{i}, 'cmnt' )
        charIndex = strfind( textInfo{i}, '=');
        comment = { textInfo{i}( charIndex+1 : end ) }; % A character
        
    else
        comment = { 'No user comment' }; % A character
    end
    
    if contains( textInfo{i}, 'Data-File-List' ) % Count number of ".rsd"
        fileNameList = textInfo( i+1 : end ); % 'fileNameList' is a column cell. 1st row is '.rsm'. The remaining rows are '.rsd' 
        numrsd = count( fileNameList, '.rsd'); % Now 'numrsd' is a column vector
        numrsd = sum( numrsd );
        break
    end
end

fclose all; % Close all open files.


% Check sample mode ( can be "DIF", "DEF", "CDS", "FPN" )
fprintf('\n')
fprintf('File name: %s \n', name)
fprintf('File path: %s \n', filepath)
fprintf('Sample mode: %s \n', sampleMode)


% Optical mapping signal acquisition frequency (Unit: # of frames per sec (i.e., Hz).) and acquisition duration
acqFreq = 1000 / sampleTime; % '1000 (ms) / sampleTime (ms)'

if camTF == 0 % Single camera
    
    systemSetupComment{1,2} = 'Single';
    
    acqDura = (pageFrames * sampleTime) / 1000; % Unit in 'sec'. All the frames are stored in that single camera.
    fprintf('Camera: single \n')
    
else % i.e., TF == 1, dual cameras
    
    systemSetupComment{1,2} = 'Dual';
    
    acqDura = (0.5*pageFrames * sampleTime) / 1000; % Unit in 'sec'. Since there are 2 cameras, half of the total frames are stored in each camera.
    fprintf('Cameras: dual \n')
end

fprintf('The acquisition frequency (for each camera): %d Hz. \n', acqFreq)
fprintf('The acquisition duration (for each camera): %.4f sec. \n', acqDura)


% Add more information into 'comment'
comment(2,1) = { '--------------------------------------------------'  };
comment(3,1) = { ['acquisition_date = ', acquisitionDate] };
comment(4,1) = { ['sample_mode = ', sampleMode] };
comment(5,1) = { ['Acquisition frequency (Hz) = ', num2str(acqFreq)] };
comment(6,1) = { ['shutter_delay = ', shutterDelay] };


%% Convert .rsd format data to .mat file

% Create CMOSdata file path list (i.e., SciMedia's data) so that Matlab can locate the data
dataPathList = cell(numrsd+1,1); % Besides all the .rsd files, there is also one more file, .rsm, that stores data. "dataPathList" contains file path and file name.

dataPathList{1} = [filepath, '/', name,'.rsm'];
for i = 1:numrsd
    dataPathList{i+1} = [filepath, '/', name, '(', num2str(i-1), ')', '.rsd'];
end

% (1) Pre-allocate matrix for storing CMOSdata as .mat file. Pre-allocate analog signal (i.e., pacing signal).

% (2.1) In single camera mode, the ".rsm" only contains 1 frame which is the background image for that camera.
% (2.2) In signle camera mode, the 1st frame in the 1st rsd file ("xxx(0).rsd") is also the background image for that camera. These data will be stored in "bgImage".

% (3.1) In dual cameras mode, the ".rsm" only contains 1 frame which is the background image for camera 1.
% (3.2) In dual cameras mode, the 1st frame in the 1st rsd file ("xxx(0).rsd") is also the background image for camera 1. 
% These data will be stored in "bgImage1". And the 2nd frame in the 1st rsd file ("xxx(0).rsd") is the background image for camera 2. 
% These data will be stored in "bgImage2".

% (4) Each ".rsd" file contains 256 frames. In single camer mode, all these frames will be stored in "cmosData". 
% In dual cameras mode, half of these frames will be stored in "cmosData1" and another half in "cmosData2"
if camTF == 0 % Single camera
    bgImage1 = int32( zeros(100, 100, 1) ); % "bgImage" will be the data matrix (i.e., .mat file) for the background image data for that single camera.
    cmosData1 = int32( zeros(100, 100, numrsd*256) ); % "cmosData" will be the data matrix (i.e., .mat file) for that single camera. But remember, the 1st frame is the background image that will be copied to "bgImage".
    analog1 = int32( zeros(numrsd*256*20, 1) ); % "20" means for each frame, there are 20 dots of analog signal.
    analog2 = int32( zeros(numrsd*256*20, 1) ); % "20" means for each frame, there are 20 dots of analog signal.

else % i.e., TF == 1, dual cameras
    bgImage1 = int32( zeros(100, 100, 1) ); % "bgImage1" will be the data matrix (i.e., .mat file) for the background image data for camera 1.
    cmosData1 = int32( zeros(100, 100, numrsd*256*0.5) ); % "cmosData1" will be the data matrix (i.e., .mat file) for camera 1. Since there are 2 cameras, half of the total frames are stored in each camera. Also the 1st frame is the background image that will be copied to "bgImage1".
    bgImage2 = int32( zeros(100, 100, 1) ); % "bgImage2" will be the data matrix (i.e., .mat file) for the background image data for camera 2.
    cmosData2 = int32( zeros(100, 100, numrsd*256*0.5) ); % "cmosData2" will be the data matrix (i.e., .mat file) for camera 2. Also the 1st frame is the background image that will be copied to "bgImage2".
    analog1 = int32( zeros(numrsd*256*0.5*20, 1) );
    analog2 = int32( zeros(numrsd*256*0.5*20, 1) );
end

% Since "xxx(0).rsd" contains background image information. Here only the
% ".rsd" files will be read.
% Read CMOS data from .rsd files by using the "dataPathList". Then save raw data to .mat file.
if camTF == 0 % Single camera
    
    % Save "cmosData"
    f = waitbar(0,'Ready to start', 'Name','Converting CMOS data'); % Display a dynamic waitbar indicating converting process.
    %%%ZL k = 1; % "k" is the sequence of frame. For each ".rsd" file, there are 256 frames. All those frames are stored in camera 1.
    for i = 2:length(dataPathList) % Open all the ".rsd" files.
        fileID = fopen(dataPathList{i},'r','l'); % 'l' means using little-endian format.
        fileData = fread(fileID,'int16=>int32'); % Convert data to numbers. At this moment, "fileData" is a 1D column.
        fclose all;
        
        fileData = reshape(fileData,128,100,[]); % All the data are now a 128-100-[numebr of frame] 3D matrix.
        fileData = permute(fileData,[2,1,3]); % Switch the 2nd dimension with 1st dimension. Now fileData is a 100-128-[number of frame] 3D matrix.
        k = size(fileData,3); % 'k' is the total number of frame in each .rsd file.
        cmosData1(:,:, k*(i-2)+1 : k*(i-1) ) = fileData(:, 21:120, :);
        analog1(k*20*(i-2)+1 : k*20*(i-1)) = reshape(fileData([1:4:80], 13, :), [],1);
        analog2(k*20*(i-2)+1 : k*20*(i-1)) = reshape(fileData([1:4:80], 15, :), [],1);
        
        if ishandle(f)
            waitbar((i-1)/(length(dataPathList)-1),f, sprintf('%.f percent',((i-1)/(length(dataPathList)-1))*100))
        end
        
    end
    if ishandle(f)
        close(f)
    end

    % Save "bgImage"
    bgImage1 = cmosData1(:,:,1);
    
    % Recreate "cmosData" so that no background image is stored inside
    cmosData1 = cmosData1(:,:,[2:end]);
    
    % Save cmos data time series and analong signal time series
    signalTime = [0 : size(cmosData1,3)-1]'; % Total number of camera frames = total number of time points
    signalTime = (1/acqFreq) *  signalTime; % (1/acqFreq) is the step of each time point. For example, if acqFreq = 1000 Hz, then each time point increase by 1/1000 = 0.001 sec.
    
    analogTime = [0 : length(analog1)-1]'; % Total number of analog signal frames = total number of time points
    analogTime = (1/(20*acqFreq)) * analogTime; % The sampling frequency of analog signal is 20 times that of camera. Therefore, 1/(20*acqFreq) is the step of each time point.
    
    clear fileData oneframe
    
    
    
else % Dual cameras
    
    % Save "cmosData1" and "cmosData2"
    f = waitbar(0,'Ready to start', 'Name','Converting CMOS data'); % Display a dynamic waitbar indicating converting process.
    %     k = 1; % "k" is the sequence of oddframe (or evenframe). For each ".rsd" file, there are 256 frames (i.e., 128 oddframes, 128 evenframes).
    for i = 2:length(dataPathList) % Open all the ".rsd" files.
        fileID = fopen(dataPathList{i},'r','l'); % 'l' means using little-endian format.
        fileData = fread(fileID,'int16=>int32'); % Convert data to numbers.
        fclose all;
        
        fileData = reshape(fileData,128,100,[]); % All the data are now a 128-100-[numebr of frame] 3D matrix.
        fileData = permute(fileData,[2,1,3]); % Switch the 2nd dimension with 1st dimension. Now fileData is a 100-128-[number of frame] 3D matrix.
        k = size(fileData,3)*0.5; % 'k' is the total number of frame for each camera in each .rsd file. "0.5" means half of the 256 frames in one .rsd file are for Camera 1, another half for Camera2.
        cmosData1(:,:, k*(i-2)+1 : k*(i-1) ) = fileData(:, 21:120, [1:2:end]); % In each ".rsd" file, the odd frames are for Camera 1 (i.e., cmosData1). [1,3,5,7,...,253,255]
        cmosData2(:,:, k*(i-2)+1 : k*(i-1) ) = fileData(:, 21:120, [2:2:end]); % In each ".rsd" file, the even frames are for Camera 2 (i.e., cmosData2). [2,4,6,8,...,254,256]
        
        % (1) For dual cameras, odd frames are for camera1 and even frames for camera2.
        % (2.1) The analog signal repeat for camera1 and camera2 per frame.
        % (2.2) The 1st frame and 2nd frame have the same analog signal, the 3rd frame and the 4th frame have the same analog signal ...
        analog1(k*20*(i-2)+1 : k*20*(i-1)) = reshape(fileData([1:4:80], 13, [1:2:end]), [],1);
        analog2(k*20*(i-2)+1 : k*20*(i-1)) = reshape(fileData([1:4:80], 15, [1:2:end]), [],1);
        
        if ishandle(f)
            waitbar((i-1)/(length(dataPathList)-1),f, sprintf('%.f percent',((i-1)/(length(dataPathList)-1))*100))
        end
    end
    if ishandle(f)
        close(f)
    end
    
    % Save "bgImage"
    bgImage1 = cmosData1(:,:,1);
    bgImage2 = cmosData2(:,:,1);
    
    % Recreate "cmosData" so that no background image is stored inside
    cmosData1 = cmosData1(:,:,[2:end]);
    cmosData2 = cmosData2(:,:,[2:end]);
    
    % Save cmos data time series and analong signal time series
    signalTime = [0 : size(cmosData1,3)-1]'; % Total number of camera frames = total number of time points
    signalTime = (1/acqFreq) *  signalTime; % (1/acqFreq) is the step of each time point. For example, if acqFreq = 1000 Hz, then each time point increase by 1/1000 = 0.001 sec.
    
    analogTime = [0 :length(analog1)-1]'; % Total number of analog signal frames = total number of time points
    analogTime = (1/(20*acqFreq)) * analogTime; % The sampling frequency of analog signal is 20 times that of camera. Therefore, 1/(20*acqFreq) is the step of each time point.
    
    
    clear fileData oddframe evenframe
    
end


%% If CDS or FPN mode is used, data will be transferred here to DIF or DEF mode

% % (1) CDS, FPN, DEF and DIF are the "sample_mode" that can be specified in
% % the acquisition software.
% % (2) CDS and FPN are for recording absolute (raw) values, which are not
% % processed.
% % (3) DEF and DIF are for recoding differential values, which are made by
% % subtracting reference value (i.e., background image) from raw value.
%
% modeTF = or(contains(smStr,'DIF'), contains(smStr,'DEF')); % True (i.e., DIF / DEF) if answer is 1. False (i.e., CDS / FPN) if answer is 0.
%
% if modeTF == 0 % CDS / FPN mode
%
%     if camTF == 0 % Single camera
%         cmosData = cmosData - repmat(bgImage,[1 1 size(cmosData,3)]);
%     else % Dual cameras
%         cmosData1 = cmosData1 - repmat(bgImage,[1 1 size(cmosData1,3)]);
%         cmosData2 = cmosData2 - repmat(bgImage,[1 1 size(cmosData2,3)]);
%     end
%
% end
%


%% Rescale "bgImage" and "cmosData" for single camera (or "bgImage1", "bgImage2", "cmosData1", and "cmosData2" for dual cameras)

if camTF == 0 % Single camera
    bgImage1 = double(bgImage1);
    bgImageNom1 = rescale(bgImage1,0,255); % rescale all the values in matrix "bgImage" to the interval [0,255]. "Nom" means normalised data
    bgImageNom1 = round(bgImageNom1);
    
else % Dual cameras
    bgImage1 = double(bgImage1);
    bgImage2 = double(bgImage2);
    bgImageNom1 = rescale(bgImage1,0,255);
    bgImageNom1 = round(bgImageNom1);
    bgImageNom2 = rescale(bgImage2,0,255);
    bgImageNom2 = round(bgImageNom2);
end


%% About analog signal

% Downsample analog signal (by default, analog signal sampling rate is 20
% times the one of camera acquisition rate)
pcl = []; % 'pacing cycle length' (if exists) stored in channel 1 or channel 2


analogTime = downsample(analogTime,20);
analog1 = downsample(analog1,20);
analog2 = downsample(analog2,20);

analogTime = analogTime(1:length(signalTime),1);
analog1 = analog1(1:length(signalTime),1);
analog2 = analog2(1:length(signalTime),1);


% Set analog1 and analog2 be positive value only 
analog1 = abs(analog1);
analog2 = abs(analog2);

analog1 = double(analog1);
analog2 = double(analog2);


% (1) To automatically check if pacing signal exists, fisrt the analog signal
% 'standard deviation threshold' is used.
% (2) The 'standard deviation threshold' is set as 400 by Zexu Lin based on
% the previously recorded analog signal.
if std(analog1) <= 300 % There is no pacing signal in this analog1 channel
    analog1(:) = 0;
else % There might be pacing signal in analog1 channel
    delta = 0.7 * ( max(analog1)-median(analog1) );
    i = logical( analog1 >= ( median(analog1)+delta ) ); % Rest analog signal value so that it only contains '0' and '1' 
    analog1(:) = 0;
    analog1(i) = 1;
end

if std(analog2) <= 400 % There is no pacing signal in this analog2 channel
    analog2(:) = 0;
else % There might be pacing signal in analog2 channel
    delta = 0.7 * ( max(analog2)-median(analog2) );
    i = logical( analog2 >= ( median(analog2)+delta ) ); % Rest analog signal value so that it only contains '0' and '1' 
    analog2(:) = 0;
    analog2(i) = 1;
end


% 'any(...)' checks if there are non-zero elements in array
% returns '0' if all of array is 0, '1' if there is any non-zero element
% (3) To automatically check if pacing signal exists, second the 'regularity 
% of the signal' is checked.
if any(analog1) == 1 % There might be pacing signal in analog1 channel
    derivSignal1 = diff(analog1); % Take derivative of analog1 signal
    peakIndex1 = find(derivSignal1 == 1);
    peakIndexInterval1 = diff(peakIndex1); % Tells how many 'data points' between each peak. The 'time lag' between two neighbouring data points is '(1000 / acqFreq)' msec. 
    
    if range(peakIndexInterval1) <= 5 % Check 'regularity'. If this is the pacing signal, then peak-to-peak distance (i.e., 'data points') should almost be the same. Here we assume the 
        pcl = mean(peakIndexInterval1) * (1000 / acqFreq);       
        pcl = round(pcl);
        fprintf('The pacing cycle length is stored in channel 1: %.f msec. (i.e., %1.f bpm, %.2f Hz) \n\n',pcl, 60*(1000/pcl), 1000/pcl )
        
        % Narrow analog1 pacing spikes (i.e., [0,1,1,0] --> [0,1,0,0])
        pcl_DataPoints = round( pcl / (1000 / acqFreq) );
        scanRange = round( 0.8 * pcl_DataPoints );
        
        for ID = 1 : length(analog1)-2
            
            if ( analog1(ID) == 0 )  &&  ( analog1(ID+1) == 1 )  &&  ( analog1(ID+2) == 1 )
                
                if ID + 2 + scanRange <= length(analog1)
                    
                    analog1(ID + 2  :  ID + 2 + scanRange) = 0;
                    
                elseif ID + 2 <= length(analog1)  &&  ID + 2 + scanRange > length(analog1)
                    
                    analog1(ID + 2  :  end) = 0;
                    break
                end
            end
        end
        
    else 
        analog1(:) = 0;
    end
    
end


if any(analog2) == 1
    derivSignal2 = diff(analog2); % Take derivative of analog2 signal
    peakIndex2 = find(derivSignal2 == 1);
    peakIndexInterval2 = diff(peakIndex2); % Tells how many 'data points' between each peak. The 'time lag' between two neighbouring data points is '(1000 / acqFreq)' msec. 
    
    if range(peakIndexInterval2) <= 5 % Check 'regularity'. If this is the pacing signal, then peak-to-peak distance (i.e., 'data points') should almost be the same.
        pcl = mean(peakIndexInterval2) * (1000 / acqFreq);
        pcl = round(pcl);
        fprintf('The pacing cycle length is stored in channel 2: %.f msec. (i.e., %1.f bpm, %.2f Hz) \n\n',pcl, 60*(1000/pcl), 1000/pcl )
        
        % Narrow analog2 pacing spikes (i.e., [0,1,1,0] --> [0,1,0,0])
        pcl_DataPoints = round( pcl / (1000 / acqFreq) );
        scanRange = round( 0.8 * pcl_DataPoints );
        
        for ID = 1 : length(analog2)-2
            
            if ( analog2(ID) == 0 )  &&  ( analog2(ID+1) == 1 )  &&  ( analog2(ID+2) == 1 )
                
                if ID + 2 + scanRange <= length(analog2)
                    
                    analog2(ID + 2  :  ID + 2 + scanRange) = 0;
                    
                elseif ID + 2 <= length(analog2)  &&  ID + 2 + scanRange > length(analog2)
                    
                    analog2(ID + 2  :  end) = 0;
                    break
                end
            end
        end
        
    else 
        analog2(:) = 0;
    end
    
end


if any(analog1) ~= 1 && any(analog2) ~= 1
    fprintf('There is no pacing signal \n\n');
end


%% Further specify cmosData

if camTF == 0 % Single camera
    cmosData1 = double(cmosData1);
    cmosData1Raw = cmosData1; % 'cmosData1Raw' is the "un-filtered"-"mask-free" data for camera 1
    userMaskMatrix_cam1 = []; % 'userMaskMatrix_cam1' is the user mask for camera 1
    
else % Dual camera
    cmosData1 = double(cmosData1);
    cmosData2 = double(cmosData2);
    cmosData1Raw = cmosData1; % 'cmosData1Raw' is the "un-filtered"-"mask-free" data for camera 1
    userMaskMatrix_cam1 = []; % 'userMaskMatrix_cam1' is the user mask for camera 1
    cmosData2Raw = cmosData2; % 'cmosData2Raw' is the un-filtered data for camera 2
    userMaskMatrix_cam2 = []; % 'userMaskMatrix_cam2' is the user mask for camera 2
end


%% Save CMOS data to .mat file

camSet = {'Single (camTF=0)'; 'Dual (camTF=1)'}; % "camSet" means camera setting. Index for 'Single (camTF=0)' is 1, and that for 'Dual (camTF=1)' is 2

fileInfo = cell(18,1); % File information
fileInfo{1,1} = ['Camera: ', camSet{camTF+1}]; % camTF+1 can be (0+1)=1 or (1+1)=2.
fileInfo{2,1} = ['Sampling mode: ', sampleMode];
fileInfo{3,1} = ['Acquisition frequency per camera: ', num2str(acqFreq), ' Hz'];
fileInfo{4,1} = ['Acquisition duration per camera: ', num2str(acqDura), ' sec'];

if (any(analog1) == 1)
    fileInfo{5,1} = ['Channel 1 pacing cycle length: ', num2str(pcl), ' msec (i.e., ', num2str(  round(60*(1000/pcl))  ), ' bpm, ', num2str(round(1000/pcl,2)) ' Hz)'];
elseif (any(analog2) == 1)
    fileInfo{5,1} = ['Channel 2 pacing cycle length: ', num2str(pcl), ' msec (i.e., ', num2str(  round(60*(1000/pcl))  ), ' bpm, ', num2str(round(1000/pcl,2)) ' Hz)'];
end

fileInfo{6,1} = 'acqFreq - acquisition frequency (Hz).';
fileInfo{7,1} = 'analog1, analog2 - pacing spike.';
fileInfo{8,1} = 'analogTime - the time vector for pacing spike.';
fileInfo{9,1} = 'bgImage1, bgImage2 - the background image for camera 1 and camera 2.';
fileInfo{10,1} = 'bgImageNom1, bgImageNom2 - the normalised background image (i.e., pixel intensity ranges in [0,255]).';
fileInfo{11,1} = 'camTF - used by ULTIMA system to decide single or dual camera mode.';

fileInfo{12,1} = 'cmosData1Raw, cmosData2Raw - the original "unfiltered, mask-free" data for camera 1 and camera 2.';
fileInfo{13,1} = 'cmosData1, cmosData2 - the "filtered" (if conditioning applied before) but "mask-free" data for camera 1 and camera 2.';

fileInfo{14,1} = 'signalTime - the time vector for cmosData1 and cmosData2.';
fileInfo{15,1} = 'comment - the note user types in Dummy system.';
fileInfo{16,1} = 'pcl - pacing cycle length (ms).';
fileInfo{17,1} = 'userMaskMatrix_cam1, userMaskMatrix_cam2 - the user-defined mask for camera 1 and camera 2.';
fileInfo{18,1} = 'signalConditioningInfo - the user-defined signal conditioning parameters for cmosData1 and cmosData2.';



%%%% Store signal conditioning information
signalConditioningInfo = {}; % To store user defined signal conditioning 



maxFileNum = 10;

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
actMapData = cell(1, parameterNumber, maxFileNum);
VmMap{1,2} = actMapDataTitle;
VmMap{1,3} = actMapData;
clear ActMapDataTitle ActMapData

repMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Rep Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', '(9) Data Section', ...
    '(10) Locs Rep', '(11) Rep Matrix', ...
    '(12) Ensemble Peaks Number', ...
    '(13) Map User Comment'};
parameterNumber = length( repMapDataTitle );
repMapData = cell(1, parameterNumber, maxFileNum);
VmMap{2,2} = repMapDataTitle;
VmMap{2,3} = repMapData;
clear RepMapDataTitle RepMapData

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
APDMapData = cell(1, parameterNumber, maxFileNum);
VmMap{3,2} = APDMapDataTitle;
VmMap{3,3} = APDMapData;
clear APDMapDataTitle APDMapData

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
RTMapData = cell(1, parameterNumber, maxFileNum);
VmMap{4,2} = RTMapDataTitle;
VmMap{4,3} = RTMapData;
clear RTMapDataTitle RTMapData

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
CVMapData = cell(1, parameterNumber, maxFileNum);
VmMap{5,2} = CVMapDataTitle;
VmMap{5,3} = CVMapData;
clear CVMapDataTitle CVMapData



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
actMapData = cell(1, parameterNumber, maxFileNum);
CaMap{1,2} = actMapDataTitle;
CaMap{1,3} = actMapData;
clear actMapDataTitle actMapData

repMapDataTitle = { '(1) Win Start Index', '(2) Win End Index', ...
    '(3) Area Mode', '(4) AP Mode', ...
    '(5) Rep Level', ...
    '(6) LB', '(7) UB', ...
    '(8) Data Section Time', '(9) Data Section', ...
    '(10) Locs Rep', '(11) Rep Matrix', ...
    '(12) Ensemble Peaks Number', ...
    '(13) Map User Comment'};
parameterNumber = length( repMapDataTitle );
repMapData = cell(1, parameterNumber, maxFileNum);
CaMap{2,2} = repMapDataTitle;
CaMap{2,3} = repMapData;
clear repMapDataTitle repMapData

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
CaTDMapData = cell(1, parameterNumber, maxFileNum);
CaMap{3,2} = CaTDMapDataTitle;
CaMap{3,3} = CaTDMapData;
clear CaTDMapDataTitle CaTDMapData

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
RTMapData = cell(1, parameterNumber, maxFileNum);
CaMap{4,2} = RTMapDataTitle;
CaMap{4,3} = RTMapData;
clear RTMapDataTitle RTMapData

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
DTMapData = cell(1, parameterNumber, maxFileNum);
CaMap{5,2} = DTMapDataTitle;
CaMap{5,3} = DTMapData;
clear DTMapDataTitle DTMapData

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
DTauMapData = cell(1, parameterNumber, maxFileNum);
CaMap{6,2} = DTauMapDataTitle;
CaMap{6,3} = DTauMapData;
clear DTauMapDataTitle DTauMapData



msg = 'Save data to .mat file';
f = waitbar(0,'Saving', 'Name',msg); % Display a dynamic waitbar indicating saving process.

% Save the file -----------------------

if camTF == 0 % Single camera
    
    VmMeasurement = { 'Camera1', VmMap }; % Camera 1
    CaMeasurement = { 'Camera1', CaMap }; % Camera 1
    
    save(newFileName, 'cmosData1Raw', 'cmosData1', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'userMaskMatrix_cam1', ...
        'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment', 'systemSetupComment', ...
        'VmMeasurement', 'CaMeasurement');
    
    
else % Dual cameras
    
    VmMeasurement = { 'Camera1', VmMap; 'Camera2', VmMap }; % Camera 1; Camera 2
    CaMeasurement = { 'Camera1', CaMap; 'Camera2', CaMap }; % Camera 1; Camera 2
    
    save(newFileName, 'cmosData1Raw', 'cmosData1', 'cmosData2Raw', 'cmosData2', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'bgImage2', 'bgImageNom2', 'userMaskMatrix_cam1', 'userMaskMatrix_cam2', ...
        'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment', 'systemSetupComment', ...
        'VmMeasurement', 'CaMeasurement');
end



if ishandle(f) == 1
    close(f)
end

% profile viewer % Show function execution time

fprintf('CMOSconverter time consumed: %.2f sec\n\n', toc)

end




%% Temporary

%{
% waitbar - Create or update wait bar dialog box
% https://www.mathworks.com/help/matlab/ref/waitbar.html

% uiprogressdlg - Create progress dialog box
% https://www.mathworks.com/help/matlab/ref/uiprogressdlg.html

% appdesigner
% https://www.mathworks.com/help/matlab/ref/appdesigner.html

% Migrating GUIDE Apps to App Designer
% https://www.mathworks.com/help/matlab/creating_guis/differences-between-app-designer-and-guide.html

% Displaying Progress Status of Long Running Script, Part 1: fprintf
% https://www.mathworks.com/videos/displaying-progress-status-of-long-running-script-part-1-fprintf-100671.html

% Way to tell % complete of script
% https://www.mathworks.com/matlabcentral/answers/13862-way-to-tell-complete-of-script
%}

% Contrast Adjustment
% https://www.mathworks.com/help/images/contrast-adjustment.html
% https://www.mathworks.com/help/images/contrast-enhancement-techniques.html

% histcounts - Histogram bin counts
% https://www.mathworks.com/help/matlab/ref/histcounts.html?searchHighlight=histcounts&s_tid=doc_srchtitle

% histogram - histogram plot
% https://www.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.histogram.html?searchHighlight=histogram&s_tid=doc_srchtitle


%% Support Information


%{
------ MATLAB BUILT-IN FUNCTION ------

fopen - Open file, or obtain information about open files
https://www.mathworks.com/help/matlab/ref/fopen.html?searchHighlight=fopen&s_tid=doc_srchtitle#btrnibn-1-machinefmt

fclose - Close one or all open files
https://www.mathworks.com/help/matlab/ref/fclose.html?searchHighlight=fclose&s_tid=doc_srchtitle

fgetl - Read line from file, removing newline characters
https://www.mathworks.com/help/matlab/ref/fgetl.html

fgets - Read line from file, keeping newline characters
https://www.mathworks.com/help/matlab/ref/fgets.html

feof - test for end of line
https://www.mathworks.com/help/matlab/ref/feof.html

frewind - Move file position indicator to beginning of open file
https://www.mathworks.com/help/matlab/ref/frewind.html

fseek - Move to specified position in file
https://www.mathworks.com/help/matlab/ref/fseek.html

ftell - Current position
https://www.mathworks.com/help/matlab/ref/ftell.html

fread - Read data from binary file
https://www.mathworks.com/help/matlab/ref/fread.html

fscanf - Read data from text file
https://www.mathworks.com/help/matlab/ref/fscanf.html

fullfile - Build full file name from parts
https://www.mathworks.com/help/matlab/ref/fullfile.html

File Name Construction
https://www.mathworks.com/help/matlab/file-name-construction.html

fileparts - Get parts of file name
https://www.mathworks.com/help/matlab/ref/fileparts.html#d117e374675

clock - Current date and time as date vector
https://www.mathworks.com/help/matlab/ref/clock.html

pause - Stop MATLAB execution temporarily
https://www.mathworks.com/help/matlab/ref/pause.html

strfind - Find strings within other strings
https://www.mathworks.com/help/matlab/ref/strfind.html?s_tid=doc_ta

count - https://www.mathworks.com/help/matlab/ref/count.html#bu55fcg-pattern
Count occurrences of pattern in strings


contains - Determine if pattern is in strings
https://www.mathworks.com/help/matlab/ref/contains.html

repmat - Repeat copies of array
https://www.mathworks.com/help/matlab/ref/repmat.html#btzx_46-1

rescale - scale range of array elements
https://www.mathworks.com/help/matlab/ref/rescale.html

mat2gray - Convert matrix to grayscale image
https://www.mathworks.com/help/images/ref/mat2gray.html#d117e204837

caxis - Set colormap limits
https://www.mathworks.com/help/matlab/ref/caxis.html

%}



%{
------ Plot image ------
imread
imshow
image
imfinfo
imwrite
ind2rgb
mat2gray

newplot - Determine where to draw graphics objects
https://www.mathworks.com/help/matlab/ref/newplot.html

%}


%{
------ Movie ------

getframe - Capture axes or figure as movie frame
https://www.mathworks.com/help/matlab/ref/getframe.html

movie - play recorded movie frame
https://www.mathworks.com/help/matlab/ref/movie.html

%}

%{
------ Normalisation and Standardization ------

Statistics Explanation
https://www.statisticshowto.datasciencecentral.com/normalized/

rescale - scale range of array elements
https://www.mathworks.com/help/matlab/ref/rescale.html

normalize - Normalize data
https://www.mathworks.com/help/matlab/ref/double.normalize.html

bounds - Smallest and largest elements
https://www.mathworks.com/help/matlab/ref/bounds.html
%}



%{
------ MiCAM System Data Format ------

(1) Under "Dif" mode, the MiCAM system will store data in three kinds of
files: .rsh, .rsm, .rsd. The ".rsh" file stores important sampling information
such as sampling rate (named as "sample_time"), number of frames (named as
"page_frame"), "sample_mode", number of cameras (named as "duak_cam"),
"Data-File-List", and "acquisition_date".

(2) Signal recording time = "sample_time" × ""page_frame"".

(3) The function "CMOSconverter" uses ".rsh" file as one of its two input,
and converts (i.e., outputs)  .rsd files to a .mat file.
%}


%{
------ About Fourier Transform ------

https://www.mathworks.com/help/matlab/ref/fft.html

https://www.mathworks.com/help/matlab/math/fourier-transforms.html

https://www.mathworks.com/help/matlab/examples/using-fft.html

https://www.mathworks.com/help/wavelet/ref/wdenoise.html?searchHighlight=wdenoise&s_tid=doc_srchtitle

Power Spectral Density
(1) http://web.eecs.utk.edu/~roberts/ECE504/PresentationSlides/PowerSpectralDensity.pdf
(2) https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-011-introduction-to-communication-control-and-signal-processing-spring-2010/readings/MIT6_011S10_chap10.pdf




%}