function model = initmodel_static( settings, i_numDim )
% function model = initmodel_static( settings, i_numDim )
% 
% BRIEF
%    Initialize model structure.
% 
% OUTPUT
%    model = initmodel( settings )
%        model.maxsize = [y,x] size of root filter in HOG cells
% ...TODO
% 
% author: Alexander Freytag
% date:   13-02-2014 (dd-mm-yyyy) (last updated)

    
%     %% how many dimensions does our feature has?
    
    % for DPM-HOG features, this would result in the following layout
    % how many dimensions does our resulting 'augmented HoG feature' has?
    % see DPM Paper from 2010 for more details
    % 2*numberBins for keeping gradient sign + 
    % 1*numberBins without the sign + 
    % 4 strange texture feature dimensions + 
    % 1 dimension constant to zero
    % -> default: 32 dimensions    
    
    sizeOfModel = [ settings.lda.bg.i_numCells, ...
                    i_numDim...
                  ];

    %% initialize the rest of the model structure
    
    %empty model of according size
    model.w          = zeros(sizeOfModel);
    % size of root filter in HOG cells
    model.i_numCells = sizeOfModel(1:2);
    % size of each cell in pixel
    model.i_binSize  = settings.lda.bg.i_binSize;
    % strange interval 
    model.interval   = settings.lda.bg.interval;    
    %threshold to reject detection with score lwoer than that
    model.d_detectionThreshold ...
                     = settings.lda.d_detectionThreshold;

    %negative mean, cov matrix, and stuff like that
    model.bg         = settings.lda.bg;
    
    %======== ======== ======== ======== 
    %      add here noise model for
    %     modeling de-noising effect
    %======== ======== ======== ========  
    
    % this adds noise on the main diagonal of the covariance matrix
    model.lda.lambda         = settings.lda.lambda;
    
    %%% this additionally adds a drop-out noise model 
    model.lda.b_noiseDropOut = settings.lda.b_noiseDropOut;
    model.lda.d_dropOutProb  = settings.lda.d_dropOutProb;
    
end