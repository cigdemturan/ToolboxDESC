function [ MBC_hist, varargout ] = desc_MBC( img, varargin )
    % DESC_MBC applies Monogenic Binary Coding
    %
    % INPUT:
    %   img - the region that the descriptor would be applied
    %   options -
    %               mbcMode - 'A' -> amplitude, 
    %                           'O' -> orientation, 
    %                           'P' --> phase
    %               gridHist - [numRow, numCol] 
    %                           or num (scalar) if numRow == numCol
    %               mode - 'nh' for normalized hist
    %
    % OUTPUT:
    %   MBC_hist - feature histogram
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
    %   Meng Yang, Lei Zhang, Simon C.K. Shiu, and David Zhang,"Monogenic Binary Coding:
    %   An efficient Local Feature Extraction Approach to Face Recognition", IEEE Trans.
    %   on Information Forensics and Security, vol. 7, no. 6, pp. 1738-1751, Dec. 2012.
    %
    %       since the code partially copied from 
    %               Monogeic Binary Coding (MBC), Version 1.0
    %               Copyright(c) 2013  Meng YANG, Lei Zhang, Simon C.K. Shiu and David Zhang
    %               All rights reserved.
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
    
    if ~isfield(options,'mbcMode')
        options.mbcMode = 'A';
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
    
    %----------------------------------paramter name in the paper--
        minWaveLength       =  4;          %lambda_min
        sigmaOnf            =  0.64;       %miu
        mult                =  1.7;        %delta_ratio
        nscale              =  3;          %the number of scales
        neigh               =  8;
        MAPPING             =  0;
        %-------process train--------------------------------------------------

    if isfield(options,'mbcMode') && strcmp(options.mbcMode, 'A')
        
        %----------------------------------paramter name in the paper--
        orientWrap          =  0;           
        radius              =  3;        
        %-------process train--------------------------------------------------
        [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(img, ...
            nscale, minWaveLength, mult, sigmaOnf, orientWrap);
        for v = 1 : nscale
            Tem_img = uint8((A1{v}-min(A1{v}(:)))./(max(A1{v}(:))-min(A1{v}(:))).*255);
            LBPHIST=descriptor_LBP(Tem_img,radius,neigh,MAPPING,'i');
            matrix2=zeros(size(h1f1{v})); matrix3=zeros(size(h2f1{v}));
            matrix2(h1f1{v}>0)=0; matrix2(h1f1{v}<=0)=1; matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
            matrix3(h2f1{v}>0)=0; matrix3(h2f1{v}<=0)=1; matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
            N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);%max=256;
            N_LBPHIST=uint16(N_LBPHIST);
            imgDesc(v).fea = N_LBPHIST; options.binVec{v} = 0:1023;
        end
    elseif isfield(options,'mbcMode') && strcmp(options.mbcMode, 'O')
        %----------------------------------paramter name in the paper--
        orientWrap          =  0;
        radius              =  4;
        %-------process train--------------------------------------------------
        
        [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(img, ...
            nscale, minWaveLength, mult, sigmaOnf, orientWrap);
        
        for v=1:nscale
            Tem_img=uint16((theta1{v}-min(theta1{v}(:)))./(max(theta1{v}(:))-min(theta1{v}(:))).*360);
            LBPHIST=lxp_phase(Tem_img,radius,neigh,0,'i');
            matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
            matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
            matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
            N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);%max=256;
    %         N_LBPHIST=double(LBPHIST);%max=256;
            N_LBPHIST=uint16(N_LBPHIST);
            imgDesc(v).fea = N_LBPHIST; options.binVec{v} = 0:1023;
        end
    elseif isfield(options,'mbcMode') && strcmp(options.mbcMode, 'P')
        %----------------------------------paramter name in the paper--
        orientWrap          =  1;
        radius              =  4;
        %-------process train--------------------------------------------------
        
        [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(img, ...
            nscale, minWaveLength, mult, sigmaOnf, orientWrap);
        
        for v=1:nscale
            Tem_img=uint16((psi1{v}-min(psi1{v}(:)))./(max(psi1{v}(:))-min(psi1{v}(:))).*360);
            LBPHIST=lxp_phase(Tem_img,radius,neigh,0,'i');
            matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
            matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
            matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
            N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);
            N_LBPHIST=uint16(N_LBPHIST);
            imgDesc(v).fea = N_LBPHIST; options.binVec{v} = 0:1023;
        end
        
    end
    
    if nargout == 2
        varargout{1} = imgDesc;
    end
    
    if rowNum == 1 && colNum == 1
        MBC_hist = [];
        for s = 1 : length(imgDesc)
            imgReg = imgDesc(s).fea;
            hh = hist(imgReg(:),options.binVec{s});
            MBC_hist = horzcat(MBC_hist,hh);
        end
        if isfield(options,'mode') && strcmp(options.mode,'nh')
            MBC_hist = MBC_hist ./ sum(MBC_hist);
        end
    else
        MBC_hist = ct_gridHist(imgDesc, rowNum, colNum, options);
    end
end