function mapping = get_mapping_info_ct(lbpRadius,lbpPoints,lbpMethod)

% ************************************************************************
%   Copyright (c) 2016, Li Liu
%   All rights reserved.
% ************************************************************************

global blockSize;
% global lbpRadius;
% global lbpPoints;
blockSize = lbpRadius*2+1;

if lbpPoints == 24 && strcmp(lbpMethod,'LBPriu2')
    load mappingLBPpoints24RIU2;
elseif lbpPoints == 16 && strcmp(lbpMethod,'LBPriu2')
    load mappingLBPpoints16RIU2;
elseif lbpPoints == 16 && strcmp(lbpMethod,'MELBPVary')
    load mappingLBPpoints16RIU2;
elseif lbpPoints == 24 && strcmp(lbpMethod,'AELBPVary')
    load mappingLBPpoints24RIU2;
else
    mapping = getmapping_mrelbp(lbpPoints,lbpMethod);
end

end % the end of the function