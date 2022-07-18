function output = denoise60Hz(input, acqFreq)

% https://www.mathworks.com/help/signal/ref/filtfilt.html#d120e50664

d60Hz = designfilt('bandstopiir', ...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',58.0, ...
    'HalfPowerFrequency2',62.0, ...
    'DesignMethod','butter', ...
    'SampleRate',acqFreq);

inputTemporary = permute( input, [3,2,1] );

inputTemporary = filtfilt( d60Hz, inputTemporary );

output = permute( inputTemporary, [3,2,1] );

end