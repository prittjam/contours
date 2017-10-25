function extract_and_save_patches_dirs(imgs_dir, contours_dir, out_dir)

files = dir(imgs_dir);
files = files(3:end);

if 7==exist(out_dir,'dir')
else
    mkdir(out_dir);
end


n_dirs= numel(files);

%try
%   delete(gcp);
%catch
%end
segments = {};
remain =genpath('/home.dokt/mishkdmy/test_dlines/contours/');
while ~isempty(remain)
   [token,remain] = strtok(remain, ':');
   segments = cat(1,segments,token);
end

%hh = parpool('local', 12);
hh = parpool('SGE', 25);
addAttachedFiles(hh,segments)

disp(files)
parfor i=1:n_dirs
    img_fname = [imgs_dir,'/' files(i).name] ;
    c_fname = [contours_dir,'/' files(i).name] ;
    p_fname = [out_dir,'/' files(i).name] ;
    extract_and_save_patches_dir(img_fname, c_fname, p_fname)
end
delete(hh)
