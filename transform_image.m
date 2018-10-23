function [Iout] = transform_image(Iin, transform)
outputView = imref2d(size(Iin));
Iout = imwarp(Iin, transform, 'OutputView', outputView);
