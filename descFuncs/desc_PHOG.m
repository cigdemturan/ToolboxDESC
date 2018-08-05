function [ PHOG_hist, varargout ] = desc_PHOG( img, varargin )
    % DESC_PHOG applies Pyramid of Histogram of Oriented Gradients
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               bin - # of quantization levels
    %               angle - 180 or 360 (please refer to the paper)
    %               L - # of pyramid levels
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   PHOG_hist - feature histogram
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
    
    if isfield(options,'bin')
        bin = options.bin;
    else
        bin = 8;
    end
        
    if isfield(options,'angle')
        angle = options.angle;
    else
        angle = 360;
    end   
        
    if isfield(options,'L')
        L = options.L;
    else
        L = 2;
    end
    
    roi = [1;size(img,1);1;size(img,2)];
    
    [~, bh_roi, bv_roi] = descriptor_PHOG(img,bin,angle,L,roi);
    
    imgDesc(1).fea = bh_roi;
    imgDesc(2).fea = bv_roi;
    
    options.L = L; options.bin = bin; options.binVec = [];
    options.phogHist = 1;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1       
        PHOG_hist = anna_phogDescriptor(bh_roi,bv_roi,options.L,options.bin)';
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            PHOG_hist = PHOG_hist ./ sum(PHOG_hist);
        end
    else
        PHOG_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end