function out = showWeightVectorHOG( w, settings )
% function out = showWeightVectorHOG( w, settings )
% 
% author: Alexander Freytag
% date  : 27-02-2014 (dd-mm-yyyy)
% 
% BRIEF :
%   Given a weight vector w obtained by training a model with DPM HOG features, 
%   positive and negative components are displayed separately
% 
% INPUT :
%    w       --  weight vector of model
%    settings
%            --  (optional), struct with possible fields, e.g.,
%                'b_closeImg', ...
% 
% OUTPUT :
%    out     -- (optional), the resulting image of visualized model

    %% ( 0 ) check input
       
    if ( nargin  < 2 )
        settings = [];
    end
    
    b_closeImg    = getFieldWithDefault ( settings, 'b_closeImg',   false);
    b_removeAxis  = getFieldWithDefault ( settings, 'b_removeAxis', true);
    s_destination = getFieldWithDefault ( settings, 's_destination', '');
        
    if ( isempty (s_destination) ) 
        b_saveAsEPS = false;
    else
        b_saveAsEPS = true;
    end
    
    
    widthOfCell  = getFieldWithDefault( settings, 'widthOfCell',  20 ); 
    heightOfCell = getFieldWithDefault( settings, 'heightOfCell', 20 );
 

    %% ( 1 ) Make pictures of positive and negative weights        

    
    % compute the visualization
    imPos = myHOGpicture( w,  widthOfCell, heightOfCell );
    imNeg = myHOGpicture( -w, widthOfCell, heightOfCell );
    
    scale = max( [w(:); -w(:)] );
    imPos = imPos ./ scale;
    imNeg = imNeg ./ scale;    
    
    
    
    %% ( 2 ) Put pictures together
    % 
    % a bit of padding for nice visualization
    buff = 10;
    imPos = myPadArray( imPos, [buff buff], 0.5);
    imNeg = myPadArray( imNeg, [buff buff], 0.5 );
    
    im = [imPos imNeg];
       

    %% ( 3 ) saturate image information out of [0,1]
    
    im(im < 0) = 0;
    im(im > 1) = 1;
    
    % scale to [0,255]
    im = im*255;    
    
    % convert to uint8 as usually done for images
    im = uint8(im);
    
  
    
    %% ( 4 ) draw figure or output result
    if ( nargout == 0 )    
    
        % create new figure
        figHandle = figure;

        imagesc(im);
        colormap gray;

        % make images beeing displayed correctly, i.e., not skewed
        axis image;
        %don't show axis ticks
        set(gca,'Visible','off');    

        if ( b_removeAxis )
            set(gca,'Visible','off')
        end

        if ( b_closeImg )
            pause
            close ( figHandle );
        end    
    else    
      out = im;
    end        

    
    if ( b_saveAsEPS )
        print( '-depsc', '-r300' , s_destination );
    end
    
end
