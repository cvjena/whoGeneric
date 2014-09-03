% Compile mex functions
%
% feature extraction
mex -O features/featuresHOGGrayScale.cc -o features/featuresHOGGrayScale
mex -O features/featuresHOGColor.cc     -o features/featuresHOGColor
mex -O features/featuresHOGorig.cc      -o features/featuresHOGorig
%
% image resizing ( by scalar factors )
mex -O features/resizeGrayScale.cc      -o features/resizeGrayScale
mex -O features/resizeColor.cc          -o features/resizeColor
%
% image shrinking ( always by factor of 2 )
mex -O features/reduceGrayScale.cc      -o features/reduceGrayScale
mex -O features/reduceColor.cc          -o features/reduceColor
%
% discrete convolutions
mex -O features/fconv2D.cc              -o features/fconv2D
mex -O features/fconv3D.cc              -o features/fconv3D
