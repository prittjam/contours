function [] = patch_demo(varargin)
cfg = struct('scale_list', 30);

cfg = cmp_argparse(cfg,varargin{:});

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

patch_list = zeros(41,73,3,10);
for k = 1:10
    contour = pts(G==ind(k));
    [patch_list(:,:,:,k),Rp,par_curves] = ...
        make_patch(contour,img, 'scale_list',cfg.scale_list);

    x = [contour(:).x];
    hold on;
    plot(x(1,:),x(2,:), ...
         'b-', 'LineWidth',2);
    plot(par_curves.x1(1,:),par_curves.x1(2,:), ...
         'g-','LineWidth',2);
    plot(par_curves.x2(1,:),par_curves.x2(2,:), ...
         'r-', 'LineWidth',2);
    hold off;
end

figure;
montage(uint8(patch_list));
