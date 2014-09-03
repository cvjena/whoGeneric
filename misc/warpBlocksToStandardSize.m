function warped = warpBlocksToStandardSize( model, pos, fh_featureExtractor )
% function warped = warpBlocksToStandardSize( model, pos, fh_featureExtractor )
%
% BRIEF: 
%     Warp positive examples to fit model dimensions.
%     Used for training root filters from positive bounding boxes.
%
% author: Alexander Freytag
% date:   13-03-2014 ( last updated)

    if ( nargin < 3 ) 
        fh_featureExtractor = [];
    end

    i_modelSize = size(model.w);
    i_modelSize = i_modelSize(1:2);
    
    numpos = length(pos);
    
    b_leaveBoundary = getFieldWithDefault ( fh_featureExtractor, 'b_leaveBoundary', false );
    
    if ( b_leaveBoundary )
        cropsize = (i_modelSize+2) .* model.i_binSize;
        %only needed in this case
        pixels   = double(i_modelSize * model.i_binSize);
        heights  = double([pos(:).y2]' - [pos(:).y1]' + 1);
        widths   = double([pos(:).x2]' - [pos(:).x1]' + 1);
    else
        cropsize = (i_modelSize) .* model.i_binSize;
    end
    
    warped  = [];
    lastreadimg='';
    
    for i = 1:numpos
    %  fprintf('%s: warp: %d/%d\n', name, i, numpos);
      if(~strcmp(pos(i).im, lastreadimg))	    
        im          = readImage(pos(i).im);
        lastreadimg = pos(i).im;
      end
      
      if ( b_leaveBoundary )
        padx = model.i_binSize * widths(i) / pixels(2);
        pady = model.i_binSize * heights(i) / pixels(1);
      else
        padx=0;
        pady=0;
      end
      
      x1 = round(double(pos(i).x1)-padx);
      x2 = round(double(pos(i).x2)+padx);
      y1 = round(double(pos(i).y1)-pady);
      y2 = round(double(pos(i).y2)+pady);
      
      window = subarray(im, y1, y2, x1, x2, 1);%note: 0 as last option is currently not supported
      warped{end+1} = imresize(window, cropsize, 'bilinear');%, 'Antialiasing', false);
    end

    if numpos == 1,
      assert(~isempty(warped));
    end
end




function B = subarray(A, i1, i2, j1, j2, pad)
% B = subarray(A, i1, i2, j1, j2, pad)
% Extract subarray from array
% pad with boundary values if pad = 1
% pad with zeros if pad = 0

    dim = size(A);
    %i1
    %i2
    is = i1:i2;
    js = j1:j2;

    if pad
      is = max(is,1);
      js = max(js,1);
      is = min(is,dim(1));
      js = min(js,dim(2));
      B  = A(is,js,:);
    else
      % todo
    end
end