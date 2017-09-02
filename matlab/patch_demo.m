function [] = patch_demo()
dlines_init();
[cur_path, name, ext] = fileparts(mfilename('fullpath'));
parent_path = fileparts(cur_path);

%img = imread('/home/old-ufo/dev/line_Jimmy/dlines/img/building_us.jpg');
img_fname = [parent_path '/img/pyramid.jpg']
img = imread(img_fname);
[ny,nx,~ ] = size(img);

E = DL.extract_contours(img);
pts = DL.segment_contours(E);

x = [pts(:).x];
G = [pts(:).G]; 

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
                   [pts(:).x],[pts(:).G]);
Gsz  = cellfun(@(x) numel(x),X);
[~,ind] = sort(Gsz,'descend');

grey_img = im2double(rgb2gray(img));

figure;
imshow(img);
h = gca;

for k = 1:10
    contour = pts(G==ind(k));

    [patch,Rp,par_curves] = make_patch(contour,img, ...
                            'scale_list',30);
    
    axes(h);
    x = [contour(:).x];
    hold on;
    plot(x(1,:),x(2,:), ...
         'b-', 'LineWidth',3);
    plot(par_curves.x1(1,:),par_curves.x1(2,:), ...
         'g-','LineWidth',3);
    plot(par_curves.x2(1,:),par_curves.x2(2,:), ...
         'r-', 'LineWidth',3);
    hold off;
    
%    ind = 1:10:size(x,2);
%    quiver(x(1,ind),x(2,ind),n(1,ind),n(2,ind),'LineWidth',3);
%    hold off;
%
    figure;
    imshow(patch);
end
