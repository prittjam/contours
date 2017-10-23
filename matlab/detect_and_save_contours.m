function detect_and_save_contours(img_fname, out_fname)

img = imread(img_fname);
[h,w,ch] = size(img);

E = DL.extract_contours(img);
contour_list = DL.segment_contours(E);

M = contour_list_to_M(contour_list, w, h);
save(out_fname,'M');

%% Reproject contours from reference image


[filepath,name,ext] = fileparts(img_fname);
if contains(name,'1')
    homs = dir([filepath, '/H*']);
    num_homs = numel( homs);
    for i =1:num_homs
        disp(['Reprojecting to img ', num2str(i+1)]);
        H = dlmread([filepath, '/', homs(i).name]);
        contour_listp = xfer_contour_list(contour_list,H);
        rep_img = imread([filepath, '/', num2str(i+1), ext]);
        [h,w,ch] = size(rep_img);
        M = contour_list_to_M(contour_listp, w, h);
        rep_out_fname = strrep(out_fname,'_contours.mat',['_contours_1_to', num2str(i+1) ,'.mat']); 
        save(rep_out_fname,'M');
    end
end


%% 

end
