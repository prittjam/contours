function recall = repeatability_on_hpatches(imgs_dir, contours_dir, pixel_th, IoU_th)

dirs = dir(imgs_dir);
dirs = dirs(3:end);


n_dirs= numel(dirs);

recall = zeros(5, n_dirs);
for i=1:n_dirs
    img_fname = [imgs_dir,'/' dirs(i).name] ;
    disp([num2str(i), img_fname])
    c_fname = [contours_dir,'/' dirs(i).name] ;
    recall(:,i) = get_repeatability_from_one_dir(img_fname, c_fname, pixel_th, IoU_th);
end


end