function [ GDP2_hist, varargout ] = desc_GDP2( img, varargin )
    % DESC_GDP2 applies Gradient Direction Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   GDP2_hist - feature histogram
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
    
    linkList = {[1,1;3,3],[1,2;3,2],[1,3;3,1],[2,3;2,1]};
    x_c = img(2:end-1,2:end-1);
    [rSize, cSize] = size(x_c);
    pattern = zeros(size(x_c));
    for n = 1 : size(linkList,2)
        corner1 = linkList{n}(1,:);
        corner2 = linkList{n}(2,:);
        x_1 = img(corner1(1):corner1(1)+rSize-1,corner1(2):corner1(2)+cSize-1);
        x_2 = img(corner2(1):corner2(1)+rSize-1,corner2(2):corner2(2)+cSize-1);
        pattern = pattern + double(((x_1 - x_2) >= 0)) .* 2^(size(linkList,2)-n);
    end
    imgDesc = pattern;
    
    binNum = 2^size(linkList,2);
    transitionSelected = [0,1,3,7,8,12,14,15];
    options.selected = transitionSelected+1;
    options.binVec = 0:(binNum-1);
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        GDP2_hist = hist(imgDesc(:),options.binVec);
        GDP2_hist = GDP2_hist(options.selected);
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            GDP2_hist = GDP2_hist ./ sum(GDP2_hist);
        end
    else
        GDP2_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end