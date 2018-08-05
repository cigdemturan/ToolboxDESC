function [ LDTP_hist, varargout ] = desc_LDTP( img, varargin )
    % DESC_LDTP applies Local Directional Texture Pattern
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               epsi - threshold value
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   LDTP_hist - feature histogram
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
    
    if nargin == 2
        options = varargin{1};
    else
        options = struct;
    end
    
    if isfield(options,'epsi')
        epsi = options.epsi;
    else
        epsi = 15;
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
%         subplot(2,4,i); imshow(uint8(abs(maskResponses(:,:,i))));
    end
    
    maskResponsesAbs = abs(maskResponses)/8;
    
    [~, ind] = sort(maskResponsesAbs(2:end-1,2:end-1,:),3);
    prin1 = ind(:,:,1);
    prin2 = ind(:,:,2); 
    
    linkList = {[2,3;2,1],[1,3;3,1],[1,2;3,2],[1,1;3,3],...
        [2,1;2,3],[3,1;1,3],[3,2;1,2],[3,3;1,1]};
    
    x_c = img(2:end-1,2:end-1,1);
    [rSize, cSize] = size(x_c);
    diffIntensity = zeros(rSize,cSize,8);
    
    for n = 1 : size(linkList,2)
        corner1 = linkList{n}(1,:);
        corner2 = linkList{n}(2,:);
        x_1 = img(corner1(1):corner1(1)+rSize-1,corner1(2):corner1(2)+cSize-1);
        x_2 = img(corner2(1):corner2(1)+rSize-1,corner2(2):corner2(2)+cSize-1);
        diffIntensity(:,:,n) = x_1 - x_2;
%         pattern = pattern + double(((x_1 - x_2) >= 0)) .* 2^(size(linkList,2)-n);
    end
    
    diffResP = zeros(rSize,cSize);
    diffResN = zeros(rSize,cSize);
    for d = 1 : 8
        diffResIns = diffIntensity(:,:,d);
        diffResP(prin1 == d) = diffResIns(prin1 == d);
        diffResN(prin2 == d) = diffResIns(prin2 == d);
    end
    
    diffResP(diffResP <= epsi & diffResP >= -epsi) = 0;
    diffResP(diffResP < -epsi) = 1;
    diffResP(diffResP > epsi) = 2;
    diffResN(diffResN <= epsi & diffResN >= -epsi) = 0;
    diffResN(diffResN < -epsi) = 1;
    diffResN(diffResN > epsi) = 2;
    
    imgDesc = 16*(prin1-1) + 4*diffResP + diffResN;
    
    uniqueBin = [0;1;2;4;5;6;8;9;10;16;17;18;20;21;22;24;25;26;32;33; ...
        34;36;37;38;40;41;42;48;49;50;52;53;54;56;57;58;64;65;66;68; ...
        69;70;72;73;74;80;81;82;84;85;86;88;89;90;96;97;98;100;101; ...
        102;104;105;106;112;113;114;116;117;118;120;121;122];
    
    options.binVec = uniqueBin;
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        LDTP_hist = hist(imgDesc(:),options.binVec);
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            LDTP_hist = LDTP_hist ./ sum(LDTP_hist);
        end
    else
        LDTP_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end