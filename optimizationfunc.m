function y = optimizationfunc(args, N, SIZE, blurmaps, confidencemaps)

nPixels = SIZE(1) * SIZE(2);

% A      = args(1);
% F      = args(2);
% fs     = args(3:(2+N));
% Idepth = args((3+N):end);

Idepth = args(1:nPixels);
A      = args(nPixels+1);
F      = args(nPixels+2);
fs     = args((nPixels+3):end);

y = depthmapfunc(Idepth, N, SIZE, A, F, fs, blurmaps, confidencemaps);