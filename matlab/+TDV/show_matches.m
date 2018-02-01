function [] = show_matches(pth,dataset)
data_pth = [pth dataset '/'];
load([data_pth 'data.mat']);
load([data_pth 'cspond.mat']);
freq = arrayfun(@(x) numel(x.idx),cspond);
[~,I] = sort(freq,'descend');
topN = 1;
%color_list = ['r','g','b','c','y','k'] ;
for k = 1:topN
    idx = cspond(I(35)).idx;
    tmp = transpose(idx) > ind;
    img_idx = transpose(sum(tmp,2));
    contour_idx = idx-ind(img_idx)+1;
    cmp_splitapply(@(a,b) draw_contours(a,b,data_pth,imnames), ...
                   img_idx,contour_idx,findgroups(img_idx));
end

function [] = ...
    draw_contours(img_idx,contour_idx,data_pth,fname_list)
[img,contour_list] = load_data(data_pth,fname_list(img_idx(1)).name); ...
figure;
imshow(img);
G = [contour_list.G];
x = [contour_list.x];
for k = 1:numel(contour_idx)
    ind = find(G == contour_idx(k));   
    hold on;
    plot(x(1,ind),x(2,ind),'g.');
    hold off;
    drawnow;
end


function [img,contour_list] = load_data(data_pth,fname)
[~,file_name] = fileparts(fname);
img = imread([data_pth fname]);
contour_file_name = [data_pth file_name '_contours.mat'];
load([data_pth file_name '_contours.mat']);
