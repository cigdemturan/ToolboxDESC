function [ LBP_hist, varargout ] = desc_LBP( img, varargin )
    % DESC_LBP applies Local Binary Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               radius - radius of the neighborhood
    %               mappingType - 'full' -> standard LBP, 
    %                               'u2' -> uniform LBP,
    %                               'ri' -> rotation invariant LBP
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LBP_hist - feature histogram
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
    
    if isfield(options,'radius')
        radius = options.radius;
        neighbors = 8*radius;
    else
        radius = 1;
        neighbors = 8;
    end
    
    if isfield(options,'mappingType') && ~strcmp(options.mappingType,'full')
        mappingType = options.mappingType;
        mapping = getmapping(neighbors,mappingType); 
        if strcmp(mappingType,'u2')
            if radius == 1
                options.binVec = 0:58;
            elseif radius == 2
                options.binVec = 0:242;
            end
        elseif strcmp(mappingType,'ri')
            if radius == 1
                options.binVec = 0:35;
            elseif radius == 2
                options.binVec = 0:4116;
            end
        end
    else
        mapping = 0;
        options.binVec = 0:255;
    end
   
    [~, imgDesc ] = descriptor_LBP(img,radius,neighbors,mapping,'nh');
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LBP_hist = hist(imgDesc(:),options.binVec);
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LBP_hist = LBP_hist ./ sum(LBP_hist);
        end
    else
        LBP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end