function [Iout] = varying_conv2(Iin, Isigma, strength)

Iout = zeros(size(Iin));

Isigma = Isigma / max(Isigma(:));

NROWS = size(Iin,1);
NCOLS = size(Iin,2);
NCHANNELS = size(Iin,3);

for irow=1:NROWS
    percentdone = 100 * irow / NROWS;
    disp(['Progress: ' num2str(percentdone) '%']);
    for icol=1:NCOLS
        sigma = strength * Isigma(irow, icol);
        
        hsize = ceil(2*[sigma sigma]);
        if (hsize(1) < 1 || hsize(2) < 1)
            Iout(irow,icol) = Iin(irow, icol);
            continue;
        end
        
        hgauss = fspecial('gaussian', hsize, sigma);
        
        imrows = (irow-1) + (1:hsize(1)) - ceil(hsize(1)/2);
        imcols = (icol-1) + (1:hsize(2)) - ceil(hsize(2)/2);
        
        for ichannel=1:NCHANNELS
            sum = 0;
            sumgauss = 0;
            for hrow=1:hsize(1)
                for hcol=1:hsize(2)
                    imrow = imrows(hrow);
                    imcol = imcols(hcol);

                    if (imrow < 1 || imrow > NROWS || imcol < 1 || imcol > NCOLS)
                        continue;
                    end

                    sum = sum + hgauss(hrow,hcol) * Iin(imrow,imcol,ichannel);
                    sumgauss = sumgauss + hgauss(hrow,hcol);
                end
            end

            Iout(irow,icol,ichannel) = sum / sumgauss;
        end
    end
end
