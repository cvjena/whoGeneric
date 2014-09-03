function hogFeature = computeHoGSizeNormalized ( imgfn )

    img = readImage( imgfn );
    [xsize,ysize] = size(img);

    load('bg15Scenes.mat');

    pos.x1=1;
    pos.y1=1;
    pos.x2=xsize;
    pos.y2=ysize;
    pos.im = imgfn;
    
    modeltemplate = initmodel('name', pos, bg15ScenesGray); 


    warpedImgRegular = warppos('doesntMatter', modeltemplate, pos);
%     imshow(warpedImgRegular{1})

    % compute HoG feature from the given image (size normalized)
    hogFeature = computeHOGs_WHO( img );

end