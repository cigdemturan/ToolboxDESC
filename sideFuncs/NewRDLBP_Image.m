function result = NewRDLBP_Image(img,imgPre,lbpRadius,lbpRadiusPre,lbpPoints,mapping,mode)

% ************************************************************************
%   Copyright (c) 2016, Li Liu
%   All rights reserved.
% ************************************************************************

blocks1 = cirInterpSingleRadiusNew(img,lbpPoints,lbpRadius);
blocks1 = blocks1';  

imgPre = imgPre(lbpRadius-lbpRadiusPre+1:end-(lbpRadius-lbpRadiusPre),lbpRadius-lbpRadiusPre+1:end-(lbpRadius-lbpRadiusPre));
blocks2 = cirInterpSingleRadiusNew(imgPre,lbpPoints,lbpRadiusPre);
blocks2 = blocks2';  

radialDiff = blocks1 - blocks2;

radialDiff(radialDiff >= 0) = 1;
radialDiff(radialDiff < 0) = 0;

bins = 2^lbpPoints;
weight = 2.^(0:lbpPoints-1);
radialDiff = radialDiff .* repmat(weight,size(radialDiff,1),1);
% mapping = getmapping(lbpPoints,'riu2');

radialDiff = sum(radialDiff,2);
result = radialDiff;
% Apply mapping if it is defined
if isstruct(mapping)
    bins = mapping.num;
    for i = 1:size(result,1)
        for j = 1:size(result,2)
            result(i,j) = mapping.table(result(i,j)+1);
        end
    end
end


if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
    % Return with LBP histogram if mode equals 'hist'.
    result = hist(result(:),0:(bins-1));
    if (strcmp(mode,'nh'))
        result = result/sum(result);
    end
else
    % Otherwise return a matrix of unsigned integers
    if ((bins-1) <= intmax('uint8'))
        result = uint8(result);
    elseif ((bins-1) <= intmax('uint16'))
        result = uint16(result);
    else
        result = uint32(result);
    end
end








