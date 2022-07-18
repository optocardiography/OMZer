close all
clc

% Useful Matlab URL ----------

% Smooth Date with Convolution
% https://www.mathworks.com/help/matlab/data_analysis/convolution-filter-to-smooth-data.html

% imgaussfilt
% https://www.mathworks.com/help/images/ref/imgaussfilt.html#namevaluepairarguments

% imfilter
% https://www.mathworks.com/help/images/ref/imfilter.html

% fspecial
% https://www.mathworks.com/help/images/ref/fspecial.html#d123e99465

% conv2
% https://www.mathworks.com/help/matlab/ref/conv2.html#bvgtez6-shape


%% (1) Load Data

% Make sure data is loaded before following steps


%% (2) Assign Values to Variables

backgroundImage = backgroundImage; % The background image

LB = mapDataWithTitle{2,5};
UB = mapDataWithTitle{2,6};
originalMapImage = mapDataWithTitle{2,10}; % The original image

originalMapImage( originalMapImage < LB | originalMapImage > UB ) = NaN;

screenSize = get( groot, 'ScreenSize' );


%% (3) Select Plot Method, Colormap, contourfLevelStep, smooth kernal size

methodGroup = { 'contourf', 'imagesc' };
plotMethod = methodGroup{1};

colormapGourp = { jet, parula, spring, summer, autumn, winter, cool, hot, turbo, hsv };
colormapSelection = colormapGourp{1};

contourfLevelStep = 0.5;

kernalSize = 1;


%% (4) Set Figure Display Option

showBackground = 1; % 0 or 1

userAlphaValue = 1; % [0,1]

showYTick = 1; % 0 or 1
showYTickLabel = 1; % 0 or 1

showXTick = 1; % 0 or 1
showXTickLabel = 1; % 0 or 1

showXAxisLine = 0; % 0 or 1
showYAxisLine = 0; % 0 or 1


%% (5) Plot The Original Image

figureOriginalObject =  figure('Name', 'Original Image' );
figureOriginalObject.Position = [ 1, 20, 0.9*screenSize(4), 0.9*screenSize(4) ];

ax_FigureOriginal = axes;


if showBackground == 1
    
    imagesc( ax_FigureOriginal, backgroundMapImage )
end


hold( ax_FigureOriginal, 'on' )

if isequal( plotMethod, 'contourf' )
    
    contourf( ax_FigureOriginal, originalMapImage, 'LineColor','none', 'LevelStep',contourfLevelStep )
    set( ax_FigureOriginal, 'YDir','Reverse' )
    
elseif isequal( plotMethod, 'imagesc' )
    
    imagesc( ax_FigureOriginal, originalMapImage, 'AlphaData', ~isnan(originalMapImage) * userAlphaValue )
    
end

set( ax_FigureOriginal, 'colormap',colormapSelection )

hold( ax_FigureOriginal, 'off' )


%% (6) Smooth the data via 'convolution'
% https://www.mathworks.com/help/matlab/data_analysis/convolution-filter-to-smooth-data.html

kernal = ones(3) / ( kernalSize * kernalSize );

smoothMapImage = conv2( originalMapImage, kernal, 'same'); % The smoothed version of the original image

figureSmoothObject =  figure('Name', 'Smooth Image' );
figureSmoothObject.Position = [ 1, 20, 0.9*screenSize(4), 0.9*screenSize(4) ];

ax_FigureSmooth = axes;


if showBackground == 1
    
    imagesc( ax_FigureSmooth, backgroundMapImage )
end


hold( ax_FigureSmooth, 'on' )

if isequal( plotMethod, 'contourf' )
    
    contourf( ax_FigureSmooth, smoothMapImage, 'LineColor','none', 'LevelStep',0.5 )
    set( ax_FigureSmooth, 'YDir','Reverse' )
    
elseif isequal( plotMethod, 'imagesc' )
    
    imagesc( ax_FigureSmooth, smoothMapImage, 'AlphaData', ~isnan(smoothMapImage) * userAlphaValue )
