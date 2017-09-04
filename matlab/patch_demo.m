function [] = patch_demo(varargin)
dlines_init();

cfg = struct('scale_list', 30);
cfg = cmp_argparse(cfg,varargin{:});

[cur_path, name, ext] = fileparts(mfilename('fullpath'));
parent_path = fileparts(cur_path);

%img = imread('/home/old-ufo/dev/line_Jimmy/dlines/img/building_us.jpg');
%img_fname = [parent_path '/img/pyramid.jpg']
img_fname = ['img3.png'];
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

num_patches = min(24,numel(Gsz));
patch_list = zeros(41,73,3,num_patches);
for k = 1:num_patches
    contour = pts(G==ind(k));
    [patch,Rp,par_curves] = ...
        make_patch(contour,img, 'scale_list',cfg.scale_list);
    
    if ~isempty(patch)
        patch_list(:,:,:,k) = patch;
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
end

figure;
montage(uint8(patch_list));
