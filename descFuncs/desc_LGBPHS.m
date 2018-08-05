function [LGBPHS_hist, varargout] = desc_LGBPHS(img,varargin)
    % DESC_LGBPHS applies Local Gabor Binary Pattern Histogram Sequence
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               uniformLBP - 1 if uniform
    %               scaleNum - # of Gabor scale
    %               orienNum - # of Gabor orientation 
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LGBPHS_hist - feature histogram
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
    %   Vitomir ätruc and Nikola Paveöi?, "The Complete Gabor-Fisher Classifier for Robust 
    %   Face Recognition," EURASIP Advances in Signal Processing, vol. 2010, 26
    %   pages, doi:10.1155/2010/847680, 2010.
    %
    %   Vitomir ätruc and Nikola Paveöi?, "Gabor-Based Kernel Partial-Least-Squares 
    %   Discrimination Features for Face Recognition," Informatica (Vilnius), vol.
    %   20, no. 1, pp. 115-138, 2009.
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

    if isfield(options,'uniformLBP')
        uniformLBP = options.uniformLBP;
    else
        uniformLBP = 1;
    end
    
    if isfield(options,'scaleNum')
        scaleNum = options.scaleNum;
    else
        scaleNum = 5;
    end
    
    if isfield(options,'orienNum')
        orienNum = options.orienNum;
    else
        orienNum = 8;
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
    
    gaborMag = abs(ct_gaborFilter(img,8,5));
    imgDesc = struct;
    c = 0;
    for s = 1 : scaleNum
        for o = 1 : orienNum
            gaborResIns = gaborMag(:,:,o,s);
            c = c + 1;
            if uniformLBP == 1
                mapping=getmapping(8,'u2'); 
                [~, codeImg] = descriptor_LBP(gaborResIns,1,8,mapping,'nh');
                options.binVec{c} = 0:58;
            else                
                [~, codeImg] = descriptor_LBP(gaborResIns,1,8,'nh');
                options.binVec{c} = 0:255;
            end
            
            imgDesc(c).fea = codeImg; 
        end
    end
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LGBPHS_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            LGBPHS_hist = horzcat(LGBPHS_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LGBPHS_hist = LGBPHS_hist ./ sum(LGBPHS_hist);
        end
    else
        LGBPHS_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end