function modelNew = learnWithGivenWhitening(model,R, neg, features, i_truncDim)
% function modelNew = learnWithGivenWhitening(model,R, neg, features, i_truncDim)
% BRIEF:
%    Learn model by linear discriminant analysis with already given
%    negative mean and covariance matrix
% 
% INPUT:
%    model           -- struct, previously untrained model, contains at
%                       least the following fields:
%        .w            -- previous (most likely empty) weight vector of
%                         model, relevant for determining the correct size
%        .i_numCells   -- number of cells, specified per dimension (copied
%                         only)
%        .i_binSize    -- number of pixel of every cell in both directions
%                         (copied only)
%        .interval     -- how many octaves are used for feature extraction 
%                         (copied only)
%        .d_detectionThreshold -- minimum scores for accepting a response
% 
%    R               -- covariance matrix learned previously
%    neg             -- negative mean learned previously
%    features        -- features of positive examples FIXME write
%                       dimensionality!
%    i_truncDim      -- int, indicating which dimension, if any,  serves as 
%                       truncation feature by being constant to zero ( as
%                       done for DPM HOG features )
% 
% OUTPUT:
%   modelNew         -- struct, learned model, with fields 'w',
%                       'i_numCells', 'i_binSize', 'interval', 'd_detectionThreshold
% 
% author:               Alexander Freytag
% last time modified:   27-02-2014 (dd-mm-yyyy)


    %num is the number of blocks we have for this cache
    numSamples  = length(features);
    
    assert (numSamples >= 1, 'LDA - No features for model training provided');

    model.d_detectionThreshold = 0; %FIXME

    % we assume that all features of the positive class are of same size!
    [ny,nx,nf] = size(features{1});
    
    if ( i_truncDim > 0 )
        nf = nf - 1;
    end


    % flatten features into single vectors
    feats = zeros(ny*nx*nf,numSamples);
    
    for i = 1:numSamples      
        
        % get current feature
        feat = features{i};
        
        % possibly remove unneeded truncation feature
        if ( i_truncDim > 0 )
            feat = feat(:, :, 1:end~=i_truncDim );
        end

        % flatten vector and store in feats-struct
        feats(:,i) = feat(:);
    end

    % average all features together
    pos = mean(feats,2);

    % perform actual LDA training
    w=R\(R'\(pos-neg));
    
    % bring weight vector into correct layout
    w = reshape(w,[ny nx nf]);     
    
    if ( i_truncDim > 0 )
        % Add in occlusion feature
        %note: might only be troublesome if very first dim is the td...
        w = cat( 3, w(:,:,1:(i_truncDim-1) ), ...
                    zeros ( size(w,1),size(w,2),1,class(w) ), ...
                    w(:, :, i_truncDim:end) ); 
    end
    
   
    
    modelNew.w                    = w;
    % size of root filter in HOG cells
    modelNew.i_numCells           = [ny nx];
    % size of each cell in pixel
    modelNew.i_binSize            = model.i_binSize;    
    % strange interval
    modelNew.interval             = model.interval;
    %threshold to reject detection with score lower than that
    modelNew.d_detectionThreshold = model.d_detectionThreshold;   
    
end

