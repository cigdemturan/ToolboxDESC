function result = NILBP_Image_ct(img,lbpPoints,mapping,mode,lbpRadius)

% ************************************************************************
%   Copyright (c) 2016, Li Liu
%   All rights reserved.
% ************************************************************************

blocks = cirInterpSingleRadius_ct(img,lbpPoints,lbpRadius);  
blocks = blocks'; 
blocks = blocks - repmat(mean(blocks,2),1,size(blocks,2));

blocks(blocks >= 0) = 1;
blocks(blocks < 0) = 0;

weight = 2.^(0:lbpPoints-1);
blocks = blocks .* repmat(weight,size(blocks,1),1);

blocks = sum(blocks,2);
result = blocks;
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
    % result = reshape(result,size(imgTemp));
    if ((bins-1) <= intmax('uint8'))
        result = uint8(result);
    elseif ((bins-1) <= intmax('uint16'))
        result = uint16(result);
    else
        result = uint32(result);
    end
end