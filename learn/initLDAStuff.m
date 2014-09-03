function ldaStuff = initLDAStuff( ny, nx, modeltemplate)
% function ldaStuff = initLDAStuff( ny, nx, modeltemplate)
%
% BRIEF:
%    At the beginning, every detector is built only from a single
%    block (see the 1-SVM paper for motivation details)
%
%    Lateron, further blocks are added to this struct increasing the
%    number of training samples of every detector
%
% INPUT:
%    ny             -- ysize of our HoG features, assumed to be constant
%    nx             -- xsize of our HoG features, assumed to be constant
%    modeltemplate  -- template for best LDA model (size) determined by who code
%
% OUTPUT:
%    ldaStuff   -- struct containing following fields:
%                   ldaStuff.R             -- covariance matrix of all data
%                   ldaStuff.neg           -- mean of universal negative data
%                   ldaStuff.modelTemplate -- model template for LDA models


    %this needs to be done only ones since our parameters are always the same

    model = modeltemplate;
    
    if ( isfield(modeltemplate.lda,'b_noiseDropOut') && ~isempty(modeltemplate.lda.b_noiseDropOut) )
        model.lda.b_noiseDropOut = modeltemplate.lda.b_noiseDropOut;
    end
  
    if ( isfield(modeltemplate.lda,'d_dropOutProb') && ~isempty(modeltemplate.lda.d_dropOutProb) )
        model.lda.d_dropOutProb = modeltemplate.lda.d_dropOutProb;
    end    
  
    if ( isfield(modeltemplate.lda,'lambda') && ~isempty(modeltemplate.lda.lambda) )
        model.lda.lambda = modeltemplate.lda.lambda;
    end      
    
    [ldaStuff.R,ldaStuff.neg] = whitenWithDropout(model.bg, model.lda, nx,ny);
    
    ldaStuff.modelTemplate = modeltemplate;
    
    %per default, we work on all dimensions
    %however, DPM HOG features have as last feature dimension truncation
    %features constant to 0. In thoses cases, we set the flag to true and
    %ignore the last dimension in further processing stages
    ldaStuff.b_ignoreLastDim = false;
        
end