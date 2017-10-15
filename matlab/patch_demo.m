function [] = patch_demo(img,varargin)
cfg = struct('scale_list', 30);
cfg = cmp_argparse(cfg,varargin{:}); 

E = DL.extract_contours(img);
contour_list = DL.segment_contours(E);

x = [contour_list(:).x];
G = [contour_list(:).G]; 

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
                   [contour_list(:).x],[contour_list(:).G]);
Gsz  = cellfun(@(x) numel(x),X);
[~,ind] = sort(Gsz,'descend');
figure;
imshow(img);

num_patches = min(24,numel(Gsz));
patch_list = zeros(41,73,3,num_patches);

ss = make_scale_space(img);

keyboard;

for k = 1:num_patches
    contour = contour_list(G==ind(k));
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

size(patch_list);
figure;
montage(uint8(patch_list));
