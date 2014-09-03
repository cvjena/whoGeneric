% function hogFeature = featuresHOGorig( img, sbin );
% 
% BRIEF:
%    Compute an array of extended HOG features for a given color image. 
%    No support for color images. Leaves a boundary of sbin pixels at 
%    the border of the image "unused".
% 
%    Advantage:    block normalization well posed on boundary
%    Disadvantage: k*sbin pixel result in k-2 cells
%
% INPUT:
%    img   -- (x,y,3) double array, input image
%    sbin  -- double scalar, number of pixels each cell covers in x and y
%             direction
%
% OUTPUT:
%    hogFeature   -- (x/sbin -2, y/sbin -2, 32) double array,
%                    extracted hog array, last dim equals 0
%   
% NOTE:
%    Don't miss to mex (compile) the .cc-file!
% 
% author: Alexander Freytag
% last update: 11-03-2014 ( dd-mm-yyyy )
% 