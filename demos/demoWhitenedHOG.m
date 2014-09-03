% author: Alexander Freytag
% date  : 27-02-2014 (dd-mm-yyyy)


%% Training
% We will train a model from a single instance.
% So let's create a tiny list of positive examples
pos(1).im = 'train.jpg';
pos(1).x1 = 70;
pos(1).y1 = 202;
pos(1).x2 = 255;
pos(1).y2 = 500;



%read image ... 
im       = readImage(pos(1).im);
figTrain = figure;
set ( figTrain, 'name', 'Training Image');
% ... and show initial bounding box
showboxes(im ,[pos(1).x1 pos(1).y1 pos(1).x2 pos(1).y2]);

%settings for feature extraction
settings.i_binSize = 8;
settings.interval  = 10; % same as on who demo file
settings.order     = 20;
% note:
% change the representation as you desire. This repo comes along with HOG
% features as default, however, any diffferent feature type can be plugged
% in as well given the proper wrapper funtion.
% Examples can be found in our repository about patch discovery
settings.fh_featureExtractor = ...
  struct('name','Compute HOG features using WHO code', ...
         'mfunction',@computeHOGs_WHOorig, ...
         'b_leaveBoundary' , true );


% try locate previously trained bg-struct
try
    fileToBG = fullfile(pwd, 'data/bg11.mat');
    load( fileToBG );
    % compatibility to older versions
    if ( isfield(bg,'sbin') && ~isfield(bg, 'i_binSize') );
        bg.i_binSize = bg.sbin;
    end
catch
    % if not possible, leave bg empty and compute it from scratch lateron
    bg=[];
end

% no negative examples, use 'universal' negative model
neg   = [];
model = learn_dataset( pos, neg, bg, settings );

%show learned model, i.e., visualized HOG feature for positive and negative weights
b_closeImg = false;
showWeightVectorHOG( model.w, b_closeImg )

%% Testing
test(1).im='test.jpg';

%perform detection
boxes=test_dataset( test, model, settings );

%convert output from 1x1-cell to double array
boxes = boxes{1};
%only take highest response
%[~,bestIdx] = max ( boxes(:,5) );
%boxes = boxes(bestIdx,:);

%show detections
im      = readImage(test(1).im);
figTest = figure;
set ( figTest, 'name', 'Test Image');
showboxes(im, boxes);

% that's it :)