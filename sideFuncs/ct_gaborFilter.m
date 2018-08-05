function [ gaborMag ] = ct_gaborFilter(img,orienNum,scaleNum)

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
    
    [r,c] = size(img);
    filter_bank = construct_Gabor_filters_PhD(orienNum, scaleNum, [r, c]);

    result = filter_image_with_Gabor_bank_PhD(img,filter_bank,1);
    pixel_num = length(result)/(orienNum*scaleNum);

    gaborMag = zeros(r,c,orienNum,scaleNum);
    orien = 0;
    scale = 1;
    for m = 1 : (orienNum*scaleNum)
        orien = orien + 1;
        if orien == orienNum + 1
            orien = 1;
            scale = scale + 1;
        end
    %     insImg = reshape(result((m-1)*pixel_num+1:m*pixel_num,1),r,c);
        gaborMag(:,:,orien,scale) = reshape(result((m-1)*pixel_num+1:m*pixel_num,1),r,c);
    end
%     scale = 5;
%     for o = 1 : orienNum
%         subplot(1,orienNum,o); imshow(gaborMag(:,:,o,scale),[]);
%     end
end