function extract_patches_from_contours(img_fname, contour_fname, patches_img_fname, contours_csv_fname)

img = imread(img_fname);
[h,w,~] = size(img);

load(contour_fname);

num_patches = max(M(:,3));

scales = [5:2:70];
num_scales = numel(scales);

patch_w = 73;
patch_h = 41;

out_image = zeros(num_patches * patch_h , num_scales * patch_w,  3);

ss = make_scale_space(img);

for i=1:num_patches
    related_idxs = M(:,3) == i;
    xy = M(related_idxs,1:2)';
    xy(1,:) = xy(1,:) * double(w);
    xy(2,:) = xy(2,:) * double(h);
    
    G = mat2cell(M(related_idxs,3)',1,ones(1,numel(M(related_idxs,3)))');
    theta = mat2cell(M(related_idxs,4)',1,ones(1,numel(M(related_idxs,4)))');
    kappa = mat2cell(M(related_idxs,5)',1,ones(1,numel(M(related_idxs,5)))');
    x = mat2cell(xy, 2,ones(1,numel(M(related_idxs,1))));
    contour = struct('x', x, 'G', G, 'theta', theta, 'kappa', kappa);
    if size(contour,2) > 0
        for sc = 1:num_scales
            [patch,Rp,par_curves] = ...
                make_patch(contour,ss, 'scale_list',scales(sc));
            if size(patch, 1) == patch_h
                out_image((i-1)*patch_h + 1:i*patch_h,  (sc-1)*patch_w + 1: sc*patch_w , :) = patch;
            end
        end
    end
end
out_image = uint8(out_image);
imwrite(out_image, patches_img_fname, 'png');

end
