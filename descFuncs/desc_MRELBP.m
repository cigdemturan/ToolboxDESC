function [MRELBP_hist, varargout] = desc_MRELBP(img, varargin)
    % DESC_MRELBP applies Median Robust Extended Local Binary Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   MRELBP_hist - feature histogram
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
    %   revised from
    %       Copyright (c) 2016, Li Liu
    %       All rights reserved.
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
    
    imSize = size(img,1);
    lbpRadiusSet = [2 4 6 8];
    img = samp_prepro(img);
    for idxLbpRadius = 1 : 4
        lbpRadius = lbpRadiusSet(idxLbpRadius);

        if idxLbpRadius > 1
            lbpRadiusPre = lbpRadiusSet(idxLbpRadius-1);
        else
            lbpRadiusPre = 0;
        end

        lbpPoints = 8;
        lbpMethod = 'MELBPEightSch1';
        mapping = get_mapping_info_ct(lbpRadius,lbpPoints,lbpMethod);
        numLBPbins = mapping.num;

        imgExt = padarray(img,[1 1],'symmetric','both');
        imgblks = im2col(imgExt,[3 3],'sliding');
        a = median(imgblks);
        b = reshape(a,size(img));
        CImg = b(lbpRadius+1:end-lbpRadius,lbpRadius+1:end-lbpRadius);
        CImg = CImg(:) - mean(CImg(:));
        CImg(CImg >= 0) = 2;
        CImg(CImg < 0) = 1;
        if lbpRadius == 2
            filWin = 3;
            halfWin = (filWin-1)/2;
            imgExt = padarray(img,[halfWin halfWin],'symmetric','both');
            imgblks = im2col(imgExt,[filWin filWin],'sliding');
            % each column of imgblks represent a feature vector
            imgMedian = median(imgblks);
            imgCurr = reshape(imgMedian,size(img));
            NILBPImage = NILBP_Image_ct(imgCurr,lbpPoints,mapping,'image',lbpRadius);
            NILBPImage = NILBPImage(:);

            histNI = hist(NILBPImage,0:(numLBPbins-1));
            NILBPImage = NILBPImage + 1;

            RDLBPImage = RDLBP_Image_SmallestRadiusOnly(b,imgCurr,lbpRadius,lbpPoints,mapping,'image');
            RDLBPImage = RDLBPImage(:);
            histRD = hist(RDLBPImage,0:(numLBPbins-1));
            RDLBPImage = RDLBPImage + 1;
        else
            if mod(lbpRadius,2) == 0
                filWin = lbpRadius + 1;
            else
                filWin = lbpRadius;
            end
            halfWin = (filWin-1)/2;
            imgExt = padarray(img,[halfWin halfWin],'symmetric','both');
            imgblks = im2col(imgExt,[filWin filWin],'sliding');
            % each column of imgblks represents a feature vector
            imgMedian = median(imgblks);
            imgCurr = reshape(imgMedian,size(img));
            NILBPImage = NILBP_Image_ct(imgCurr,lbpPoints,mapping,'image',lbpRadius);
            NILBPImage = NILBPImage(:);
            histNI = hist(NILBPImage,0:(numLBPbins-1));
            NILBPImage = NILBPImage + 1;

            if mod(lbpRadiusPre,2) == 0
                filWin = lbpRadiusPre + 1;
            else
                filWin = lbpRadiusPre;
            end

            halfWin = (filWin-1)/2;
            imgExt = padarray(img,[halfWin halfWin],'symmetric','both');
            imgblks = im2col(imgExt,[filWin filWin],'sliding');
            imgMedian = median(imgblks);
            imgPre = reshape(imgMedian,size(img));

            RDLBPImage = NewRDLBP_Image(imgCurr,imgPre,lbpRadius,lbpRadiusPre,lbpPoints,mapping,'image');
            RDLBPImage = RDLBPImage(:);
            histRD = hist(RDLBPImage,0:(numLBPbins-1));
            RDLBPImage = RDLBPImage + 1; 
        end

        imgDesc(idxLbpRadius).fea.CImg = reshape(CImg,imSize - 4*idxLbpRadius,[]);
        imgDesc(idxLbpRadius).fea.NILBPImage = reshape(NILBPImage,imSize - 4*idxLbpRadius,[]);
        imgDesc(idxLbpRadius).fea.RDLBPImage = reshape(RDLBPImage,imSize - 4*idxLbpRadius,[]);
    end
    
    options.mrelbpHist = 1; options.binVec = 800; options.numLBPbins = numLBPbins;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        MRELBP_hist = [];
        for i = 1 : 4
            Joint_CINIRD = zeros(options.numLBPbins,options.numLBPbins,2);
            CImg = reshape(imgDesc(i).fea.CImg,[],1);
            NILBPImage = reshape(imgDesc(i).fea.NILBPImage,[],1);
            RDLBPImage = reshape(imgDesc(i).fea.RDLBPImage,[],1);
            for ih = 1 : length(NILBPImage)
                Joint_CINIRD(NILBPImage(ih),RDLBPImage(ih),CImg(ih)) = ...
                    Joint_CINIRD(NILBPImage(ih),RDLBPImage(ih),CImg(ih)) + 1;
            end
            Joint_CINIRD = Joint_CINIRD(:)';
            MRELBP_hist = horzcat(MRELBP_hist,Joint_CINIRD);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            MRELBP_hist = MRELBP_hist ./ sum(MRELBP_hist);
        end
    else
        MRELBP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end