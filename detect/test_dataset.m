function boxes=test_dataset(test, model, settings )
% boxes=test_dataset(test, model, setting )
% test is struct array with fields:
%	.im:full path to image

%TODO

for i = 1:length(test),
  fprintf('testing: %d/%d\n', i, length(test));
  im = readImage(test(i).im);
  %tic;
  pyraFeat = featPyramidGeneric( im, model, settings ) ;
  boxes{i} = detectWithGivenFeatures( pyraFeat, model, model.thresh );
  %toc; tic;
  %%%
  %TODO replace by own method
  boxes{i} = nonMaxSupp(boxes{i},.25);
  %toc;
 % showboxes(im,boxes{i});
end

