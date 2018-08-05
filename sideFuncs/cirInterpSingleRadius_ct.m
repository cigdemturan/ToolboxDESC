function blocks = cirInterpSingleRadius_ct(img,lbpPoints,lbpRadius)

% ************************************************************************
%   Copyright (c) 2016, Li Liu
%   All rights reserved.
% ************************************************************************

[imgH,imgW] = size(img);

imgNewH = imgH - 2*lbpRadius;
imgNewW = imgW - 2*lbpRadius;

% the interpolated img
blocks = zeros(lbpPoints,imgNewH*imgNewW);

radius = lbpRadius;
neighbors = lbpPoints;
spoints = zeros(neighbors,2);

% Determine the dimensions of the input img.
[ysize,xsize] = size(img);
% Angle step
angleStep = 2 * pi / neighbors;
for i = 1 : neighbors
    spoints(i,1) = -radius * sin((i-1)*angleStep);
    spoints(i,2) = radius * cos((i-1)*angleStep);
end

miny = min(spoints(:,1));
maxy = max(spoints(:,1));
minx = min(spoints(:,2));
maxx = max(spoints(:,2));

% Block size, each LBP code is computed within angleStep block of size bsizey*bsizex
bsizey = ceil(max(maxy,0)) - floor(min(miny,0))+1;
bsizex = ceil(max(maxx,0)) - floor(min(minx,0))+1;

% Coordinates of origin (0,0) in the block
origy = 1 - floor(min(miny,0));
origx = 1 - floor(min(minx,0));

% Minimum allowed size for the input img depends
% on the radius of the used LBP operator.
if(xsize < bsizex || ysize < bsizey)
    error('Too small input img. Should be at least (2*radius+1) x (2*radius+1)');
end

% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Compute the LBP code img
for i = 1 : neighbors
    y = spoints(i,1) + origy;
    x = spoints(i,2) + origx;
    % Calculate floors, ceils and rounds for the x and y.
    fy = floor(y);
    cy = ceil(y);
    ry = round(y);
    
    fx = floor(x);
    cx = ceil(x);
    rx = round(x);
    
    % Check if interpolation is needed.
    if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
        % Interpolation is not needed, use original datatypes
        imgNew = img(ry:ry+dy,rx:rx+dx);
        blocks(i,:) = imgNew(:)';
    else
        % Interpolation needed, use double type images
        ty = y - fy;
        tx = x - fx;
        
        % Calculate the interpolation weights.
        w1 = (1 - tx) * (1 - ty);
        w2 =      tx  * (1 - ty);
        w3 = (1 - tx) *      ty ;
        w4 =      tx  *      ty ;
        % Compute interpolated pixel values
        imgNew = w1*img(fy:fy+dy,fx:fx+dx) + w2*img(fy:fy+dy,cx:cx+dx) + ...
            w3*img(cy:cy+dy,fx:fx+dx) + w4*img(cy:cy+dy,cx:cx+dx);
        blocks(i,:) = imgNew(:)';
    end
end % loop neighbors

end % end of the function