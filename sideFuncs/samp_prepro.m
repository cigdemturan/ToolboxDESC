function sampleIn = samp_prepro(sampleIn)

% ************************************************************************
%   Copyright (c) 2016, Li Liu
%   All rights reserved.
% ************************************************************************

% image sample preprocessing
sampleIn = double(sampleIn);
sampleIn = sampleIn - mean(sampleIn(:));
% sampleIn = sampleIn / sqrt(mean(mean(sampleIn .^ 2)));
sampleIn = sampleIn / std(sampleIn(:));



