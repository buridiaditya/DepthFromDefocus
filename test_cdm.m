%% 
load alignedgray.mat;

%%
N = size(alignedgray, 3);
depth = calc_sharpness_map(alignedgray, N);

depth = depth / max(depth(:));

depth_ = imgaussfilt(1-depth, 100);

figure;
imshow(depth_);


figure;
surf(depth_);