function [ LFD_hist, varargout ] = desc_LFD( img, varargin )
    % DESC_LFD applies Local Frequency Descriptor
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LFD_hist - feature histogram
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
    %   Cigdem Turan and Kin-Man Lam, ìHistogram-based Local Descriptors for Facial 
    %   Expression Recognition (FER): A comprehensive Study,î Journal of Visual 
    %   Communication and Image Representation, 2018. doi: 10.1016/j.jvcir.2018.05.024
    %
    %   Timo Ojala, Matti Pietik‰inen and Topi M‰enp‰‰, "Multiresolution gray-scale and 
    %   rotation invariant texture classification with Local Binary Patterns". IEEE 
    %   Transactions on Pattern Analysis and Machine Intelligence, 2002, 24(7):971-987.
    %
    %   Timo Ojala, Matti Pietik‰inen and Topi M‰enp‰‰, "A generalized Local Binary 
    %   Pattern operator for multiresolution gray scale and rotation invariant texture 
    %   classification". Second International Conference on Advances in Pattern Recognition,
    %   Rio de Janeiro, Brazil, 2001, 397-406.
    %
    %   Ville Ojansivu and Janne Heikkil‰, "Blur insensitive texture classification using
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
    
    [~, filterResp] = descriptor_LPQ(img,5); 

    %LMD
    magn = abs(filterResp);

    imgDesc = struct;
    mapping = getmapping(8,'ri'); 
    [~,imgDesc(1).fea] = descriptor_LBP(magn,1,8);

    %LPD
    CoorX = sign(real(filterResp));
    CoorY = sign(imag(filterResp));

    quadrantMat = ones(size(filterResp));
    quadrantMat(CoorX == -1 & CoorY == 1) = 2;
    quadrantMat(CoorX == -1 & CoorY == -1) = 3;
    quadrantMat(CoorX == 1 & CoorY == -1) = 4;
    
    rSize = size(quadrantMat,1)-2;
    cSize = size(quadrantMat,2)-2;
    link = [1,1;1,2;1,3;2,3;3,3;3,2;3,1;2,1];
    x_c = quadrantMat(2:end-1,2:end-1);
    pattern = zeros(size(x_c));

    for n = 1 : size(link,1)
        corner = link(n,:);
        x_i = quadrantMat(corner(1):corner(1)+rSize-1,corner(2):corner(2)+cSize-1);
        pattern = pattern + double(x_c == x_i) .* 2^(size(link,1)-n);
    end
    
    imgDesc(2).fea = pattern;
    options.binVec{1} = 0:255;
    options.binVec{2} = 0:255;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LFD_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            LFD_hist = horzcat(LFD_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LFD_hist = LFD_hist ./ sum(LFD_hist);
        end
    else
        LFD_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end