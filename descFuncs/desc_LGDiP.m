function [LGDiP_hist, varargout] = desc_LGDiP(img, varargin)
    % DESC_LGDIP applies Local Gabor Directional Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LGDiP_hist - feature histogram
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
    %   Vitomir Štruc and Nikola Paveši?, "The Complete Gabor-Fisher Classifier for Robust 
    %   Face Recognition," EURASIP Advances in Signal Processing, vol. 2010, 26
    %   pages, doi:10.1155/2010/847680, 2010.
    %
    %   Vitomir Štruc and Nikola Paveši?, "Gabor-Based Kernel Partial-Least-Squares 
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

    uniqueBin = [7,11,13,14,19,21,22,25,26,28,35,37,38,41,42,44,49,50,52,56,67,69,...
        70,73,74,76,81,82,84,88,97,98,100,104,112,131,133,134,137,138,140,145,146,...
        148,152,161,162,164,168,176,193,194,196,200,208,224]';
    
    [ro,co] = size(img);
    imgDesc = struct;
    
    gaborMag = abs(ct_gaborFilter(img,8,5));
    for scale = 1 : 5
        [~, ind] = sort(gaborMag(:,:,:,scale),3,'descend');
        bit8array = zeros(ro,co,8);
        bit8array(ind == 1 | ind == 2 | ind == 3) = 1;
        codeImg = zeros(ro,co);
        for r = 1 : ro
            codebit = reshape(bit8array(r,:,8:-1:1),size(img,2),[]);
            codeImg(r,:) = bin2dec(num2str(codebit))';
        end

        imgDesc(scale).fea = codeImg;
        options.binVec{scale} = uniqueBin;
    end
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LGDiP_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            LGDiP_hist = horzcat(LGDiP_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LGDiP_hist = LGDiP_hist ./ sum(LGDiP_hist);
        end
    else
        LGDiP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end