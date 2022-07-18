function output = normaliseSignal(input)

tmin = min( input,[],3 ); % 'tmin' refers to THIRD DIMENSION min
tmax = max( input,[],3 ); % 'tmax' refers to THIRD DIMENSION max

output = rescale( input, 'InputMin',tmin, 'InputMax',tmax );

end