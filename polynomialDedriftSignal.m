function output = polynomialDedriftSignal(input, dedriftOrder)

inputTemporary = permute( input, [3,2,1] );

inputTemporary = detrend( inputTemporary, dedriftOrder );

output = permute( inputTemporary, [3,2,1] );

end