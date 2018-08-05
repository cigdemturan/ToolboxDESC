function [ LAP_hist, varargout ] = desc_LAP( img, varargin )
    % DESC_LAP applies Local Arc Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LAP_hist - feature histogram
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
    
    linkList1 = {[2,2;4,4],[2,3;4,3],[2,4;4,2],[3,4;3,2]};
    linkList2 = {[1,1;5,5],[1,2;5,4],[1,3;5,3],[1,4;5,2],[1,5;5,1],[2,5;4,1],[3,5;3,1],[4,5;2,1]};
    x_c = img(3:end-2,3:end-2);
    [rSize, cSize] = size(x_c);
    pattern1 = zeros(size(x_c));
    for n = 1 : size(linkList1,2)
        corner1 = linkList1{n}(1,:);
        corner2 = linkList1{n}(2,:);
        x_1 = img(corner1(1):corner1(1)+rSize-1,corner1(2):corner1(2)+cSize-1);
        x_2 = img(corner2(1):corner2(1)+rSize-1,corner2(2):corner2(2)+cSize-1);
        pattern1 = pattern1 + double(((x_1 - x_2) > 0)) .* 2^(size(linkList1,2)-n);
    end
    pattern2 = zeros(size(x_c));
    for n = 1 : size(linkList2,2)
        corner1 = linkList2{n}(1,:);
        corner2 = linkList2{n}(2,:);
        x_1 = img(corner1(1):corner1(1)+rSize-1,corner1(2):corner1(2)+cSize-1);
        x_2 = img(corner2(1):corner2(1)+rSize-1,corner2(2):corner2(2)+cSize-1);
        pattern2 = pattern2 + double(((x_1 - x_2) > 0)) .* 2^(size(linkList2,2)-n);
    end
    
    imgDesc(1).fea = pattern1; binVec{1} = 0:2^size(linkList1,2)-1;
    imgDesc(2).fea = pattern2; binVec{2} = 0:2^size(linkList2,2)-1;
    
    options.binVec = binVec;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LAP_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            LAP_hist = horzcat(LAP_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LAP_hist = LAP_hist ./ sum(LAP_hist);
        end
    else
        LAP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end