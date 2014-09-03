function paddedArray = myPadArray( myArray, padSize, valForPadding )
% function newf = myPadArray( myArray, padSize, valForPadding )
% 
% BRIEF:
%   Quite the same thing as matlabs padarray, but significantly faster ( about 
%    ~10 times)
% 
% author: Alexander Freytag
% date  : 28-02-2014 ( dd-mm-yyyy )

    if ( numel ( padSize ) < 2 )
        padSize = [padSize, padSize];
    end
    
    if ( (ndims ( myArray ) > 2 ) && (numel ( valForPadding ) ~= size(myArray,3) ) )
        valForPadding = repmat ( valForPadding, size(myArray,3),1 );
    end    

    classOfMyArray = class ( myArray );
    
    newsize = size( myArray );
    newsize(1) = newsize(1)+2*padSize(1);
    newsize(2) = newsize(2)+2*padSize(2);
    
    startpos = [padSize(1)+1, padSize(2)+1];
    endpos   = startpos+[size( myArray,1 ), size( myArray,2 )]-1;
    
    % be safe about not changing the classtype of the padded array
    valForPadding = cast ( valForPadding, classOfMyArray);    
    

    
    
    if ( ndims ( myArray ) == 3 )
        % create 'plain' array
        paddedArray         = ones( newsize, classOfMyArray );
        for i=1:size(myArray,3)
            paddedArray(:,:,i)  = valForPadding(i)*paddedArray(:,:,i);
        end
        
        % set original content to according position    
        paddedArray (startpos(1):endpos(1), startpos(2):endpos(2), :) = myArray;        
        
    elseif ( ndims ( myArray ) == 2 )
        % create 'plain' array
        paddedArray         = valForPadding*ones( newsize, classOfMyArray );
        
        % set original content to according position
        paddedArray (startpos(1):endpos(1), startpos(2):endpos(2) ) = myArray;        
    else
        disp('Number of feature dimensions does not match!')
    end
end