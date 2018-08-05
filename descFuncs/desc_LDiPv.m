function [ LDiPv_hist, varargout ] = desc_LDiPv( img, varargin )
    % DESC_LDiPV applies Local Directional Pattern Variance
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LDiPv_hist - feature histogram
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
    
    %Kirsch Mask
    Kirsch=cell(8,1);
    Kirsch{1}=[-3 -3 5;-3 0 5;-3 -3 5];
    Kirsch{2}=[-3 5 5;-3 0 5;-3 -3 -3];
    Kirsch{3}=[5 5 5;-3 0 -3;-3 -3 -3];
    Kirsch{4}=[5 5 -3;5 0 -3;-3 -3 -3];
    Kirsch{5}=[5 -3 -3;5 0 -3;5 -3 -3];
    Kirsch{6}=[-3 -3 -3;5 0 -3;5 5 -3];
    Kirsch{7}=[-3 -3 -3;-3 0 -3;5 5 5];
    Kirsch{8}=[-3 -3 -3;-3 0 5;-3 5 5];
    
    maskResponses = zeros(size(img,1),size(img,2),8);
    for i = 1 : size(Kirsch,1)
    %     maskResponses.(['kirsch' num2str(i)]) = conv2(img,Kirsch{i},'same');
        maskResponses(:,:,i) = conv2(img,Kirsch{i},'same');
    end
    
    maskResponsesAbs = abs(maskResponses);
    
    [~, ind] = sort(maskResponsesAbs,3,'descend');
    bit8array = zeros(size(img,1),size(img,2),8);
    bit8array(ind == 1 | ind == 2 | ind == 3) = 1;
    imgDesc = zeros(size(img));
    for r = 1 : size(img,1)
        codebit = reshape(bit8array(r,:,8:-1:1),size(img,2),[]);
        imgDesc(r,:) = bin2dec(num2str(codebit))';
    end
    
    uniqueBin = [7,11,13,14,19,21,22,25,26,28,35,37,38,41,42,44,49,50,52,56,67,69,...
        70,73,74,76,81,82,84,88,97,98,100,104,112,131,133,134,137,138,140,145,146,...
        148,152,161,162,164,168,176,193,194,196,200,208,224]';
    
    varianceImg = var(maskResponsesAbs,0,3);
    options.weight = varianceImg;
    options.binVec = uniqueBin;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LDiPv_hist = zeros(1,length(options.binVec));
        for i = 1 : length(options.binVec)
            LDiPv_hist(i) = sum(options.weight(imgDesc == options.binVec(i)));
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LDiPv_hist = LDiPv_hist ./ sum(LDiPv_hist);
        end
    else
        LDiPv_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end