function GSDconverter(path, fileCell)
% fileCell is a 1x3 cell containing: [{displayName}, {camera 1 file},
% {camera2 file}]. If single camera then {camera2 file} is empty
tic

oldFileName = fileCell{2};
oldFileName2 = fileCell{3};
filepath = path;
%% Get file path and file name of .rsd or .gsd files
[~,name,~] = fileparts(oldFileName); % Get the path name, file name, and extension for the specified file.
if isempty(oldFileName2) % Single camera
    newFileName = [filepath, '/', name, '.mat']; % Define the name of .mat file, and its file path.
    camTF = 0;
else % Dual camera
    [~,actualName,~] = fileparts(fileCell{1});
    newFileName = [filepath, '/', actualName, '.mat']; % Use display name for .mat filename
    camTF = 1;
end
%% Read file information from .gsh file

% Read ".gsh" file
fileID = fopen([filepath, '/', name, '.gsh'],'r'); % Open the specified file for reading (i.e., 'r'). Opening camera 1's .gsh file.

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

sampleMode = 'DIF'; % GSD is always saved as differential data (DIF mode)
comment = {'No user comments in this file!'};


% Check version of '.gsd' - whether it is acquired using MiCAM (0) or BV Workbench (1).
% BV Workbench uses colon ':', MiCAM uses equal sign '='.
% Example: 'Frame Size = 10000' versus 'Number of frames : 10000'

acqVersion = ~contains(textInfo{1}, 'DataName'); % MiCAM generated file's first line has 'DataName'

for i = 1 : size(textInfo,1) % Iterate through each line in '.gsh' header file
    if acqVersion == 0 % Reading through MiCAM generated file
        
        charIndex = strfind( textInfo{i}, '='); % 'charIndex' the index of the character we are searching for
        
        if contains( textInfo{i}, 'AcquisitionDate' )
            acquisitionDate = strtrim(textInfo{i}( charIndex+1 : end )); % A character
        end
        
        if contains( textInfo{i}, 'frame_number' ) % 'PageFrames' + 'sampleTime' can be used to calculate 'acquisition duration'
            pageFrames = strtrim(textInfo{i}( charIndex+1 : end ));
            pageFrames = str2double( pageFrames );
        end
        
        if contains( textInfo{i}, 'sample_time' )
            sampleTime = strtrim(textInfo{i}( charIndex+1 : end-4 ));
            sampleTime = str2double( sampleTime ); % Unit in 'msec'
            acqFreq = 1000 / sampleTime; % Convert to Hz
        end
        
        %% - GSD files are always saved in DIF mode
        %         if contains( textInfo{i}, 'sampling_mode' )
        %             sampleMode = strtrim(textInfo{i}( charIndex+1 : end )); % A character
        %         end
        
        if contains( textInfo{i}, 'shutter_dly' )
            shutterDelay = strtrim(textInfo{i}( charIndex+1 : end )); % A character
        end
        
        %%     %%%%%%% TODO - DOUBLE CHECK THIS
%         if contains( textInfo{i}, 'dual_cam' ) % Check 'single camera' or 'dual cameras'. For single camera, 'dual_cam' can be 0 or 1
%             camTF = ~ any( [contains(textInfo{i},'dual_cam=0'), contains(textInfo{i},'dual_cam=1')] ); % True (i.e., dual cameras) if answer is 1. False (i.e., single camera) if answer is 0.
%         end
        
    else % Reading through BV Workbench generated file
        charIndex = strfind( textInfo{i}, ':'); % 'charIndex' the index of the character we are searching for
        
        if contains( textInfo{i}, 'Date created' )
            acquisitionDate = strtrim(textInfo{i}( charIndex+1 : end )); % A character
        end
        
        if contains( textInfo{i}, 'Number of frames' ) % 'PageFrames' + 'sampleTime' can be used to calculate 'acquisition duration'
            pageFrames = strtrim(textInfo{i}( charIndex+1 : end ));
            pageFrames = str2double( pageFrames );
        end
        
        if contains( textInfo{i}, 'Frame rate (Hz)' ) % Frequency in Hz
            acqFreq = strtrim(textInfo{i}( charIndex+1 : end ));
            acqFreq = str2double( acqFreq ); % Unit in Hz
            sampleTime = 1000 / acqFreq; % Convert to msec
        end
        %% - GSD files are always saved in DIF mode
        %         if contains( textInfo{i}, 'sampling_mode' )
        %             sampleMode = strtrim(textInfo{i}( charIndex+1 : end )); % A character
        %         end
    end