end

set( ax_FigureSmooth, 'colormap',colormapSelection )

hold( ax_FigureSmooth, 'off' )


%% (7) Apply Figure Display Option

if showXTick == 0
    
    set( ax_FigureOriginal, 'XTick',[] );
    set( ax_FigureSmooth, 'XTick',[] );
end

if showXTickLabel == 0
    
    set( ax_FigureOriginal, 'Xticklabel',[] )
    set( ax_FigureSmooth, 'Xticklabel',[] );
end

if showYTick == 0
    
    set( ax_FigureOriginal, 'YTick',[] );
    set( ax_FigureSmooth, 'YTick',[] );
    
end

if showYTickLabel == 0
    
    set( ax_FigureOriginal, 'Yticklabel',[] )
    set( ax_FigureSmooth, 'Yticklabel',[] );
end

if showXAxisLine == 0
    
    set( ax_FigureOriginal, 'XColor','none' )
    set( ax_FigureSmooth, 'XColor','none' )
end

if showYAxisLine == 0
    
    set( ax_FigureOriginal, 'YColor','none' )
    set( ax_FigureSmooth, 'YColor','none' )
end


%% (8) Add Text

addText = 1; % 0 or 1

if addText == 1
    
    textContent = 'Text Test';
    
    textXPosition = 70;
    textYPosition = 50;
    textFontColor = 'Red';
    textFontSize = 40;
    
    text( ax_FigureOriginal, textXPosition, textYPosition, textContent, ...
        'Color', textFontColor, 'FontSize', textFontSize, 'FontWeight','Bold', ...
        'HorizontalAlignment','center', 'VerticalAlignment','middle')
    
    text( ax_FigureSmooth, textXPosition, textYPosition, textContent, ...
        'Color', textFontColor, 'FontSize', textFontSize, 'FontWeight','Bold', ...
        'HorizontalAlignment','center', 'VerticalAlignment','middle')
end


%% (9) Add Marker

addMarker = 1; % 0 or 1

Color1 = [ 0.00, 0.45, 0.74 ]; % [ 0, 115, 189 ] % Blue
Color2 = [ 0.93, 0.69, 0.13 ]; % [ 237, 161, 33 ] % Orange
Color3 = [ 0.64, 0.08, 0.18 ]; % [ 163, 20, 46 ] % Red
Color4 = [ 0.72, 0.27, 1.00 ]; % [ 184, 69, 255 ] % Purple
Color5 = [ 0.47, 0.67, 0.19 ]; % [ 120, 171, 48 ] % Green
Color6 = [ 0.89, 0.47, 0.58 ]; % [ 227, 120, 148 ]
ColorGroup = { Color1, Color2, Color3, Color4, Color5, Color6 };

lineWidthOption = 10;
markerSizeOption = 40;
markerEdgeColorOption = 'White';


if addMarker == 1
    
    pixelX = 50;
    pixelY = 50;
    
    
    hold(ax_FigureOriginal, 'on')
    
    for ID = 1 : length( pixelX )
        plot( ax_FigureOriginal, pixelX(ID), pixelY(ID), ...
            'LineWidth', lineWidthOption, ...
            'Marker', 'o', ...
            'MarkerSize', markerSizeOption, ...
            'MarkerFaceColor', ColorGroup{ID}, ...
            'MarkerEdgeColor', markerEdgeColorOption )
    end
    
    hold(ax_FigureOriginal, 'off')
    
    
    hold(ax_FigureSmooth, 'on')
    
    for ID = 1 : length( pixelX )
        plot( ax_FigureSmooth, pixelX(ID), pixelY(ID), ...
            'LineWidth', lineWidthOption, ...
            'Marker', 'o', ...
            'MarkerSize', markerSizeOption, ...
            'MarkerFaceColor', ColorGroup{ID}, ...
            'MarkerEdgeColor', markerEdgeColorOption )
    end
    
    hold(ax_FigureSmooth, 'off')
end