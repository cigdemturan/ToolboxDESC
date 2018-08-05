function mapping = getmapping(samples,mappingtype)
% ===================================================================
% GETMAPPING returns a structure containing a mapping table for LBP codes.
%  MAPPING = GETMAPPING(samples,MAPPINGTYPE) returns a
%  structure containing a mapping table for
%  LBP codes in a neighbourhood of samples sampling
%  points. Possible values for MAPPINGTYPE are
%       'u2'   for uniform LBP
%       'ri'   for rotation-invariant LBP
%       'riu2' for uniform rotation-invariant LBP.
%       'fathi12' for implementing the method by fathi et al. in 2012
%  Example:
%       I = imread('rice.tif');
%       MAPPING = getmapping(16,'riu2');
%       LBPHIST = lbp(I,2,16,MAPPING,'hist');
%  Now LBPHIST contains a rotation-invariant uniform LBP
%  histogram in a (16,2) neighbourhood.
% ===================================================================
numAllLBPs = 2^samples;
table = 0 : numAllLBPs-1;
newMax = 0; % number of patterns in the resulting LBP code
index  = 0;

% Uniform 2
if strcmp(mappingtype,'u2') || strcmp(mappingtype,'LBPu2') || strcmp(mappingtype,'LBPVu2GMPD2')
    newMax = samples*(samples-1) + 3;
    for i = 0 : numAllLBPs-1
        % rotate left
        j = bitset(bitshift(i,1,samples),1,bitget(i,samples));
        % number of 1 -> 0 and 0 -> 1 transitions in binary string
        % x is equal to the number of 1-bits in
        % XOR(x,Rotate left(x))
        numt = sum(bitget(bitxor(i,j),1:samples));
        if numt <= 2
            table(i+1) = index;
            index = index + 1;
        else
            table(i+1) = newMax - 1;
        end
    end
end


% Rotation invariant
if strcmp(mappingtype,'ri') 
    tmpMap = zeros(2^samples,1) - 1;
    for i = 0:2^samples-1
        rm = i;
        r  = i;
        for j = 1:samples-1
            r = bitset(bitshift(r,1,samples),1,bitget(r,samples)); % rotate left
            if r < rm
                rm = r;
            end
        end
        if tmpMap(rm+1) < 0
            tmpMap(rm+1) = newMax;
            newMax = newMax + 1;
        end
        table(i+1) = tmpMap(rm+1);
    end
end



% Uniform and Rotation invariant
if strcmp(mappingtype,'riu2') || strcmp(mappingtype,'MELBPVary') || strcmp(mappingtype,'AELBPVary') || ...
        strcmp(mappingtype,'GELBPEight') || strcmp(mappingtype,'CLBPEight') || ...
        strcmp(mappingtype,'ELBPEight') || strcmp(mappingtype,'LBPriu2Eight') || ...
        strcmp(mappingtype,'MELBPEight') || strcmp(mappingtype,'AELBPEight') || ...
        strcmp(mappingtype,'MELBPEightSch1') || strcmp(mappingtype,'MELBPEightSch2') || ...
        strcmp(mappingtype,'MELBPEightSch3') || strcmp(mappingtype,'MELBPEightSch4') || ...
        strcmp(mappingtype,'MELBPEightSch5') || strcmp(mappingtype,'MELBPEightSch6') || ...
        strcmp(mappingtype,'MELBPEightSch7') || strcmp(mappingtype,'MELBPEightSch8')|| ...
        strcmp(mappingtype,'MELBPEightSch9') || strcmp(mappingtype,'MELBPEightSch10') || ...
        strcmp(mappingtype,'MELBPEightSch0') || strcmp(mappingtype,'MELBPEightSch11')
    newMax = samples + 2;
    for i = 0:2^samples - 1
%         j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); % rotate left
        j = bitset(bitshift(i,1,'uint8'),1,bitget(i,samples)); % rotate left
        numt = sum(bitget(bitxor(i,j),1:samples));
        if numt <= 2
            table(i+1) = sum(bitget(i,1:samples));
        else
            table(i+1) = samples+1;
        end
    end
end


% *************************************************************************
if strcmp(mappingtype,'MELBPEightSch1Num')
    newMax = 2*(samples - 1);
    for i = 0:2^samples - 1
        j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); % rotate left
        numt = sum(bitget(bitxor(i,j),1:samples));
        if numt <= 2
            table(i+1) = sum(bitget(i,1:samples));
        else
            numOnesInLBP = sum(bitget(i,1:samples));
            table(i+1) = samples+numOnesInLBP-1;
        end
    end
end
% *************************************************************************


% *************************************************************************
if strcmp(mappingtype,'MELBPEightSch1Count')
    newMax = samples + 1;
    for i = 0:2^samples - 1
        numOnesInLBP = sum(bitget(i,1:samples));
        table(i+1) = numOnesInLBP;
    end
end
% *************************************************************************

mapping.table = table;
mapping.samples = samples;
mapping.num = newMax;

if strcmp(mappingtype,'')
    mapping.num = numAllLBPs;
end


