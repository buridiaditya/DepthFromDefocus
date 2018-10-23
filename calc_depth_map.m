function [depthmap] = calc_depth_map(Ifocused, Iindex, photos, N)

ROWS = size(Ifocused, 1);
COLS = size(Ifocused, 2);

dblursigma = 0.25;
rmax = 15;

blursigmas = 0:dblursigma:rmax;
Nblursigmas = length(blursigmas);

Iblurred = zeros(ROWS, COLS, Nblursigmas);

Iblurred(:,:,1) = Ifocused;

%figure; hold on;
for i=2:Nblursigmas
    
    Iblurred(:,:,i) = imgaussfilt(Ifocused, blursigmas(i));
    %imshow(Iblurred(:,:,i));
end

blursigmas = zeros(ROWS, COLS, N);
confidences = zeros(ROWS, COLS, N);

differences = zeros(ROWS, COLS, Nblursigmas);
SIGMA = 15;
ALPHA = 2;
figure; hold on;
for i=[1 N] %1:N
    I = photos(:,:,i);
    
    for j=1:Nblursigmas
        % Equation (7)
        diff = abs(I - Iblurred(:,:,j));
        differences(:,:,j) = imgaussfilt(diff, SIGMA);
    end
    
    % Equation (8), blur map
    [Ismallestdiff, blursigmas(:,:,i)] = min(differences, [], 3);
    
%     % Equation (9), confidence map
%     confidences(:,:,i) = (mean(differences, 3) - Ismallestdiff).^ALPHA;
%     
%     subplot(1,2,1); imshow(blursigmas(:,:,i), []); 
%     subplot(1,2,2); imshow(confidences(:,:,i), []); 
%     drawnow;
end

useCustomMethod = true;

if (useCustomMethod)
    
    Itest = blursigmas(:,:,1) + (max(max(blursigmas(:,:,end))) - blursigmas(:,:,end));
    depthmap = Itest;
    
else
   WII = 80;

    disp('Solving for aperture, focal length and focal depths with fixed depth map');
        A0 = 29.35;
        F0 = 8.36;
        fs0 = linspace(16.6, 43, N);
        depth0 = imresize(fs0(Iindex), [WII NaN]);

        DOWNSAMPLED_SIZE = [size(depth0, 1) size(depth0, 2)];
        nPixels = DOWNSAMPLED_SIZE(1) * DOWNSAMPLED_SIZE(2);

        blursigmasdownsampled = imresize(blursigmas, DOWNSAMPLED_SIZE);
        confidencemapsdownsampled = imresize(confidences, DOWNSAMPLED_SIZE);

        x0 = [A0 F0 fs0];
        fun = @(x)(depthmapfunc(depth0, ...
            N, ...
            DOWNSAMPLED_SIZE, ...
            x(1), ...
            x(2), ...
            x(3:end), ...
            blursigmasdownsampled, ...
            confidencemapsdownsampled));

        options = optimoptions(@lsqnonlin,...
            'Algorithm', 'levenberg-marquardt', ...
            'MaxIter', 2000, ...
            'MaxFunEvals', 1000000, ...
            'Display','iter');

        tic;
        [x,resnorm,residual,exitflag,output] = lsqnonlin(fun, x0, [], [], options);
        toc;
        output

        A0
        A = x(1)

        F0
        F = x(2)

        fs0
        fs = x(3:end)

    disp('Solving for depth map');
        depth0 = imresize(fs(Iindex), [WII NaN]);
        x0 = depth0(:)';

        fun = @(x)(depthmapfunc(x, ...
            N, ...
            DOWNSAMPLED_SIZE, ...
            A, ...
            F, ...
            fs, ...
            blursigmasdownsampled, ...
            confidencemapsdownsampled));

        tic;
        [x,resnorm,residual,exitflag,output] = lsqnonlin(fun, x0, [], [], options);
        toc;
        output

        depth = x;
        depthmap = reshape(depth, DOWNSAMPLED_SIZE(1), DOWNSAMPLED_SIZE(2));

    figure;
    imshowpair(depth0, depthmap, 'diff'); 
end