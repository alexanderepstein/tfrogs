function [masked_denoised_signal] = bm(tf,tf_denoised,lrn)
mask = zeros(size(tf));
for i=1:size(tf,1)
    for j=1:size(tf,2)
        if (tf_denoised(i,j)>lrn(i,j))
            mask(i,j) = 1;
        end
    end
end
masked_denoised_signal = mask.*tf;
