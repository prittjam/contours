function detect_contours_on_hpatches(hpatches_dir, contours_dir, patches_dir)
%% Detect contours in each image

dlines_init;
dirs = dir(hpatches_dir);
dirs = dirs(3:end);

if 7==exist(contours_dir,'dir')
else
mkdir(contours_dir);
end

n_dirs = numel(dirs);
disp(dirs)
for i=1:n_dirs
    img_fname = [hpatches_dir,'/' dirs(i).name] ;
    out_fname = [contours_dir,'/' dirs(i).name] ;
    detect_and_save_countours_dir(img_fname, out_fname);
end
%% Reproject contours




end