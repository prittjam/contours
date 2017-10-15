function detect_and_save_countours_dir(in_dir_name, our_dir_name)

files = dir(in_dir_name);
files = files(3:end);

if 7==exist(our_dir_name,'dir')
else
mkdir(our_dir_name);
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

hh = parpool(min(100,n_imgs));
addAttachedFiles(hh,segments)

disp(files)
parfor i=1:n_imgs
    img_fname = [in_dir_name,'/' files(i).name] ;
    try
        imfinfo(img_fname);
    catch 
        disp([img_fname, ' failed']);
        continue
    end
    out_fname = [our_dir_name, '/', files(i).name, '_contours.mat'];
    detect_and_save_contours(img_fname, out_fname)
end
delete(gcp)
