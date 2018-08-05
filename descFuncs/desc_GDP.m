function [ GDP_hist, varargout ] = desc_GDP( img, varargin )
    % DESC_GDP applies Gradient Directional Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               mask - sobel or prewitt
    %               t - threshold value
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   GDP_hist - feature histogram
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
    
    if ~isfield(options,'mask')
        options.mask = 'sobel';
        t = 22.5;%5; %default
    elseif strcmp(options.mask,'sobel') && ~isfield(options,'t')
        t = 22.5;%5; %default
    elseif strcmp(options.mask,'prewitt') && ~isfield(options,'t')
        t = 330;%5; %default
    else
        t = options.t;
    end
    
    EPSILON = 0.0000001;
    PI = 3.141592653589;

    if strcmp(options.mask,'sobel')
        maskA = [-1,-2,-1;0,0,0;1,2,1];
        maskB = [-1,0,1;-2,0,2;-1,0,1];
        link = [1,2;1,1;2,1;3,1;3,2;3,3;2,3;1,3];
    elseif strcmp(options.mask,'prewitt')
        maskA = [1,1,1;0,0,0;-1,-1,-1];
        maskB = [1,0,-1;1,0,-1;1,0,-1];
        link = [3,1;3,2;3,3;2,3;1,3;1,2;1,1;2,1];
    end

    Gx = conv2(img,maskA,'same');
    Gy = conv2(img,maskB,'same');
    angles = atan(Gy./ (Gx + EPSILON));
    angles = angles * 180/PI + 90; %scaled to degree from radian
    img = angles;
    
    x_c = img(2:end-1,2:end-1);
    [rSize, cSize] = size(x_c);
    GDPdecimal = zeros(rSize,cSize);
    for n = 1 : size(link,1)
        corner = link(n,:);
        x_i = img(corner(1):corner(1)+rSize-1,corner(2):corner(2)+cSize-1);
        GDPdecimal = GDPdecimal + double(((x_i - x_c) <= t) & ((x_i - x_c) >= -t)) .* 2^(8-n);
    end
%     subplot(121); imshow(uint8(GDPdecimal));
    
    if strcmp(options.mask,'prewitt')
        mapping = getmapping(8,'u2');
        for r = 1 : size(GDPdecimal,1)
            for c = 1 : size(GDPdecimal,2)
                GDPdecimal(r,c) = mapping.table(GDPdecimal(r,c)+1);
            end
        end
        binNum = mapping.num;
    else
        binNum = 256;
    end
    
    imgDesc = GDPdecimal;
    options.binVec = 0:(binNum-1);
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        GDP_hist = hist(imgDesc(:),options.binVec);
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            GDP_hist = GDP_hist ./ sum(GDP_hist);
        end
    else
        GDP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end