img = imread('107.jpg');
desc = dlmread('4Jimmy/107.desc');
load('4Jimmy/107.jpg_contours.mat');
contours = transpose(M);

[ny,nx,~] = size(img);
figure;
imshow(img);

T = clusterdata(single(desc), ...
                'criterion','distance', ...
                'linkage','single', ...
                'cutoff',0.5);
freq = hist(T,1:max(T));
good_labels = find(freq>1);

colors = distinguishable_colors(numel(good_labels));

keyboard;

for k = 1:numel(good_labels)
    idx = find(T == good_labels(k));
    for k2 = 1:numel(idx)
        ind = find(M(:,3)==idx(k2));
        hold on;
        plot(nx*M(ind,1),ny*M(ind,2),'Color',colors(k,:),'LineWidth',3);
        hold off;
    end
end
