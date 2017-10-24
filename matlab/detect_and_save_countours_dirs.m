function detect_and_save_countours_dirs(in_dir_name, out_dir_name)
dlines_init
files = dir(in_dir_name);
files = files(3:end);

if 7==exist(out_dir_name,'dir')
else
mkdir(out_dir_name);
end


n_dirs = numel(files);
%try
%   delete(gcp);
%catch
%end
%segments = {};
%remain =genpath('/home.dokt/mishkdmy/test_dlines/contouts/');
%while ~isempty(remain)
%   [token,remain] = strtok(remain, ':');
%   segments = cat(1,segments,token);
%end

%hh = parpool('SGE',4);%min(100,n_imgs));
%hh = parpool('local', 12);
%addAttachedFiles(hh,segments)

disp(files)
for i=1:n_dirs
    img_fname = [in_dir_name,'/' files(i).name] ;
    out_fname = [out_dir_name,'/' files(i).name] ;
    detect_and_save_countours_dir(img_fname, out_fname);
end
%delete(gcp)
