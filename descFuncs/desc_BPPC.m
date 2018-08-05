function [BPPC_hist, varargout] = desc_BPPC(img, varargin)
    % DESC_BPPC applies Binary Pattern of Phase Congruency
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   BPPC_hist - feature histogram
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
    %   Peter Kovesi, "Image Features From Phase Congruency". Videre: A
    %   Journal of Computer Vision Research. MIT Press. Volume 1, Number 3,
    %   Summer 1999 http://mitpress.mit.edu/e-journals/Videre/001/v13.html
    %
    %   Peter Kovesi, "Phase Congruency Detects Corners and
    %   Edges". Proceedings DICTA 2003, Sydney Dec 10-12
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
    
    [~, ~, phaseAngle2, ~, pc, EO] = phasecong3(img, 4, 6, 3);
    imgDesc = struct;
    phaseAngle = phaseAngle2(2:end-1,2:end-1);
    for o = 1 : 6
        imgDesc(o).pc = pc{o};
        
        mapping=getmapping(8,'u2'); 
        [~, codeImg] = descriptor_LBP(imgDesc(o).pc,1,8,mapping,'nh');
% 
        angleInd = floor(phaseAngle./60);
        imgDesc(o).fea = codeImg + angleInd * 59;
        options.binVec{o} = 0:176;
    end
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        BPPC_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            BPPC_hist = horzcat(BPPC_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            BPPC_hist = BPPC_hist ./ sum(BPPC_hist);
        end
    else
        BPPC_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
    
end