close all
clc

%% (0) Load data correctly


%% (1) Get X and Y (i.e., row and col) of a pixel, and signal

X = 40;
Y = 40;

row = Y;
col = X;

hilbert_sig = squeeze( hilbertDataSection( row, col, : ) );

if isrow( hilbert_sig )
    hilbert_sig = hilbert_sig';
end

%% (2) Get the real and imaginary part of the complex value

real_hilbert_sig = real( hilbert_sig );
imag_hilbert_sig = imag( hilbert_sig );


%% (3) Plot real vs img signals

screenSize = get( groot, 'ScreenSize' );

figureObject =  figure( 'Name', 'Phase' );
figureObject.Position = [ 1, 20, 0.9*screenSize(4), 0.9*screenSize(4) ];

ax_Figure = axes;


plot( ax_Figure, real_hilbert_sig, imag_hilbert_sig, 'linewidth',2 )
xlabel( ax_Figure, 'Real' )
ylabel( ax_Figure, 'Img' )

xlim( ax_Figure, [ -1, 1 ] )
ylim( ax_Figure, [ -1, 1 ] )

ax_Figure.XAxisLocation = 'Origin';
ax_Figure.YAxisLocation = 'Origin';
ax_Figure.LineWidth = 3;
ax_Figure.FontSize = 40;


%% (4) Plot real abd img on time axis

t = dataSectionTime;
if isrow(t)
    t=t';
end

figure
line( t, real_hilbert_sig, 'Color','blue' )
line( t, imag_hilbert_sig, 'Color','red' )
legend( 'real', 'img' )