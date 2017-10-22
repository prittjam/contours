function [] = xfer_demo(varargin)
dlines_init();
img1 = imread('../img/img1.png');
img2 = imread('../img/img4.png');
H = dlmread('H1to4p');

figure;
subplot(1,2,1);
imshow(img1);
subplot(1,2,2);
imshow(img2);

tmp = pwd;
E = DL.extract_contours(img1);
contour_list = DL.segment_contours(E);
cd(tmp)

x = [contour_list(:).x];
G = [contour_list(:).G]; 
theta = [contour_list(:).theta];

contour_listp = xfer_contour_list(contour_list,H);

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
                   [contour_list(:).x],[contour_list(:).G]);
Gsz  = cellfun(@(x) numel(x),X);
[~,ind] = sort(Gsz,'descend');

num_contours = min(10,numel(Gsz));

scale = 20;
for k = 1:num_contours
    contour = contour_list(G==ind(k));
    [par_curves,n] = make_par_curves(contour,scale);        
    
    subplot(1,2,1);
    hold on;
    plot(par_curves.x(1,:),par_curves.x(2,:), ...
         'b-', 'LineWidth',2);
    plot(par_curves.x1(1,:),par_curves.x1(2,:), ...
         'g-','LineWidth',2);
    plot(par_curves.x2(1,:),par_curves.x2(2,:), ...
         'r-', 'LineWidth',2);
    hold off;
    
    contour2 = contour_listp(G==ind(k));

    [par_curvesp,np] = make_par_curves(contour2,scale); 
    subplot(1,2,2);
    hold on;
    plot(par_curvesp.x(1,:),par_curvesp.x(2,:), ...
         'b-', 'LineWidth',2);
    plot(par_curvesp.x1(1,:),par_curvesp.x1(2,:), ...
         'g-','LineWidth',2);
    plot(par_curvesp.x2(1,:),par_curvesp.x2(2,:), ...
         'r-', 'LineWidth',2);
    hold off;    
end
