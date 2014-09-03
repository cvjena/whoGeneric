function figHandle = showboxes(im, boxes, partcolor, b_WnHgiven)
% showboxes(im, boxes)
% Draw boxes on top of image.

if ( nargin < 4 ) 
    b_WnHgiven = false;
end


if ( (nargin < 3) || isempty ( partcolor) )
  partcolor(1)    = {'r'};
  partcolor(2:20) = {'b'};
end

%imagesc(im); axis image; axis off;
handle = imshow(im);
hold on;
if ~isempty(boxes)
  numparts = floor(size(boxes, 2)/4);
  for i = 1:numparts
    x1 = boxes(:,1+(i-1)*4);
    y1 = boxes(:,2+(i-1)*4);
    if ( b_WnHgiven )
        x2 = x1+boxes(:,3+(i-1)*4);
        y2 = y1+boxes(:,4+(i-1)*4);
    else
        x2 = boxes(:,3+(i-1)*4);
        y2 = boxes(:,4+(i-1)*4);        
    end
    line([x1 x1 x2 x2 x1]',[y1 y2 y2 y1 y1]','color',partcolor{i},'linewidth',5);
  end
end
drawnow;
hold off;

if ( nargout > 0 )
    figHandle = handle;
end
