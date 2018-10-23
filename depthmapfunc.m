function y = depthmapfunc(xdepth, N, SIZE, A, F, fs, blurmaps, confidencemaps)

depthmap = reshape(xdepth, SIZE(1), SIZE(2));

y = 0;

for i=1:N
    f = fs(i);
    
    T = ((A * abs(f - depthmap) * F ./ (depthmap * abs(f - F)) - blurmaps(:,:,i))...
        .* confidencemaps(:,:,i)).^2;
    y = y + sum(T(:));
end