function pyra = featPyramidGeneric(im, model, settings )
% function pyra = featPyramidGeneric(im, model, settings )
% 
%  author: Alexander Freytag
%  date:   26-02-2014 ( dd-mm-yyyy )
% 
%  BRIEF: 
%     Computes a feature pyramid from an image. Features are padded such
%     that at least a single cell is visible. For every scale factor, the
%     resized image is as often downsampled by factor 2 until less than 
%     i_numCells *i_binSize pixel are available.
%
%  INPUT:
%     im       -- image to extract feature pyramid from, gray scale and 
%                 RGB images are supported right now
% 
%     model    -- struct, with at least the following fields 
%         .interval   -- scalar, number of octaves for rescaling the img
%         .i_numCells -- 2x1, number of cells in y and x direction
%         .i_binSize  -- scalar, number of pixel of every cell in x and y direction 
% 
%     settings -- (optional) struct, with possible fields
%         .fh_featureExtractor -- (struct), contains name and mfunction for
%                                 feature extraction
%         .d_maxRelBoxExtent   -- what shall be the max extent of a box
%                                 features are extracted from? (1.0 allows
%                                 for responses covering the whole image)
% 
%  OUTPUT: 
%     pyra.feat{i} is the i-th level of the feature pyramid.
%     pyra.scales{i} is the scaling factor used for the i-th level.
%     pyra.feat{i+interval} is computed at exactly half the resolution of feat{i}.
% 


    %% (1) check input
    if ( nargin < 3 )
        settings = [];
    end
    
    %check for feature extractor, if not existing, set to default
    fh_featureExtractor = struct('name','Compute patch means', 'mfunction',@computePatchMeans);
    settings = addDefaultVariableSetting( settings, 'fh_featureExtractor', fh_featureExtractor, settings );    
    
    %check for feature extractor, if not existing, set to []
    settingsFeatureExtractorDefault = [];
    settings = addDefaultVariableSetting( settings, 'settingsFeatureExtractor', settingsFeatureExtractorDefault, settings );

    %% (2) compute features
    interval    = model.interval;
    i_numCells  = model.i_numCells;
    i_binSize   = model.i_binSize;

    % Select padding, allowing for at least one cell in model to be visible
    if (getFieldWithDefault ( settings, 'b_padFeatPyramid', true ) )
        padx = max(model.i_numCells(2)-1,0);
        pady = max(model.i_numCells(1)-1,0);
    else
        padx = 0;
        pady = 0;
    end

    % Even padding allows for consistent spatial relations across 2X scales
    padx = floor(padx/2)*2;
    pady = floor(pady/2)*2;

        

    sc = 2 ^(1/interval);
    imsize = [size(im, 1) size(im, 2)];
    
    % a value of 1.0 allows responses covering the whole image, whereas 0.5
    % results on boxes covering 25% at most
    d_maxRelBoxExtent = getFieldWithDefault ( settings, 'd_maxRelBoxExtent', 1.0 );
    imsizeMaxAcceptable = d_maxRelBoxExtent*imsize;
    
    % determine maximum scale such that at least i_numCells *i_binSize px
    % are visible in the scaled image
    maxScalesProLevel = zeros( interval, 1);
    for i = 1:interval
        maxScalesProLevel(i) = ...
                1 + floor(   log2(    1/sc^(i-1).*min( double(imsizeMaxAcceptable) ...
                                             ./ ...
                                         (i_numCells *i_binSize) ...
                                        ) ...
                                ) ...
                         );
    end

    %pre-allocate memory                     
    pyra.feat  = cell(  sum( maxScalesProLevel), 1);
    pyra.scale = zeros( sum( maxScalesProLevel), 1);
    % our resize function wants floating point values
    im = double(im);
    %%TODO check whether double<-> uint8 is still needed for meanPatch features

    if ( length(size(im)) == 2)
        resizeFct = @resizeGrayScale;
        reduceFct = @reduceGrayScale;
    else
        resizeFct = @resizeColor;
        reduceFct = @reduceColor;
    end

    
    settings.settingsFeatureExtractor.i_binSize = i_binSize;    
    
    % every iteration rescales the image with exponentially decreasing
    % factors, corresponds to the scale space of Lowes SIFT paper
    for i = 1:interval
        %rescale image according to current scaling factor
        scaledImg = resizeFct(im, 1/sc^(i-1));        
        
        %initial scaling factor for this iteration
        pyra.scale( i ) = 1/sc^(i-1);
        
        % always doubles support of cells by shrinking the image by a factor of
        % 2 in every iteration, corresponds to octaves of Lowes SIFT paper        
        for j = 1:maxScalesProLevel(i)
            
            %extracat features for current level
            pyra.feat{  i+(j-1)*interval } = settings.fh_featureExtractor.mfunction ( scaledImg, settings.settingsFeatureExtractor );
            
            % the scale is exactly have the scale of the previous level
            pyra.scale( i+(j-1)*interval ) = 0.5^(j-1) * pyra.scale(i);
            
            % shrink image by factor of 2 for next iteration in inner round
            scaledImg = reduceFct(scaledImg);            
        end
    end

    %% write results to output object
    % write boundary occlusion feature
    
    %Ricks code: td = model.features.truncation_dim;
    if ( strcmp ( settings.fh_featureExtractor.name, 'Compute HOG features using WHO code' ) || ...
         strcmp ( settings.fh_featureExtractor.name, 'HOG and Patch Means concatenated' ) ...
       )  
        td = 32;
    else
        % no truncation for all other known feature types
        td = 0;
    end
    if ( strcmp ( settings.fh_featureExtractor.name, 'Compute HOG features using WHO code' ) )  
        % add 1 to padding because feature generation deletes a 1-cell
        % wide border around the feature map        
        padAdd = 1;
    else
        % nothing to change for padding
        padAdd = 0;
    end    
    
    for i = 1:length(pyra.feat)
        
        if ( ndims ( pyra.feat{i} ) > 2 )
            pyra.feat{i} = myPadArray(pyra.feat{i}, [pady+padAdd padx+padAdd 0], 0);
        else
            pyra.feat{i} = myPadArray(pyra.feat{i}, [pady+padAdd padx+padAdd], 0);
        end


        % possibly correct the truncation feature
        if ( td > 0 )
            pyra.feat{i}(1:pady,            :,       td) = 1;
            pyra.feat{i}(end-pady:end,      :,       td) = 1;
            pyra.feat{i}(:,            1:padx,       td) = 1;
            pyra.feat{i}(:,            end-padx:end, td) = 1;
        end
    end
      

    %% add further settings to output object
    pyra.scale    = model.i_binSize./pyra.scale;
    pyra.interval = interval;
    pyra.imy      = imsize(1);
    pyra.imx      = imsize(2);
    pyra.pady     = pady;
    pyra.padx     = padx;

end
