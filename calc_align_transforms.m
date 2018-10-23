function [ transforms ] = calc_align_transforms(images, ifixed, varargin)

N = size(images, 3);

I_fixed = images(:,:,ifixed);

metricThreshold = 250;
if (nargin == 1)
    metricThreshold = varargin(1);
end

% detect features of the "fixed" image
pts_fixed = detectSURFFeatures(I_fixed, 'MetricThreshold', metricThreshold);
[fts_fixed, validpts_fixed] = extractFeatures(I_fixed, pts_fixed);

count = 0;
for i=1:N
    if (i == ifixed)
        continue;
    end
    
    I_curr = images(:,:,i);
    
    % extract features from the image to transform
    pts_curr = detectSURFFeatures(I_curr, 'MetricThreshold', metricThreshold);
    [fts_curr, validpts_curr] = extractFeatures(I_curr, pts_curr);
    
    % match feature vectors
    indexPairs = matchFeatures(fts_fixed, fts_curr);
    matchedpts_fixed = validpts_fixed(indexPairs(:,1));
    matchedpts_curr  = validpts_curr(indexPairs(:,2));
    
    [tform, ~, ~] = estimateGeometricTransform(...
        matchedpts_curr, matchedpts_fixed, 'similarity');
    
    transforms(i) = tform;
    count = count + 1;
    disp(['Completed ' num2str(count) '/' num2str(N-1)]);
end