function output = binnigSignal(input, kernalSize)

kernal = (1/kernalSize^2) .* ones(kernalSize,kernalSize);

output = imfilter(input, kernal, 0); % '0' means padding with 0

end