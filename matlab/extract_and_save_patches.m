function extract_and_save_patches(imgs_dir, contours_dir, out_dir)

files = dir(imgs_dir);
files = files(3:end);

if 7==exist(out_dir,'dir')
else
    mkdir(out_dir);
end


n_imgs = numel(files);

try
   delete(gcp);
catch
end
segments = {};
remain =genpath('/home.dokt/mishkdmy/test_dlines/contours/');
while ~isempty(remain)
   [token,remain] = strtok(remain, ':');
   segments = cat(1,segments,token);
end

hh = parpool('local', 12);
addAttachedFiles(hh,segments)


parfor i=1:n_imgs
    img_fname = [files(i).folder,'/' files(i).name] ;
    try
        imfinfo(img_fname);
    catch
        disp([img_fname, ' failed']);
        continue
    end
    contour_fname = [contours_dir, '/', files(i).name, '_contours.mat'];
    %load(contour_fname);
    %disp(M)
    disp([num2str(i),' ' , img_fname]);
    
    patches_out_fname = [out_dir, '/', files(i).name, '_patches.png'];
    if 2==exist(patches_out_fname,'file')
        disp([patches_out_fname, ' exists, skipping'])
        continue
    end
    extract_patches_from_contours(img_fname, contour_fname, patches_out_fname, '');
    
end
delete(gcp)
