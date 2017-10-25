function rec = get_repeatability_from_one_dir(imgs_dir, contour_dir, pixel_th, IoU_th)

img1 = imread([imgs_dir, '/', '1.ppm']);
c_sfx = '.ppm_contours.mat';

[h1,w1,ch1] = size(img1);
c1_fname = [contour_dir, '/1', c_sfx];
load(c1_fname);
contour_list1 =  M_to_contour_list(M, w1, h1);
rec = zeros(1,5);

for i=2:6
    img2 = imread([imgs_dir, '/', num2str(i), '.ppm']);
    [h2,w2,ch2] = size(img2);
    c2_fname = [contour_dir, '/', num2str(i), c_sfx];
    load(c2_fname);
    contour_list2 =  M_to_contour_list(M, w2, h2);
    H = dlmread([imgs_dir, '/H_1_', num2str(i)]);
    [cspond_list, rec(i-1)] = match_contours(contour_list1,contour_list2,H,pixel_th,IoU_th);

end



end

