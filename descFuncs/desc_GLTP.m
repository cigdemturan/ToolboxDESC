function [ GLTP_hist, varargout ] = desc_GLTP( img, varargin )
    % DESC_GLTP applies Gradient Local Ternary Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               t - threshold value
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   GLTP_hist - feature histogram
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
    
    EPSILON=0.0000001;
    PI=3.141592653589;
    
	img = double(img);
	
    if nargin == 2
        options = varargin{1};
    else
        options = struct;
    end
    
    if ~isfield(options,'t')
        options.t = 10; %in the paper, decided emprically
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
    
    maskA = [-1,-2,-1;0,0,0;1,2,1];
    maskB = [-1,0,1;-2,0,2;-1,0,1];
    
    Gx = conv2(img,maskA,'same');
    Gy = conv2(img,maskB,'same');
    
    imgGradient = abs(Gx) + abs(Gy);
    
    [~, imgDesc] = desc_LTeP(imgGradient, options);
    options.binVec{1} = 0:255;
    options.binVec{2} = 0:255;
    
    if isfield(options,'DGLP') && options.DGLP == 1
        [r,c] = size(Gx);
        imgAngle = atan(Gy./(Gx + EPSILON));
        imgAngle = imgAngle * 180/PI;
        imgAngle(Gx < 0) = imgAngle(Gx < 0) + 180;
        imgAngle(Gx >= 0 & Gy < 0) = imgAngle(Gx >= 0 & Gy < 0) + 360;
        imgAngle = imgAngle(2:r-1,2:c-1);
        imgAngle = floor(imgAngle ./ 22.5);
        
        imgDesc(3).fea = imgAngle; options.binVec{3} = 0:15;
    end
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        GLTP_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            GLTP_hist = horzcat(GLTP_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            GLTP_hist = GLTP_hist ./ sum(GLTP_hist);
        end
    else
        GLTP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end    
end