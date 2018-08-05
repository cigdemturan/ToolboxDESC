function [ LDN_hist, varargout ] = desc_LDN( img, varargin )
    % DESC_LDN applies Local Directional Number Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               mask - 'gaussian', 'kirsch', 'sobel', 'prewitt'
    %               msize - odd numbers as 3, 5, and 7
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LDN_hist - feature histogram
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
    %   Ramirez Rivera, A.; Rojas Castillo; Oksam Chae, "Local Directional Number
    %   Pattern for Face Analysis: Face and Expression Recognition," Image Processing,
    %   IEEE Transactions on , vol.22, no.5, pp.1740,1752, May 2013 doi: 10.1109/TIP.2012.2235848
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
    
    if ~isfield(options,'mask')
        mask = 'kirsch'; %default
        msize = 3;
    else
        mask = options.mask;
        if strcmp(mask,'gaussian')
            if isfield(options,'start')
                start = options.start;
            else
                start = 0.5;
            end
        else
            if isfield(options,'msize')
                msize = options.msize;
            else
                msize = 3;
            end
        end
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
    
    uniqueBin = [1;2;3;4;5;6;7;8;10;11;12;13;14;15;16;17;19;20;21;22;23;24;25;...
        26;28;29;30;31;32;33;34;35;37;38;39;40;41;42;43;44;46;47;48;49;50;51;...
        52;53;55;56;57;58;59;60;61;62];

    if strcmp(mask,'gaussian')
        imgDesc(1).fea = descriptor_LDN(img,'mask','gaussian','sigma',start);
        options.binVec{1} = uniqueBin;
        imgDesc(2).fea = descriptor_LDN(img,'mask','gaussian','sigma',2*start);
        options.binVec{2} = uniqueBin;
        imgDesc(3).fea = descriptor_LDN(img,'mask','gaussian','sigma',3*start);
        options.binVec{3} = uniqueBin;
    else
        imgDesc = descriptor_LDN(img,'mask',mask,'masksize',msize);
        options.binVec = uniqueBin;
    end
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        if isstruct(imgDesc)
            LDN_hist = [];
            for s = 1 : length(imgDesc)
                imgReg = imgDesc(s).fea;
                hh = hist(imgReg(:),options.binVec{s});
                LDN_hist = horzcat(LDN_hist,hh);
            end
        else
            LDN_hist = hist(imgDesc(:),options.binVec);
        end
        
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LDN_hist = LDN_hist ./ sum(LDN_hist);
        end
    else
        LDN_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end