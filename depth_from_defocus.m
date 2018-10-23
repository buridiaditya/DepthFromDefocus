function [Ifocused, Idepth] = depth_from_defocus(directory, imagetype, ifixed, prealigned)

MAX_SIZE = 1000;

% get all files in the directory of that type
tmp = dir([directory '/*.' imagetype]);
tmp = {tmp.name};

N = length(tmp);
if (ischar(ifixed))
    ifixed = N;
end

% get image info
info = imfinfo(strcat(directory, '/', tmp{1}));
isrgb = strcmp('truecolor', info.ColorType);

%% Align images using homography and RANSAC
for i=1:N
    image = im2double(imread(strcat(directory, '/', tmp{i})));
    if (info.Width > info.Height && info.Width > MAX_SIZE)
        image = imresize(image, [NaN MAX_SIZE]);
    elseif (info.Height > info.Width && info.Height > MAX_SIZE)
        image = imresize(image, [MAX_SIZE NaN]);
    end

    if (~isrgb) % Grayscale
        filesgray(:,:,i) = image;
    else
        filesrgb(:,:,:,i) = image;
        filesgray(:,:,i) = rgb2gray(image);
    end
end

ROWS = size(image, 1);
COLS = size(image, 2);

if (~prealigned)

    transforms = calc_align_transforms(filesgray, ifixed, 250);

    alignedgray = align_images(filesgray, transforms, [ifixed], N);
    if (isrgb)
        alignedrgb = align_images(filesrgb, transforms, [ifixed], N);
    end
else
    alignedgray = filesgray;
    alignedrgb = filesrgb;
end

clear filesgray filesrgb

%% Show aligned images
% figure;
% for i=1:N
%     if (isrgb)
%         imshow(alignedrgb(:,:,:,i));
%     else
%         imshow(alignedgray(:,:,i));
%     end
%     waitforbuttonpress;
% end


%% Calculate sharpness map from aligned focus stack

sharpnessmap = calc_sharpness_map(alignedgray, N);

%% Create all-in-focus image from focus stack and sharpness map

Isharpgray = zeros(ROWS, COLS);
if (isrgb)
    Isharprgb = zeros(ROWS, COLS, 3);
end

for row=1:ROWS
    for col=1:COLS
        isharpest = sharpnessmap(row, col);
        
        Isharpgray(row, col) = alignedgray(row, col, isharpest);
        if (isrgb)
            Isharprgb(row, col, :) = alignedrgb(row, col, :, isharpest);
        end
    end
end

%% Allow user cropping to remove crappy edges
allowcropping = false;

if (allowcropping)
    [I2 , RECT] = imcrop(sharpnessmap / max(sharpnessmap(:)));

    beginx = ceil(RECT(1));
    beginy = ceil(RECT(2));
    endx = beginx + floor(RECT(3));
    endy = beginy + floor(RECT(4));

    alignedgray = alignedgray(beginy:endy, beginx:endx, :);
    Isharpgray = Isharpgray(beginy:endy, beginx:endx);
    if (isrgb)
        alignedrgb = alignedrgb(beginy:endy, beginx:endx, :, :);
        Isharprgb = Isharprgb(beginy:endy, beginx:endx, :);
    end    
end

%% Calculate depth map from all-in-focus image and aligned stack

if (isrgb)
    Ifocused = Isharprgb;
else
    Ifocused = Isharpgray;
end

Idepth = calc_depth_map(Isharpgray, sharpnessmap, alignedgray, N);


Idepth = imgaussfilt(Idepth, 10);

figure; imshow(Idepth,[]);