function initWorkspaceWHOGeneric


    %% add paths
    
    % pre-computed data
    addpath( genpath( fullfile(pwd, 'data') ) );
    
    % things for detecting objects
    addpath( genpath( fullfile(pwd, 'detect') ) );
    
    % mainly HOG and scripts for image resizing
    addpath( genpath( fullfile(pwd, 'features') ) );
    
    % everything regarding learning the actual LDA detectors
    addpath( genpath( fullfile(pwd, 'learn') ) );
    
    % path to introducing demo scripts
    addpath( genpath( fullfile(pwd, 'demos') ) );    
    
    % minor things, e.g., warping of blocks or padding of arrays
    addpath( 'misc' );    
    
    
    % read images from given filename
    if (exist('readImage') ~= 2 )
        addpath( genpath( fullfile(pwd, 'misc/imageIO') ) );    
    end
    
    % scripts for configuration of setting-objects
    if (exist('getFieldWithDefault') ~= 2 )
        addpath( genpath( fullfile(pwd, 'misc/settings') ) );    
    end    
    
    %% 3rd party, untouched
    
    % nothing needed here...
    
end
