function boxes = detectWithGivenFeatures(pyraFeats,model,thresh)
%function boxes = detectWithGivenFeatures(pyraFeats,model,thresh)
% 
% BRIEF:
%     Detect object in images by searching for large model responses in
%     terms of convolution scores
% 
%     Pretty much the same as the original code of who, only differs in
%     handing over precomputed features.
%     Additionally, no hallucinated levels are deleted.
% 
% author: Alexander Freytag
% date:   26-02-2014 (dd-mm-yyyy)

    levels   = 1:length(pyraFeats.feat);
    %pre-allocate some memory (assume not more then 10k boxes in advance)
    boxes    = zeros(10000,5);
    myDetectorFilter  = {model.w};

    % padding of image borders
    padx = pyraFeats.padx;
    pady = pyraFeats.pady;
    
    sizx = size(model.w,2);
    sizy = size(model.w,1);
    cnt  = 0;

    for l = levels,
        % get features of current scale
        scale = pyraFeats.scale(l);
      
        % do the actual convolution
        if ( ndims ( myDetectorFilter{1} ) > 2 ) 
            resp  = fconv3D( pyraFeats.feat{l}, myDetectorFilter, 1,1);
        else
            resp  = fconv2D( pyraFeats.feat{l}, myDetectorFilter, 1,1);
        end        
        
        % correction of data structure
        resp  = resp{1};
        
        % only accept scores over thresh
        [y,x] = find(resp >= thresh);
        
        if ( ~isempty(x) )
            I  = (x-1)*size(resp,1)+y;

            % convert responses to original image coordinates
            x1 = (x-1-padx)*scale + 1;
            y1 = (y-1-pady)*scale + 1;
            x2 = x1 + sizx*scale  - 1;
            y2 = y1 + sizy*scale  - 1;

            i = cnt+1:cnt+length(I);

            % store corners of box + score
            boxes(i,:) = [x1 y1 x2 y2 resp(I)];

            % increase number of responses found so far
            cnt = cnt+length(I);
        end
    end

    %that's it, return the found boxes with corresponding scores
    boxes = boxes(1:cnt,:);
end
