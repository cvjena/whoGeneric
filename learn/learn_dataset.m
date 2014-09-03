function model = learn_dataset( pos, neg, bg, settings )
% model = learn_dataset(pos, neg, name, settings )
% 
% author: Alexander Freytag
% date:   13-02-2014 (dd-mm-yyyy) (last updated)
% 
% BRIEF
%    Initialize model structure. (note: If you just have image patches, instead of bounding boxes, consider using learn.m directly)
% 
% INPUT
%     pos      -- is a struct array for the positive patches, with fields:
%	              .im (full path to the image), .x1 (xmin), .y1 (ymin), .x2 (xmax), .y2 (ymax)
%     neg      -- struct array for the negative patches with field:
%	              im: full path to the image 
%                 Used only when the background statistics cannot be found.
%     bg       -- (optional) pre-computed whitening info (cov mat, negative mean, ...)
%     settings -- struct with config settings
%      
% OUTPUT
%    model     -- learnt model
% 


    if ( isempty(neg) )
        allImages = {pos.im};
    else
        allImages = [ {pos.im}; {neg.im} ];
    end

    
    %use given background statistics if they exist; else build them
    if ( isempty(bg) )
      bg  = trainBGwithArbitraryFeatures( allImages, settings );
    end


    % Define model structure
    % how many dimensions does our feature has?
    % compute a feature for a small,  empty image to fetch the number of
    % dimensions every cell-feature has
    i_numImgChannels = size ( readImage( allImages{1}),3);
    i_numDim = size( settings.fh_featureExtractor.mfunction ( zeros([3 3 i_numImgChannels]) ),3 );  
    
    clear ( 'allImages' );
    
    %computed lda variables
    settings.lda.bg = bg;
    %threshold to reject detection with score lwoer than th
    settings.lda.d_detectionThreshold = 0;
    
    % how many cells are useful in both directions?
    i_numCells = computeOptimalCellNumber ( pos, settings.i_binSize );
    settings.lda.bg.i_numCells = i_numCells;
    
    %======== ======== ======== ======== 
    %      add here noise model for
    %     modeling de-noising effect
    %======== ======== ======== ========      
    % this adds noise on the main diagonal of the covariance matrix
    settings.lda.lambda = bg.lambda;
    %%% this additionally adds a drop-out noise model 
    settings.lda.b_noiseDropOut = false;
    settings.lda.d_dropOutProb = 0.0;
    
    settings.lda.bg.interval = settings.interval;
    
    model = initmodel_static(settings, i_numDim);
    
    %skip models if the HOG window is too skewed
    if( max(model.i_numCells)<4*min(model.i_numCells) )
        
        %get image patches
        warpedTrainBlocks = warpBlocksToStandardSize( model, pos, settings.fh_featureExtractor );
        
        % pre-compute features from the seeding blocks (size normalized)
        feats = computeFeaturesForBlocks( warpedTrainBlocks, settings);  

        
        [ldaStuff.R,ldaStuff.neg] = whitenWithDropout(model.bg, model.lda, model.i_numCells(2),model.i_numCells(1));
        
        % for the HOG features computed here, the 32nd dim is constant to
        % zero serving as truncation dim.
        i_truncDim = 32;
        
        model = learnWithGivenWhitening(model, ...
            ldaStuff.R, ldaStuff.neg, ...
            feats, i_truncDim );

    else
        model.maxsize
        error('HOG window is too skewed!');
    end
    
    model.w=model.w./(norm(model.w(:))+eps);
    model.thresh = 0.5;
    model.bg=[];
end

