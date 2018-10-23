%% Wall panels 2
[Ifocused, Idepth] = depth_from_defocus('photostacks/wall_panels2', 'jpg', 1, false);

%% Keyboard
[Ifocused, Idepth] = depth_from_defocus('photostacks/keyboard', 'jpg', 1, false);

%% Table
[Ifocused, Idepth] = depth_from_defocus('photostacks/table3', 'jpg', 1, true);

%% REFOCUS STEP, run any of the above sections first

NROWS = size(Ifocused,1);
NCOLS = size(Ifocused,2);

isrgb = ndims(Ifocused) == 3;

figure;
imshow(Ifocused);

[x, y] = ginput(1);
x = round(x)
y = round(y)

depth = Idepth(y, x);

blurstrength = input('Specify blur strength');
blurmap = abs(Idepth - depth);

figure; imshow(blurmap, []);

Iblurred = zeros(NROWS, NCOLS, 3);

Irefocused = zeros(size(Ifocused));
Irefocused = varying_conv2(Ifocused, blurmap, blurstrength);

figure; imshow(Irefocused);
