function features = computeFeaturesForBlocks ( blocks, settings )
%%TODO docu

    %% (1) check input
    if ( nargin < 2 )
        settings = [];
    end
    
    %check for feature extractor, if not existing, set to default
    fh_featureExtractor = struct('name','Compute mean patches', 'mfunction',@computeMeanPatches);
    settings = addDefaultVariableSetting( settings, 'fh_featureExtractor', fh_featureExtractor, settings );    
    
    %check for feature extractor, if not existing, set to []
    settingsFeatureExtractorDefault = [];
    settings = addDefaultVariableSetting( settings, 'settingsFeatureExtractor', settingsFeatureExtractorDefault, settings );
    
    %% (2) compute features
    
    n = length(blocks);
       
    for i=n:-1:1 
        feature = settings.fh_featureExtractor.mfunction ( blocks{i}, settings.settingsFeatureExtractor );
        features(i).feature = feature;
    end


end