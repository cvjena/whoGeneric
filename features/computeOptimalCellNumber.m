function i_numCells = computeOptimalCellNumber ( blocks, i_binSize )
% function i_numCells = computeOptimalCellNumber ( blocks, i_binSize )
% 
% author: Alexander Freytag
% date:   02-03-2014 ( dd-mm-yyyy )
% 

    % pick mode of aspect ratios
    h = [blocks(:).y2]' - [blocks(:).y1]' + 1;
    w = [blocks(:).x2]' - [blocks(:).x1]' + 1;

    xx = -2:.02:2;
    filter = exp(-[-100:100].^2/400);
    aspects = hist(log(double(h)./double(w)), xx);
    aspects = convn(aspects, filter, 'same');
    [peak, I] = max(aspects);
    aspect = exp(xx(I));

    % pick 20 percentile area
    mean(h);
    mean(w);
    areas = sort(h.*w);
    % nasty hack to constrain HoG feature support areas to be not too big or 
    % too small, even if our input data would tell us otherwise
    area = areas(max(floor(length(areas) * 0.2),1));
    area = max(min(area, 7000), 5000);


    % how many pixels shall a cell cover in x and y direction?
    sbin = i_binSize;

    % pick dimensions according to data suggestions
    w  = sqrt(double(area)/aspect);
    h  = w*aspect;


    % resulting number of cells in x direction
    sizeX = round(h/sbin);
    % resulting number of cells in y direction
    sizeY = round(w/sbin);
    
    i_numCells = [sizeX sizeY];
    i_numCells = max(i_numCells,1);
end