end

fclose all; % Close all open files.

%% Find .txt file if file is from BV Workbench
% The text file includes useful information like how many cameras were used and shutter delay information

% BV Workbench appends the name of the camera and whether it is camera 1 or 2 at the end of the GSH/GSD file name.
% This is usually in the form "[actual filename]_CameraName (IF[#]-CAM[#]).gsh" (without the '[' and ']')
% The text file has that information removed, so the actual filename is first determined and then the text file is opened.
if acqVersion == 1 % BV Workbench-generated file
    actualFilename = split(name, '_'); % Split filename into substrings separated by '_'.
    actualFilename = join(actualFilename(1:end-1),'_'); % If any '_' are in the actual filename, keep them.
    actualFilename = actualFilename{1}; % Above line resulted in 1x1 cell array, so get the string from that.
    
    txtFID = fopen([filepath, '/', actualFilename, '.txt'],'r'); % Open the text file
    
    if txtFID == -1 % Text file is not in the same directory, alert the user
        %% %%%%%%% TODO - ALERT USER
        
        msg = 'Please include the corresponding .txt file!';
        warning( msg );
        fprintf('\n');
        
        return;
    else
        textInfo = textscan( txtFID, '%s', 'Delimiter','');
        textInfo = textInfo{1}; % 'textInfo' is a column cell. Each row is one text line in the loaded .rsh file
        
        for i = 1 : size(textInfo,1)
            if contains( textInfo{i}, 'Active cameras' )
                charIndex = strfind( textInfo{i}, ':'); % 'charIndex' the index of the character we are searching for
                numCams = str2num(strtrim(textInfo{i}( charIndex+1 : end )));
                camTF = numCams ~= 1; % If there is 1 active camera, 'camTF' is 0 because the expression (... ~= 1) is false
            end
            
            if contains( textInfo{i}, 'Shutter delay' )
                charIndex = strfind( textInfo{i}, ':'); % 'charIndex' the index of the character we are searching for
                shutterDelay = strtrim(textInfo{i}( charIndex+1 : end )); % In ms
            end
            
            % User comments are stored in the text file in the following structure:
            %             ...
            %     --------------------
            %     Comment
            %     --------------------
            %     [Some user comment, line does not exist if no comment is there]
            %     --------------------
            %     Tags
            %             ...
            
            if contains( textInfo{i}, 'Comment' ) % Find section for comments
                commentStart = i;
            end
            
            if contains( textInfo{i}, 'Tags' ) % Next section is for tags, so comments are between previous index and this index
                commentEnd = i;
            end
        end
        
        if commentEnd ~= commentStart + 3 % Means there is some user comments
            comment = textInfo(commentStart+2:commentEnd-2);
        end
    end
    
    
end

fclose all; % Close all open files.

fprintf('\n')
fprintf('File name: %s \n', name)
fprintf('File path: %s \n', filepath)
fprintf('Sample mode: %s \n', sampleMode)

acqDura = (pageFrames * sampleTime) / 1000; % Unit in 'sec'. All the frames are stored in that single camera.

fprintf('The acquisition frequency (for each camera): %d Hz. \n', acqFreq)
fprintf('The acquisition duration (for each camera): %.4f sec. \n', acqDura)

% Add more information into 'comment'
n = size(comment, 1); % Depends on how many lines of user comments there are
comment(n+1,1) = { '--------------------------------------------------'  };
comment(n+2,1) = { ['acquisition_date = ', acquisitionDate] };
comment(n+3,1) = { ['sample_mode = ', sampleMode] };
comment(n+4,1) = { ['Acquisition frequency (Hz) = ', num2str(acqFreq)] };
comment(n+5,1) = { ['shutter_delay = ', shutterDelay] };

%% Convert .gsd format data to .mat file from first camera

