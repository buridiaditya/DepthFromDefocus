function [Idepth] = calc_sharpness_map(images, N)

type = 'sobel';

SMOOTH = true;
ROWS = size(images, 1);
COLS  = size(images, 2);
sharps = zeros(ROWS, COLS, N);

sobel_x = fspecial('sobel');
sobel_y = sobel_x';

sigmagauss = 25;

if (strcmp('sobel', type))
    for i=1:N
        I = images(:,:,i);
        Idepth = conv2(I, sobel_x, 'same').^2 + conv2(I, sobel_y, 'same').^2;

        if (SMOOTH)
            Idepth = imgaussfilt(Idepth, sigmagauss);
        end

        sharps(:,:,i) = Idepth;
    end    
    
elseif (strcmp('paper', type))
    SIGMA = 13;
    
    for i=1:N
        I = images(:,:,i);
    
        Igradient = conv2(I, sobel_x, 'same').^2 + conv2(I, sobel_y, 'same').^2;
        Iexpgradient = exp(Igradient);

        Idepth = imgaussfilt(Iexpgradient, SIGMA);

        if (SMOOTH)
            Idepth = imgaussfilt(Idepth, sigmagauss);
        end

        sharps(:,:,i) = Idepth;
    end
end

[~, Idepth] = max(sharps, [], 3);
