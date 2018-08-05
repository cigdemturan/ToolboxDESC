function [ IWBC_hist, varargout ] = desc_IWBC( img, varargin )
    % DESC_IWBC applies Improved Weber Binary Coding
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               scale - number of scale in a IWBC pyramid
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   IWBC_hist - feature histogram
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
    
    scaleCell{1} = [1,1;1,2;1,3;2,3;3,3;3,2;3,1;2,1];
    scaleCell{2} = [1,1;1,2;1,3;1,4;1,5;2,5;3,5;4,5;5,5;5,4;5,3;5,2;5,1;4,1;3,1;2,1];
    scaleCell{3} = [1,1;1,2;1,3;1,4;1,5;1,6;1,7;2,7;3,7;4,7;5,7;6,7;7,7;7,6;7,5;7,4;7,3;7,2;7,1;6,1;5,1;4,1;3,1;2,1];
    
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
    
    if isfield(options,'scale')
        scale = options.scale;
    else
        scale = 1; %default
    end
    
    img = double(img);
    numNeigh = scale*8;
    BELTA=5; % to avoid that center pixture is equal to zero
    ALPHA=3; % like a lens to magnify or shrink the difference between neighbors
    EPSILON=0.0000001;
    ANGLE = 5*pi/4;
    ANGLEDiff = 2*pi/numNeigh;
%     [yRow, xCol] = size(img);
    x_c = img(1+scale:end-scale,1+scale:end-scale);
    [rSize, cSize] = size(x_c);
    DEx = zeros(rSize,cSize);
    DEy = zeros(rSize,cSize);
    link = scaleCell{scale};
    for n = 1 : numNeigh
        corner = link(n,:);
        x_i = img(corner(1):corner(1)+rSize-1,corner(2):corner(2)+cSize-1);
        DEx = DEx + (x_i - x_c) * cos(ANGLE);
        DEy = DEy + (x_i - x_c) * sin(ANGLE);
        ANGLE = ANGLE - ANGLEDiff;
    end
    EPSx = atan( (ALPHA*DEx) ./ (x_c+BELTA) );
    EPSy = atan( (ALPHA*DEy) ./ (x_c+BELTA) );
    signEPSx = sign(EPSx);
    signEPSy = sign(EPSy);
    
    EPSxDeg = EPSx * 180/pi;
    EPSyDeg = EPSy * 180/pi;
    NWM = sqrt(EPSxDeg.^2 + EPSyDeg.^2);
    EPSx(EPSx == 0) = EPSILON;
    NWO = atan(EPSy./EPSx);
    NWO = NWO * 180/pi;
    NWO( EPSx < 0) = NWO(EPSx < 0) + 180;
    NWO(EPSx > 0 & EPSy < 0) = NWO(EPSx > 0 & EPSy < 0) + 360;

    B_x = ones(size(signEPSx));
    B_x(signEPSx == 1) = 0;
    B_y = ones(size(signEPSy));
    B_y(signEPSy == 1) = 0;

    %%LOCAL BINARY MAGNITUDE PATTERN
    %   for NWM (Novel Weber Magnitude)
    scale2 = 1;
    numNeigh = scale2*8;
    link = scaleCell{scale2};

    x_c = NWM(1+scale2:end-scale2,1+scale2:end-scale2);
    [rSize, cSize] = size(x_c);
    LBMP = zeros(rSize,cSize);
    for i = 1 : numNeigh
        corner = link(i,:);
        x_i = NWM(corner(1):corner(1)+rSize-scale2,corner(2):corner(2)+cSize-scale2);
        diff = x_i - x_c;
        diff(diff == 0 | diff > 0) = 1;
        diff(diff < 0) = 0;
        LBMP = LBMP + diff .* 2^(numNeigh-i);
    end

    IWBC_M = LBMP + B_y(1+scale2:end-scale2,1+scale2:end-scale2) .* 2^(numNeigh);
    IWBC_M = IWBC_M + B_x(1+scale2:end-scale2,1+scale2:end-scale2) .* 2^(numNeigh+1);

    %%LOCAL XOR ORIENTATION PATTERN
    %   for NWO (Novel Weber Orientation)
    NWO(NWO == 360) = 0;
    NWO(NWO >=  0 & NWO < 90) = 0;
    NWO(NWO >=  90 & NWO < 180) = 1;
    NWO(NWO >=  180 & NWO < 270) = 2;
    NWO(NWO >=  270 & NWO < 360) = 3;
    
    x_c = NWO(1+scale2:end-scale2,1+scale2:end-scale2);
    LXOP = zeros(rSize,cSize);
    for i = 1 : numNeigh
        corner = link(i,:);
        x_i = NWO(corner(1):corner(1)+rSize-scale2,corner(2):corner(2)+cSize-scale2);
        diff = ~eq(x_i, x_c);
%         diff = xor(x_i, x_c);
        LXOP = LXOP + diff .* 2^(numNeigh-i);
    end

    IWBC_O = LXOP + B_y(1+scale2:end-scale2,1+scale2:end-scale2) .* 2^(numNeigh);
    IWBC_O = IWBC_O + B_x(1+scale2:end-scale2,1+scale2:end-scale2) .* 2^(numNeigh+1);
    
    imgDesc(1).fea = IWBC_M; options.binVec{1} = 0:(2^(numNeigh+2)-1);
    imgDesc(2).fea = IWBC_O; options.binVec{2} = 0:(2^(numNeigh+2)-1);
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        IWBC_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            IWBC_hist = horzcat(IWBC_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            IWBC_hist = IWBC_hist ./ sum(IWBC_hist);
        end
    else
        IWBC_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end