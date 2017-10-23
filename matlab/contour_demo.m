function [] = contour_demo(img,varargin)
dlines_init();
ss = struct('img',img, ...
            'sigma',0.5);

tmp = pwd;
E = DL.extract_contours(img);
cd(tmp);

contour_list = ...
    DL.segment_contours(E, ...
                        'min_response',-inf, ...
                        'max_kappa', inf, ...
                        'min_length', 10);

figure;
subplot(1,2,1)
imshow(img);
[yy,xx] = find(E>0);
hold on;
plot(xx,yy,'g.');
hold off;

subplot(1,2,2);
imshow(img);
x = [contour_list(:).x];
G = [contour_list(:).G]; 

num_contours = numel(unique(G));
colors = distinguishable_colors(numel(unique(G)));

for k = 1:num_contours
    contour = contour_list(G==k);
    x = [contour(:).x];
    hold on;
    plot(x(1,:),x(2,:),'g.','Color',colors(k,:));
    hold off;
end