% In binary numbers, the most-significant bit occurs at the beginning of
% the number. '10110' -> '1' is most-significant

% Assume that the memory layout of the file is this:
% byte number | number
% --------------------
%     35      |   1
%     37      |   0
%     39      |   1
%     41      |   0

% Big-endian format means to read the file such that the most significant
% bit occurs at the earliest memory address. In this case, the resulting
% binary number would be '1010'. Little-endian format means to read the
% file such that the least significant bit occurs at the earliest memory
% address. In this case, the resulting
% binary number would be '0101'.

% GSD files use little-endian format

fileID = fopen([filepath, '/', name, '.gsd'],'r', 'l'); % Open the specified file in little-endian (i.e., 'l') for reading (i.e., 'r').

% First 256 bytes is reserved header info, so we can skip.
% fseek(fileID, # bytes to skip from origin, definition of what origin is)
reserved_header = fseek(fileID, 256, 'bof'); % 'bof' stands for 'beginning of file'

% Data Format information (FORM_INFO)
numXPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of pixels on x-axis
numYPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of pixels on y-axis
numXSkippedPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of skipped pixels (columns) on x-axis from left
numYSkippedPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of skipped pixels (rows) on x-axis from top
numXActualPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of actual pixels on x-axis
numYActualPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of actual pixels on y-axis
numFramesGSD = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of frames (should be same as in '.gsh' file)
extra_info = fseek(fileID, 284, 'bof'); % Skip to byte 284 from beginning of file
samplingRateGSD = fread(fileID, 1, 'float'); % Reading 1 value of type 'float; -> sampling rate in msec (should be same as in '.gsh' file)

extra_info = fseek(fileID, 328, 'bof'); % Skip to byte 328 from beginning of file

% Input signal info (AUX_INFO)
numAnalogChannels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of analog channels
analogSamplingMultiplier = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> Analog channel samples this many times faster than data channel's sampling rate
extra_info = fseek(fileID, 338, 'bof'); % Skip to byte 338 from beginning of file
numAnalogFrames = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of frames (should be same as in '.gsh' file)

extra_info = fseek(fileID, 972, 'bof'); % Skip (point) to byte 972 from beginning of file

% Get background image and data
cmosData1 = fread(fileID, numXPixels*numYPixels*(pageFrames+1), 'int16'); % +1 to include the background image
cmosData1 = reshape(cmosData1, numXPixels, numYPixels, pageFrames+1); % Note xPixels are in row index, this is because values are read column by column
cmosData1 = cmosData1(numXSkippedPixels+1:numXSkippedPixels + numXActualPixels, numYSkippedPixels+1:numYSkippedPixels + numYActualPixels, :); % Take out skipped pixels
cmosData1 = permute(cmosData1, [2,1,3]); % X represents columns, so need to rotate 90 degrees clockwise (swap x and y indices)

% Separate background image from data
bgImage1 = cmosData1(:,:,1);
cmosData1 = cmosData1(:,:,2:end);

% Get data in analog channels
analogData = fread(fileID, numAnalogChannels*numAnalogFrames*analogSamplingMultiplier, 'int16');

analogData = reshape(analogData, numAnalogFrames*analogSamplingMultiplier, []); % Each column is a separate analog channel

% Save cmos data time series and analong signal time series
signalTime = [0 : size(cmosData1,3)-1]'; % Total number of camera frames = total number of time points
signalTime = (1/acqFreq) *  signalTime; % (1/acqFreq) is the step of each time point. For example, if acqFreq = 1000 Hz, then each time point increase by 1/1000 = 0.001 sec.

analogTime = [0 :size(analogData,1)-1]'; % Total number of analog signal frames = total number of time points
analogTime = (1/(analogSamplingMultiplier*acqFreq)) * analogTime; % The sampling frequency of analog signal is 'nRate' times that of camera. Therefore, 1/(nRate*acqFreq) is the step of each time point.

%% Rescale "bgImage1" for single camera
bgImageNom1 = rescale(bgImage1,0,255); % rescale all the values in matrix "bgImage" to the interval [0,1]. "Nom" means normalised data
bgImageNom1 = round(bgImageNom1);


%% Downsample analog signals to match data sampling

%analogDataDownSampled = nan(numAnalogChannels, size(cmosData1,3)); % Create new variable for storing downsampled analog signals

pcl = []; % 'pacing cycle length' (if exists) stored in channel 1 or channel 2
analogTime = downsample(analogTime, analogSamplingMultiplier);
analogData = downsample(analogData, analogSamplingMultiplier); % Downsamples by treating each column as separate signal

% Positive values only
analogData = abs(analogData);

% (1) To automatically check if pacing signal exists, fisrt the analog signal
% 'standard deviation threshold' is used.
% (2) The 'standard deviation threshold' is set as 400 by Zexu Lin based on
% the previously recorded analog signal.
analog1 = zeros(size(analogData,1), 1);
analog2 = zeros(size(analogData,1), 1);

for i = 1 : size(analogData, 2) % Go through each analog channel
    
    outlierLocs = find( isoutlier( std (analogData, 0, 1) ) == 1 );
    
    if std( analogData(:, i) ) > 150  &&  length( outlierLocs ) == 1  &&  outlierLocs == i % 400 % There might be pacing signal in channel, assume only one outlier
        
        % Check direction of spike. If downward then it needs to be flipped
        % to be upward. This is done by checking where the median is in
        % respect to the max and min values. If median is closer to max,
        % then spike is downward, otherwise spike is upward.
        isDownward = abs(max(analogData(:, i))-median(analogData(:, i))) < abs(min(analogData(:, i))-median(analogData(:, i)));
        
        if isDownward == 1
            aData = -analogData(:,i) - min(-analogData(:,i));
        end
        
        delta = 0.7 * ( max(aData)-median(aData) );
        j = logical( aData >= ( median(aData)+delta ) ); % Rest analog signal value so that it only contains '0' and '1'
        analog1(j) = 1;
        
        
        derivSignal1 = diff(analog1); % Take derivative of analog1 signal
        peakIndex1 = find(derivSignal1 == 1);
        peakIndexInterval1 = diff(peakIndex1); % Tells how many 'data points' between each peak. The 'time lag' between two neighbouring data points is '(1000 / acqFreq)' msec.
        
        if range(peakIndexInterval1) <= 5 % Check 'regularity'. If this is the pacing signal, then peak-to-peak distance (i.e., 'data points') should almost be the same. Here we assume the
            
            pcl = mean(peakIndexInterval1) * (1000 / acqFreq);
            pcl = round(pcl);
            
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
            
            fprintf('The pacing cycle length is stored in channel %d: %.f msec. (i.e., %1.f bpm, %.2f Hz) \n\n',i,pcl, 60*(1000/pcl), 1000/pcl )
        
            
        else
            analog1 = zeros(size(analogData,1), 1);
        
        end
        
        break; % Assuming only one channel will have pacing signal, every other channel is noise
    end
    
end

if any(analog1) ~= 1 && any(analog2) ~= 1
    fprintf('There is no pacing signal \n\n');
end


%% Further specify cmosData (single camera)

cmosData1 = double(cmosData1);
cmosData1Raw = cmosData1; % 'cmosData1Raw' is the "un-filtered"-"mask-free" data for camera 1
userMaskMatrix_cam1 = []; % 'userMaskMatrix_cam1' is the user mask for camera 1

%% Get data from second camera if it exists
if camTF == 1
    [~,name,~] = fileparts(oldFileName2); % Get the path name, file name, and extension for the specified file.
    fileID = fopen([filepath, '/', name, '.gsd'],'r', 'l'); % Open the specified file in little-endian (i.e., 'l') for reading (i.e., 'r').
    
    % First 256 bytes is reserved header info, so we can skip.
    % fseek(fileID, # bytes to skip from origin, definition of what origin is)
    reserved_header = fseek(fileID, 256, 'bof'); % 'bof' stands for 'beginning of file'
    
    % Data Format information (FORM_INFO)
    numXPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of pixels on x-axis
    numYPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of pixels on y-axis
    numXSkippedPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of skipped pixels (columns) on x-axis from left
    numYSkippedPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of skipped pixels (rows) on x-axis from top
    numXActualPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of actual pixels on x-axis
    numYActualPixels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of actual pixels on y-axis
    numFramesGSD = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of frames (should be same as in '.gsh' file)
    extra_info = fseek(fileID, 284, 'bof'); % Skip to byte 284 from beginning of file
    samplingRateGSD = fread(fileID, 1, 'float'); % Reading 1 value of type 'float; -> sampling rate in msec (should be same as in '.gsh' file)
    
    extra_info = fseek(fileID, 328, 'bof'); % Skip to byte 328 from beginning of file
    
    % Input signal info (AUX_INFO)
    numAnalogChannels = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of analog channels
    analogSamplingMultiplier = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> Analog channel samples this many times faster than data channel's sampling rate
    extra_info = fseek(fileID, 338, 'bof'); % Skip to byte 338 from beginning of file
    numAnalogFrames = fread(fileID, 1, 'short'); % Reading 1 value of type 'short' -> number of frames (should be same as in '.gsh' file)
    
    extra_info = fseek(fileID, 972, 'bof'); % Skip (point) to byte 972 from beginning of file
    
    % Get background image and data
    cmosData2 = fread(fileID, numXPixels*numYPixels*(pageFrames+1), 'int16'); % +1 to include the background image
    cmosData2 = reshape(cmosData2, numXPixels, numYPixels, pageFrames+1); % Note xPixels are in row index, this is because values are read column by column
    cmosData2 = cmosData2(numXSkippedPixels+1:numXSkippedPixels + numXActualPixels, numYSkippedPixels+1:numYSkippedPixels + numYActualPixels, :); % Take out skipped pixels
    cmosData2 = permute(cmosData2, [2,1,3]); % X represents columns, so need to rotate 90 degrees clockwise (swap x and y indices)
    
    % Separate background image from data
    bgImage2 = cmosData2(:,:,1);
    cmosData2 = cmosData2(:,:,2:end);
    
    % Rescale "bgImage2" for second camera
    bgImage2 = double(bgImage2);
    bgImageNom2 = rescale(bgImage2,0,255);
    bgImageNom2 = round(bgImageNom2);
    
    % Further specify cmosData (second camera)
    cmosData2 = double(cmosData2);
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
fileInfo{10,1} = 'bgImageNom1, bgImageNom2 - the normalised background image (i.e., pixel intensity ranges in [0,1]).';
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



% Important: isempty( struct([]) ) = 1
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
    '(7) Pseudo Data Time', '(8) Data Section', ...
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
    '(8) Pseudo Data Time', '(9) Data Section', ...
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
    '(8) Pseudo Data Time', '(9) Data Section', ...
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
    '(9) Pseudo Data Time', '(10) Data Section', ...
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
    '(16) Pseudo Data Time', '(17) Data Section', ...
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
            '(7) Pseudo Data Time', '(8) Data Section', ...
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
    '(8) Pseudo Data Time', '(9) Data Section', ...
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
    '(8) Pseudo Data Time', '(9) Data Section', ...
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
    '(9) Pseudo Data Time', '(10) Data Section', ...
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
    '(9) Pseudo Data Time', '(10) Data Section', ...
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
    '(9) Pseudo Data Time', '(10) Data Section', ...
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



f = waitbar(0,'Saving', 'Name','Save data to .mat file'); % Display a dynamic waitbar indicating saving process.

if camTF == 0 % Single camera
    
    systemSetupComment{1,2} = 'Single';
    
    VmMeasurement = { 'Camera1', VmMap }; % Camera 1
    CaMeasurement = { 'Camera1', CaMap }; % Camera 1
    
    save(newFileName, 'cmosData1Raw', 'cmosData1', 'signalTime', 'acqFreq', 'bgImage1', 'bgImageNom1', 'userMaskMatrix_cam1', ...
        'analog1', 'analog2', 'analogTime', 'pcl', 'camTF', 'fileInfo', 'signalConditioningInfo', 'comment', 'systemSetupComment', ...
        'VmMeasurement', 'CaMeasurement');
    
else % Dual cameras
    
    systemSetupComment{1,2} = 'Dual';
    
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

fprintf('GSDconverter time consumed: %.2f sec\n\n', toc)




end

