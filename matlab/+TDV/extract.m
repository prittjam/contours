function [] = extract(pth,data_set)
dlines_init();
data_pth = [pth data_set '/'];
data = load([data_pth 'data.mat']);
[data,num_all_contours] = process_dir(data,data_pth);

function [data,num_all_contours] = process_dir(data,data_pth)
fname_list = data.imnames;
num_all_contours = 0;
summary_file_name = [data_pth 'summary.mat'];
if ~exist(summary_file_name,'file')
    for k = 1:numel(fname_list)
        [~,~,num_contours] = ...
            load_data(data_pth,fname_list(k).name);
        num_all_contours = num_all_contours+num_contours;
    end
    save(summary_file_name,'num_all_contours');
else
    load(summary_file_name);
end
    
function [img,contour_list,num_contours] = load_data(data_pth,fname)
[~,file_name] = fileparts(fname);
img = imread([data_pth fname]);
contour_file_name = [data_pth file_name '_contours.mat'];
if ~exist(contour_file_name,'file')
    tmp = pwd;
    E = DL.extract_contours(img);
    cd(tmp); 
    contour_list = ...
        DL.segment_contours(E, ...
                            'min_response',-inf, ...
                            'max_kappa', inf, ...
                            'min_length', 10);
    save([data_pth file_name '_contours.mat'],'contour_list');
else
    load([data_pth file_name '_contours.mat']);
end
G = [contour_list(:).G];
maxG = max(G);
num_contours = maxG;
