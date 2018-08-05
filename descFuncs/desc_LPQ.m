function [ LPQ_hist, varargout ] = desc_LPQ( img, varargin )
    % DESC_LPQ applies Local Phase Quantization
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               windowSize - size of the neighborhood
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LPQ_hist - feature histogram
    %   imgDesc - descriptor image
    % 
    % ABOUT
    % Created:      9.4.2017
    % Last Update:  5.8.2018
    % Version:      1.0
    %
    % WHEN PUBLISHING A PAPER AS A RESULT OF RESEARCH CONDUCTED BY USING THIS CODE
    % OR ANY PART OF IT, MAKE A REFERENCE TO THE FOLLOWING PUBLICATIONS:
    %
    %   Cigdem Turan and Kin-Man Lam, “Histogram-based Local Descriptors for Facial 
    %   Expression Recognition (FER): A comprehensive Study,” Journal of Visual 
    %   Communication and Image Representation, 2018. doi: 10.1016/j.jvcir.2018.05.024
    %
    %   Ville Ojansivu and Janne Heikkilä, "Blur insensitive texture classification using
    %   local phase quantization". Proc. Image and Signal Processing (ICISP 2008), 2008, 
    %   5099:236-243. 
    %
    %
    % Copyright (c) 2018 Cigdem Turan
    % Department of Electronic and Information Engineering,
    % The Hong Kong Polytechnic University
    % 
    % Permission is hereby granted, free of charge, to any person obtaining a copy
    % of this software and associated documentation files, to deal
    % in the Software without restriction, subject to the following conditions:
    % 
    % The above copyright notice and this permission notice shall be included in 
    % all copies or substantial portions of the Software.
    %
    % The Software is provided "as is", without warranty of any kind.
    % 
    % August 2018
    
    img = double(img);
    
    if nargin == 2
        options = varargin{1};
    else
        options = struct;
    end
    
    if isfield(options,'gridHist') && length(options.gridHist) == 2
        rowNum = options.gridHist(1);
        colNum = options.gridHist(2);
    elseif isfield(options,'gridHist') && length(options.gridHist) == 1
        rowNum = options.gridHist;
        colNum = options.gridHist;
    else
        rowNum = 1;
        colNum = 1;
    end
    
    if isfield(options,'windowSize')
        wSz = options.windowSize;
    else
        wSz = 5;
    end
    
    [imgDesc, ~] = descriptor_LPQ(img,wSz);
    
    options.binVec = 0:255;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LPQ_hist = hist(imgDesc(:),options.binVec);
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LPQ_hist = LPQ_hist ./ sum(LPQ_hist);
        end
    else
        LPQ_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end