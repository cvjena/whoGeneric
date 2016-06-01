function BG = trainBGwithArbitraryFeatures( allImages, settings )
% function BG = trainBGwithArbitraryFeatures( allImages, settings )
% 
% BRIEF
%    Trains a spatial autocorrelation function from a list of images
% 
% OUTPUT
% ...TODO
% 
% author: Alexander Freytag
% date:   13-02-2014 (dd-mm-yyyy)

    %% (1) check input
    
    order               = settings.order;
    
    interval            = settings.interval;
    
    % number of cells in every dimension
    i_binSize          = settings.i_binSize;
    
    % those three assignments need to be done here already, since the BG
    % object is passed to pyramid construction methods
    % (featPyramidGeneric), e.g., in line 84 (currently)
    BG.i_binSize  = i_binSize;
    BG.interval   = interval;  
    % size of root filter in cells
    % we want to extract at least two cells per dim to ensure save
    % calcaluations (strange things happened if set to [1,1] only)
    BG.i_numCells = [2,2];      
    
    i_truncDim = getFieldWithDefault ( settings, 'i_truncDim', -1 );
    
    
    
    %NOTE perhaps we should explicitely specify to NOT use any padding at
    %all... 
    

    %% (2) set necessary variables
    % Ignoring an empty feature dimension? For DPM HOG features, this is 
    % an empty (===0) truncation feature
    
    % if no dim was specified, we compare against the feature types we
    % know...
    if ( i_truncDim < 0 )
        if ( strcmp ( settings.fh_featureExtractor.name, 'Compute HOG features using WHO code' ) || ...
             strcmp ( settings.fh_featureExtractor.name, 'HOG and Patch Means concatenated' )    || ...
             strcmp ( settings.fh_featureExtractor.name, 'HOG and Color Names' )...
           ) 
            i_truncDim = 32;
        else
            i_truncDim = 0;
        end
    end

    % compute a feature for a small, empty image to fetch the number of
    % dimensions every cell-feature has
    i_numImgChannels = size ( readImage(allImages{1}),3);
    i_numDim = size( settings.fh_featureExtractor.mfunction ( zeros([3 3 i_numImgChannels]) ),3 );    
    
    if ( i_truncDim > 0 )
      display('Ignoring last truncation feature');
      i_numDim  = i_numDim-1;
    end
    
    neg = zeros(i_numDim,1);
    
    % will be the total number of cells extracted from all images on all
    % scales
    n   = 0;
    
    


    %% (3) start learning negative mean
    fprintf('\nLearning negative mean\n');

    % average features over all images, and all possible locations and
    % scales
    for i = 1:length(allImages)
        
      % progressbar-like output  
      if( rem(i,10)==1 )
          fprintf('%d / %d\n', i,length(allImages) );
      end
   
      im = readImage( allImages{i} );
      if ( i_numImgChannels ~= size ( im,3) )
            % if by chance there are some images not fitting to the other
            % ones...
            continue;
      end      

      % Extract feature pryamid, removing hallucinated octave
      pyra = featPyramidGeneric(im, BG, settings );
            
      % run over all scales
      for s = 1:length(pyra.feat)
        featIm = pyra.feat{s};
        
        % possibly remove last dimension 
        if ( i_truncDim > 0 )
            featIm = featIm(:, :, 1:end~=i_truncDim );
        end        
   
        [imy,imx,imz] = size(featIm);
        
        % total number of extractable from the image at the current scale
        t = imy*imx;
        
        % compress all cells in each channel into a single long feature
        % vector
        feat = reshape(featIm,t,imz);
        % increase number of totally inspected features
        n    = n + t;
        % add features to previous universal mean
        try
            neg  = neg + sum(feat)';        
        catch err
            err
        end
      end  
    end

    % normalize mean accordingly
    neg = neg'/n;

    w    = order;
    h    = order;
    dxy = [];
    for x = 0:w-1,
      for y = 0:h-1,
        dxy = [dxy; [x y]];
        if x > 0 & y > 0,
          dxy = [dxy; [x -y]];
        end
      end
    end



    %% (4) start learning covariance matrix
    k    = size(dxy,1);
    ns   = zeros(k,1);
    cov  = zeros(i_numDim,i_numDim,k);    
    
    fprintf('\nLearning stationairy negative covariance\n');

    for i = 1:length(allImages)
                
        % progressbar-like output
        if( rem(i,10)==1 )
            fprintf('%d / %d\n', i,length(allImages) );
        end
        im        = readImage( allImages{i} );
        if ( i_numImgChannels ~= size ( im,3) )
            % if by chance there are some images not fitting to the other
            % ones...
            continue;
        end

        % Extract feature pryamid
        pyra      = featPyramidGeneric(im, BG, settings );
      
        % Subtract mean from all features extracted from current image
        for s = 1:length(pyra.feat),
            featIm = pyra.feat{s};

            if ( i_truncDim > 0 )
                featIm = featIm(:, :, 1:end~=i_truncDim );
            end
        
            [imy,imx,imz] = size(featIm);
            featIm = reshape(featIm,imy*imx,imz);
            featIm = bsxfun(@minus,featIm,neg);
            if ( imz > 1 )
                featIm = reshape(featIm,[imy imx imz]);
            else
                featIm = reshape(featIm,[imy imx]);
            end
            pyra.feat{s} = featIm;
        end
      
        for s = 1:length(pyra.feat),
          for i = 1:k,
            dx = dxy(i,1);
            dy = dxy(i,2);
            [imy,imx,~] = size(pyra.feat{s});
            
            if ( dy > 0 )
              y11 = 1;
              y12 = imy - dy;
            else
              y11 = -dy + 1;
              y12 = imy;
            end
            
            if ( dx > 0 )
              x11 = 1;
              x12 = imx - dx;
            else
              x11 = -dx + 1;
              x12 = imx;
            end
            
            if ( ( y12 < y11 ) || ( x12 < x11 ) )
              continue;
            end
            
            y21 = y11 + dy;
            y22 = y12 + dy;
            x21 = x11 + dx;
            x22 = x12 + dx;        
            assert(y11 >= 1 && y12 <= imy && ...
                   x21 >= 1 && x22 <= imx);
               
            t    = (y12 - y11 + 1)*(x12 - x11 + 1);
            feat1 = reshape(pyra.feat{s}(y11:y12,x11:x12,:),t,i_numDim);        
            feat2 = reshape(pyra.feat{s}(y21:y22,x21:x22,:),t,i_numDim);
            
            cov(:,:,i) = cov(:,:,i) + feat1'*feat2;
            ns(i) = ns(i) + t;
          end
        end
      
    end %for i = 1:length(allImages) 

    fprintf('\n');
    neg = neg';

    for i = 1:k
      cov(:,:,i) = cov(:,:,i) / ns(i);
    end

    
    %% (5) write results to output object
    
    BG.neg        = neg;
    BG.cov        = cov;
    BG.dxy        = dxy;
    BG.ns         = ns;
    BG.lambda     = .01;
  
    
end
