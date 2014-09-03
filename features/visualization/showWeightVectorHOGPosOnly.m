function out = showWeightVectorHOGPosOnly( w, settings )
% function out = showWeightVectorHOGPosOnly( w, settings )
% 
% author: Alexander Freytag
% date  : 14-02-2014 (dd-mm-yyyy)
% 
% BRIEF :
%   Given a weight vector w obtained by training a model with DPM HOG features, 
%   positive components are displayed
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
 

    %% ( 1 ) Make pictures of positive weights        
    
    wwp = foldHOG(w);
    scale = max(wwp(:));
    scale = double(255)/scale;
    

    % compute the visualization
    im = myHOGpicture(wwp, widthOfCell, heightOfCell );
    % scale to [0,255]
    im = im*scale;

    % 
    % a bit of padding for nice visualization
    buff = 10;
    im = myPadArray( im, [buff buff], 200 );

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

function f = foldHOG(w)
    % f = foldHOG(w)
    % Condense HOG features into one orientation histogram.
    % Used for displaying a feature.

    f=max(w(:,:,1:9),0)+max(w(:,:,10:18),0)+max(w(:,:,19:27),0);
end
