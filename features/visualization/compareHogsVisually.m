function compareHogsVisually ( hog1, hog2, idxDimsToShow )
% function compareHogsVisually ( hog1, hog2, idxStart, idxEnd )
% 
% brief:  compute dim-wise differences between two hog features and plot
%         the results into an image
% author: Alexander Freytag
% date:   05-02-2014 (dd-mm-yyyy)
%
% INPUT:  hog1 and hog2 two hog features of corresponding size
%         idxDimsToShow (optionally) vector with dim indices

    if ( nargin < 3 )
        idxDimsToShow = 1:size(hog1,3);
    end
    
    
    for i=1:length(idxDimsToShow)
        
        % create new figure
        fig1=figure; 
        % set title indicating current dimension
        s_titleHoG = sprintf('Dim %d', idxDimsToShow(i) );
        set ( fig1, 'name', s_titleHoG);        
        
        % plot actual differences
        imagesc( (hog1(:,:,idxDimsToShow(i) ) - hog2(:,:, idxDimsToShow(i) )));
        
        % don't miss a colorbar indicating the actual values
        colorbar; 

        % wait for user input 
        pause; 

        % close current figure and switch to next dimension
        close(fig1);
    end
end