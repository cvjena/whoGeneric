function im = readImage( s_imageName, settings )
% function im = readImage( s_imageName, settings )
% 
% author: Alexander Freytag
% date:   31-03-2014 ( dd-mm-yyyy )
% 
% BRIEF:  read an image from filename, possible repeate a gray value image
%         to result in 3 dimensions (pseudo-RGB)
% 
% INPUT: 
%         s_imageName -- char array ( filename to image )
%         settings    -- struct (optional), with useable fields
%                        'b_resizeImageToStandardSize',
%                        'i_standardImageSize'
% 
% OUTPUT:
%         im          -- h x w x 3 uint8 image
% 
    if( nargin < 2 ) 
        settings = [];
    end

    %% (1) READ IMAGE FROM FILENAME
    im = imread( s_imageName );
    
    %% (2) RESIZING TO STANDARD SIZE IF DESIRED
    if ( getFieldWithDefault (settings, 'b_resizeImageToStandardSize', false ) )
        
        i_standardImageSize = getFieldWithDefault ( settings, 'i_standardImageSize', [128,128]);
        
        if ( ndims(i_standardImageSize) == 1)
            i_standardImageSize = repmat(i_standardImageSize, [1,2]);
        end
        
       im = imresize(im, i_standardImageSize);  
    end

    %% (3) MAKE IMAGE ALWAYS TO BE COLOR, OR PSEUDO COLOR
    if( ndims( im ) == 2 )
        im = repmat ( im, [1,1,3] );
    end
    
end

