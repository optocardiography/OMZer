close all
clc

%% (1) Load Data

% Make sure data is loaded before following steps


%% (2) Assign Values to Variables

bgImage = backgroundImage;


%% (3) Choose the frames of the video

frameTime = [ 0 : 0.5:  30 ]; % Unit in msec. Manually type in frames of the video

frameID = 1 + ( frameTime / ( 1000 / acquisitionFrequency_Hz_Unit ) );


%% (4) Export to Video or Not

exportVideo = 1; % 0 or 1
videoFrameRate = 5;

if exportVideo == 1
    
    saveDir = uigetdir;
    
    if saveDir ~= 0 % User has selected file directory
        
        prompt = {'Enter filename to save (without extension)...   Please do not use \/:*?"<>|'};
        dlgtitle = 'Save the video file';
        dfinput = { 'Video' };
        dims = [1,150];
        
        filename = inputdlg(prompt, dlgtitle, dims, dfinput);
        
        if ~isempty(filename) % User has entered a name
            
            fullSaveName = strcat(saveDir, '/', filename);
            fullSaveName = fullSaveName{:};
            
        else
            
            msg = 'You want to export a video but did not set the file name correctly. Program cannot continue.';
            warning( msg );
            fprintf('\n');
            
            return
        end
        
    else
        
        msg = 'You want to export a video but did not set the save direct correctly. Program cannot continue.';
        warning( msg );
        fprintf('\n');
        
        return
    end
end


%% (5) Set Figure Display Option

methodGroup = { 'imagesc', 'contourf', 'pcolor' };
plotMethod = methodGroup{2};

wavefrontLineWidth = 4.5;

showBackground = 1; % 0 or 1

userAlphaValue = 1; % [0,1]

showYTick = 1; % 0 or 1
showYTickLabel = 1; % 0 or 1

showXTick = 1; % 0 or 1
showXTickLabel = 1; % 0 or 1

showXAxisLine = 0; % 0 or 1
showYAxisLine = 0; % 0 or 1

addText = 1; % 0 or 1

needPause = 1; % 0 or 1
pauseTime = 0.1; % Unit sec



%% (5) Plot and Save video

screenSize = get( groot, 'ScreenSize' );

figureObject =  figure( 'Name', 'Phase' );
figureObject.Position = [ 1, 20, 0.9*screenSize(4), 0.9*screenSize(4) ];

ax_Figure = axes;


if exportVideo == 1
    
    videoObj = VideoWriter( fullSaveName, 'MPEG-4' ); % Write all pictures in this video
    videoObj.FrameRate = videoFrameRate;
    open(videoObj);   
end

for ID = frameID
    
    % Apply background images
    if showBackground == 1
        
        imagesc( ax_Figure, bgImage )
        
        hold( ax_Figure, 'on' )
    end
    
    % Plot the map frame
    frameImage = phaseMapDataSection( :, :, ID);
    
    if isequal( plotMethod, 'imagesc' )
        
        plotObject = imagesc( ax_Figure, frameImage );
        plotObject.AlphaData = userAlphaValue * ~isnan( frameImage );
        
    elseif isequal( plotMethod, 'pcolor' )
        
        plotObject = pcolor( ax_Figure, frameImage );
        plotObject.FaceColor = 'interp';
        plotObject.EdgeColor = 'none';
        plotObject.AlphaData = ~isnan(frameImage) * userAlphaValue; % Make the pixel with NaN transparent
        
    elseif isequal( plotMethod, 'contourf' )
        
        contourf( ax_Figure, frameImage, 'LineColor','none', 'LevelStep', pi/2^6 )
        set( ax_Figure, 'YDir','Reverse' )
    end
    
    colormap( ax_Figure, jet )
    
    %  Colorbar
    colorbarObect = colorbar( ax_Figure );
    colorbarObect.Ticks = [ -pi, -pi/2, 0, pi/2, pi ];
    colorbarObect.TickLabels = { '-\pi', '-\pi/2', '0', '\pi/2', '\pi' };
    colorbarObect.FontWeight = 'Bold';
    colorbarObect.FontSize = 30;
    
    caxis( ax_Figure, [ -pi, pi ] )
    
    hold( ax_Figure, 'off' )
    
    % Plot wavefront
    wavefrontInfo_TemporaryHolder = wavefrontDataSection{ ID }; % 'wavefrontDataSection' is a cell that includes another cell (i.e., 'wavefrontInfo_TemporaryHolder')
    
    if iscell( wavefrontInfo_TemporaryHolder )
        
        for idx = 1 : size( wavefrontInfo_TemporaryHolder, 1 )
            
            wavefront_X = wavefrontInfo_TemporaryHolder{ idx,4 };
            wavefront_Y = wavefrontInfo_TemporaryHolder{ idx,5 };
            
            line( ax_Figure, wavefront_X, wavefront_Y, 'Color','White', 'LineWidth',wavefrontLineWidth );
        end
    end
    
    % Apply text content
    if addText == 1
        
        
        textContent_Num = sprintf('%.1f', frameTime(ID));
        
        %textContent_Num = num2str( frameTime(ID) );
        textContent_Unit = 'ms';
        
        textXPosition = [ 70, 85 ];
        textYPosition = [ 20, 20 ];
        textFontColor = 'Red';
        textFontSize = 40;
        
        text( ax_Figure, textXPosition, textYPosition, { textContent_Num, textContent_Unit}, ...
            'Color', textFontColor, 'FontSize', textFontSize, 'FontWeight','Bold', ...
            'HorizontalAlignment','center', 'VerticalAlignment','middle')      
    end
    
    % Apply Figure Display Option
    if showXTick == 0
        
        set( ax_Figure, 'XTick',[] );
    end
    
    if showXTickLabel == 0
        
        set( ax_Figure, 'Xticklabel',[] )
    end
    
    if showYTick == 0
        
        set( ax_Figure, 'YTick',[] );
    end
    
    if showYTickLabel == 0
        
        set( ax_Figure, 'Yticklabel',[] )
    end
    
    if showXAxisLine == 0
        
        set( ax_Figure, 'XColor','none' )
    end
    
    if showYAxisLine == 0
        
        set( ax_Figure, 'YColor','none' )
    end
    
    % Puse frame plot
    if needPause == 1
        
        pause( pauseTime )
    end
    
    
    
    
    if exportVideo == 1
        
        newImageData = getframe(gcf);
        writeVideo(videoObj,newImageData);
    end
    
end

if exportVideo == 1
    
    close(videoObj);
    
    if ishandle(figureObject)
        close(figureObject)
    end
end
