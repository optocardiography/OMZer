function output = SGFilterSignal(input)

Wl = 13; % Window length
SGorder = 5; % The order of the filter

output = smoothdata( input, 3, 'sgolay',Wl, 'Degree',SGorder ); % Smooth along the 3rd dimension

end