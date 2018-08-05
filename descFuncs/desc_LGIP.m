function [ LGIP_hist, varargout ] = desc_LGIP( img, varargin )
    % DESC_LGIP applies Local Gradient Increasing Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LGIP_hist - feature histogram
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
    
    img = double(img);
    [r, c] = size(img);
    
    v000 = double(-img(2:end-3,3:end-2) + img(2:end-3,4:end-1) -2*img(3:end-2,3:end-2) ...
        + 2*img(3:end-2,4:end-1) - img(4:end-1,3:end-2) + img(4:end-1,4:end-1) > 0);
    v001 = double(-img(2:end-3,2:end-3) + img(1:end-4,3:end-2) -2*img(3:end-2,3:end-2) ...
        + 2*img(2:end-3,4:end-1) - img(4:end-1,4:end-1) + img(3:end-2,5:end) > 0);
    v010 = double(-img(3:end-2,2:end-3) + img(2:end-3,2:end-3) -2*img(3:end-2,3:end-2) ...
        + 2*img(2:end-3,3:end-2) - img(3:end-2,4:end-1) + img(2:end-3,4:end-1) > 0);
    v011 = double(-img(4:end-1,2:end-3) + img(3:end-2,1:end-4) -2*img(3:end-2,3:end-2) ...
        + 2*img(2:end-3,2:end-3) - img(2:end-3,4:end-1) + img(1:end-4,3:end-2) > 0);
    v100 = double(-img(2:end-3,3:end-2) + img(2:end-3,2:end-3) -2*img(3:end-2,3:end-2) ...
        + 2*img(3:end-2,2:end-3) - img(4:end-1,3:end-2) + img(4:end-1,2:end-3) > 0);
    v101 = double(-img(2:end-3,2:end-3) + img(3:end-2,1:end-4) -2*img(3:end-2,3:end-2) ...
        + 2*img(4:end-1,2:end-3) - img(4:end-1,4:end-1) + img(5:end,3:end-2) > 0);
    v110 = double(-img(3:end-2,2:end-3) + img(4:end-1,2:end-3) -2*img(3:end-2,3:end-2) ...
        + 2*img(4:end-1,3:end-2) - img(3:end-2,4:end-1) + img(4:end-1,4:end-1) > 0);
    v111 = double(-img(4:end-1,2:end-3) + img(5:end,3:end-2) -2*img(3:end-2,3:end-2) ...
        + 2*img(4:end-1,4:end-1) - img(2:end-3,4:end-1) + img(3:end-2,5:end) > 0);

    OTVx = reshape(v000 + v001 + v111 - v011 - v100 - v101,1,[]);
    OTVy = reshape(v001 + v010 + v011 - v101 - v110 - v111,1,[]);

    patternMask = [...
                    -1,-1,30,29,28,-1,-1;...
                    -1,16,15,14,13,12,-1;...
                    31,17,4,3,2,11,27;...
                    32,18,5,0,1,10,26;...
                    33,19,6,7,8,9,25;...
                    -1,20,21,22,23,24,-1;...
                    -1,-1,34,35,36,-1,-1];
    idx = sub2ind([7 7], OTVx+4, OTVy+4);
    % AA = patternMask(reshape(OTVx+4,[],1),reshape(OTVy+4,[],1));
    LGIP = patternMask(idx);
    imgDesc = reshape(LGIP,r-4,c-4);
    options.binVec = 0:36;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LGIP_hist = hist(imgDesc(:),options.binVec);
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LGIP_hist = LGIP_hist ./ sum(LGIP_hist);
        end
    else
        LGIP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end