function [aligned] = align_images(images, transforms, except, N)

for i=1:N
    if (ndims(images) == 3) % Grayscale
        if (any(except == i))
            aligned(:,:,i) = images(:,:,i);
            continue;
        end
        
        Iin = images(:,:,i);
        transform = transforms(i);
        Iout = transform_image(Iin, transform);
        
        aligned(:,:,i) = Iout;
        
    elseif (ndims(images) == 4) % RGB
        if (any(except == i))
            aligned(:,:,:,i) = images(:,:,:,i);
            continue;
        end
        
        Iin = images(:,:,:,i);
        transform = transforms(i);
        Iout = transform_image(Iin, transform);
        
        aligned(:,:,:,i) = Iout;
    else
        error('Input array has to be gray or rgb');
    end
end
