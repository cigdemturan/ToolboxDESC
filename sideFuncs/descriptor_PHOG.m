function [p_hist, bh_roi, bv_roi] = descriptor_PHOG(I,bin,angle,L,roi)
% anna_PHOG Computes Pyramid Histogram of Oriented Gradient over a ROI.
%               
% [BH, BV] = anna_PHOG(I,BIN,ANGLE,L,ROI) computes phog descriptor over a ROI.
% 
% Given and image I, phog computes the Pyramid Histogram of Oriented Gradients
% over L pyramid levels and over a Region Of Interest

%IN:
%	I - Images of size MxN (Color or Gray)
%	bin - Number of bins on the histogram 
%	angle - 180 or 360
%   L - number of pyramid levels
%   roi - Region Of Interest (ytop,ybottom,xleft,xright)
%
%OUT:
%	p - pyramid histogram of oriented gradients
%
% Authors: Anna Bosch and Andrew Zisserman 
Img = I;
if nargin == 1
    bin = 8;
    angle = 360;
    L = 2;
    roi = [1;size(I,1);1;size(I,2)];
end
if size(Img,3) == 3
    G = rgb2gray(Img);
else
    G = Img;
end
bh = [];
bv = [];

if sum(sum(G))>100
    E = edge(G,'canny');
    [GradientX,GradientY] = gradient(double(G));
%     GradientYY = gradient(GradientY);
    Gr = sqrt((GradientX.*GradientX)+(GradientY.*GradientY));
            
    index = GradientX == 0;
    GradientX(index) = 1e-5;
            
    YX = GradientY./GradientX;
    if angle == 180, A = ((atan(YX)+(pi/2))*180)/pi; end
    if angle == 360, A = ((atan2(GradientY,GradientX)+pi)*180)/pi; end
                                
    [bh, bv] = anna_binMatrix(A,E,Gr,angle,bin);
else
    bh = zeros(size(I,1),size(I,2));
    bv = zeros(size(I,1),size(I,2));
end

bh_roi = bh(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
bv_roi = bv(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
% p = anna_phogDescriptor(bh_roi,bv_roi,L,bin);
% p = p';
p_hist = [];
%s = sprintf('%s.txt',I);
%dlmwrite(s,p);
