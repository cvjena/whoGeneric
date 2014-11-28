function initWorkspaceWHOGeneric

    %% setup paths in use-specific manner
    
    if  strcmp( getenv('USER'), 'freytag')
        % dependencies go here      
    else
        fprintf('Unknown user %s and unknown default settings', getenv('USER') ); 
    end


    %% add paths
    
    % add main path
    b_recursive = false; 
    b_overwrite = true;
    s_pathMain = fullfile(pwd);
    addPathSafely ( s_pathMain, b_recursive, b_overwrite )
    clear ( 's_pathMain' );      
    
    % pre-computed data
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathData              = fullfile(pwd, 'data');
    addPathSafely ( s_pathData, b_recursive, b_overwrite )
    clear ( 's_pathData' ); 
    
    % things for detecting objects
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathDetect            = fullfile(pwd, 'detect');
    addPathSafely ( s_pathDetect, b_recursive, b_overwrite )
    clear ( 's_pathDetect' );
    
    % mainly HOG and scripts for image resizing
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathFeatures          = fullfile(pwd, 'features');
    addPathSafely ( s_pathFeatures, b_recursive, b_overwrite )
    clear ( 's_pathFeatures' );
    
    % everything regarding learning the actual LDA detectors
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathLearn             = fullfile(pwd, 'learn');
    addPathSafely ( s_pathLearn, b_recursive, b_overwrite )
    clear ( 's_pathLearn' );
    
    % path to introducing demo scripts
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathDemos             = fullfile(pwd, 'demos');
    addPathSafely ( s_pathDemos, b_recursive, b_overwrite )
    clear ( 's_pathDemos' );   
    
    % minor things, e.g., warping of blocks or padding of arrays
    b_recursive             = false; 
    b_overwrite             = true;
    s_pathMisc              = fullfile(pwd, 'misc');
    addPathSafely ( s_pathMisc, b_recursive, b_overwrite )
    clear ( 's_pathMisc' );
    
    
    % read images from given filename
    if (exist('readImage') ~= 2 )
        b_recursive             = true; 
        b_overwrite             = true;
        s_pathImageIO           = fullfile(pwd, 'misc/imageIO');
        addPathSafely ( s_pathImageIO, b_recursive, b_overwrite )
        clear ( 's_pathImageIO' );  
    end
    
    % scripts for configuration of setting-objects
    if (exist('getFieldWithDefault') ~= 2 )
        b_recursive             = true; 
        b_overwrite             = true;
        s_pathSettings          = fullfile(pwd, 'misc/settings');
        addPathSafely ( s_pathSettings, b_recursive, b_overwrite )
        clear ( 's_pathSettings' );
    end    
    
    %% 3rd party, untouched
    
    % nothing needed here...
    
end



function addPathSafely ( s_path, b_recursive, b_overwrite )
    if ( ~isempty(strfind(path, [s_path , pathsep])) )
        if ( b_overwrite )
            if ( b_recursive )
                rmpath( genpath( s_path ) );
            else
                rmpath( s_path );
            end
        else
            fprintf('InitPatchDiscovery - %s already in your path but overwriting de-activated.\n', s_path);
            return;
        end
    end
    
    if ( b_recursive )
        addpath( genpath( s_path ) );
    else
        addpath( s_path );
    end
end
