function histAll = ct_gridHist(imgDesc, rowNum, colNum, options)
    % CT_GRIDHIST divides the image to subregions (rowNum*colNum)
    %       and calculates the histogram from those subregions
    %
    % INPUT:
    %   imgDesc - the descriptor image from the descriptor function
    %   rowNum - # of row required for the grid
    %   colNum - # of columns required for the grid
    %   options -
    %               disR - # of rows to be discarded from each row (from left and right)
    %               disC - # of columns to be discarded from each column (from above and bottom)
    %               mode - 'nh' for normalized hist
    %           For other options, please refer to the considering
    %           descriptor function
    %
    % OUTPUT:
    %   histAll - feature histogram
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
    if isfield(options,'disR')
        disR = options.disR;
    else
        disR = 0;
    end
    
    if isfield(options,'disC')
        disC = options.disC;
    else
        disC = 0;
    end
    
    incSR = 1 + disR;
    incER = rowNum - disR;
    incSC = 1 + disC;
    incEC = colNum - disC;
        
    binVec = options.binVec;
    
    if isstruct(imgDesc)
        if isfield(options,'wldHist') && options.wldHist == 1
            [rSize, cSize] = size(imgDesc(1).fea.GO);
        elseif isfield(options,'mrelbpHist') && options.mrelbpHist == 1
            %%do nothing
        else
            [rSize, cSize] = size(imgDesc(1).fea);
        end
    else
        [rSize, cSize] = size(imgDesc);
    end
    count = 0;
    histAll = [];
    
    if isfield(options,'mrelbpHist') && options.mrelbpHist == 1
        histRegion = cell((rowNum-2*disR)*(colNum-2*disC),1);
        
        for i = 1 : 4
%             display(['level ' num2str(i)]);
            countReg = 0;
            rSize = size(imgDesc(i).fea.CImg,1);
            cSize = size(imgDesc(i).fea.CImg,2);
            for y = incSR : incER
                for x = incSC : incEC
                    numLBPbins = options.numLBPbins;
                    Joint_CINIRD = zeros(numLBPbins,numLBPbins,2);
                    countReg = countReg + 1;
%                     display(char(num2str(countReg)));
                    xMin = (x-1)*(cSize/colNum)+1;
                    yMin = (y-1)*(rSize/rowNum)+1;
                    width = cSize/colNum - 1;
                    height = rSize/rowNum - 1;
                    rect = [xMin yMin width height];
                    
                    CImg = reshape(imcrop(imgDesc(i).fea.CImg,rect),[],1);
                    NILBPImage = reshape(imcrop(imgDesc(i).fea.NILBPImage,rect),[],1);
                    RDLBPImage = reshape(imcrop(imgDesc(i).fea.RDLBPImage,rect),[],1);
                    
                    for ih = 1 : length(NILBPImage)
                        Joint_CINIRD(NILBPImage(ih),RDLBPImage(ih),CImg(ih)) = ...
                            Joint_CINIRD(NILBPImage(ih),RDLBPImage(ih),CImg(ih)) + 1;
                    end
                    Joint_CINIRD = Joint_CINIRD(:)';
                    if i == 1
                        histRegion{countReg} = Joint_CINIRD;
                    else
                        histRegion{countReg} = horzcat(histRegion{countReg},Joint_CINIRD);
                    end
                end
            end
        end
        histAll = histRegion{1};
        for h = 2 : length(histRegion)
            histAll = horzcat(histAll,histRegion{h});
        end
%         histAll = histAll ./ sum(histAll);
    else
        for y = incSR : incER
            for x = incSC : incEC
                count = count + 1;
                xMin = (x-1)*(cSize/colNum)+1;
                yMin = (y-1)*(rSize/rowNum)+1;
                width = cSize/colNum - 1;
                height = rSize/rowNum - 1;
                rect = [xMin yMin width height];

                if ~isstruct(imgDesc)
                    % crop the image for the region
                    imgReg = imcrop (imgDesc,rect);
                    % 
                    if isfield(options,'weight')
                        histIns = zeros(1,length(binVec));
                        weig = imcrop(options.weight,rect);
                        for i = 1 : length(binVec)
                            histIns(i) = sum(weig(imgReg == binVec(i)));
                        end
    %                     size(histIns)
                    else
                        histIns = hist(imgReg(:),binVec);
                    end

                    if isfield(options,'selected') && ~isempty(options.selected)
                        histIns = histIns(options.selected);
                    end
                else
                    if isfield(options,'phogHist') && options.phogHist == 1
    %                     display('here2')
                        bh = imcrop(imgDesc(1).fea,rect);
    %                     display(char(num2str(sum(sum(double((bh)))))))
                        bv = imcrop(imgDesc(2).fea,rect);
    %                     display(char(num2str(sum(sum(double(isnan(bv)))))))
                        histIns = anna_phogDescriptor(bh,bv,options.L,options.bin)';
    %                     display(char(num2str(sum((double(isnan(histIns)))))))
                    else
                        histIns = [];
                        for s = 1 : length(imgDesc)

                            if isfield(options,'wldHist') && options.wldHist == 1
                                imgGO = imcrop(imgDesc(s).fea.GO,rect);
                                imgDE = imcrop(imgDesc(s).fea.DE,rect);

                                range = 360 / options.T;
                                imgGO = floor(imgGO ./ range);

                                range = 180 / options.N;
                                imgDE = floor(imgDE ./ range);

                                hh = [];
                                for t = 0 : options.T - 1
                                    orien = imgDE(imgGO == t);
                                    orienHist = hist(orien,0:1:options.N-1);
                                    hh = horzcat(hh,orienHist);
                                end
                            else
                                imgReg = imcrop(imgDesc(s).fea,rect);
                                hh = hist(imgReg(:),binVec{s});
                                if isfield(options,'selected') && ~isempty(selected)
                                    hh = hh(selected);
                                end

                            end
                            histIns = horzcat(histIns,hh);
                        end
                    end
                end
                normHistIns = histIns ./ sum(histIns);
                normHistIns(isnan(normHistIns)) = 0;
                histAll = horzcat(histAll,normHistIns); 
            end
        end
        histAll = histAll ./ sum(histAll);
    end
end