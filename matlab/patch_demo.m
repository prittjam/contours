function patch_list = patch_demo(img,varargin)
cfg = struct('scale_list', 30, ...
             'use_scale_space',true);

dlines_init();
cfg = cmp_argparse(cfg,varargin{:}); 

if cfg.use_scale_space
    ss = make_scale_space(img);
else
    ss = struct('img',img, ...
                'sigma',0.5);
end

tmp = pwd;
E = DL.extract_contours(img);
%contour_list = DL.segment_contours(E);
contour_list = ...
    DL.segment_contours(E, ...
                        'min_response',-inf, ...
                        'max_kappa', inf, ...
                        'min_length', 10);
cd(tmp)

x = [contour_list(:).x];
G = [contour_list(:).G]; 

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
                   [contour_list(:).x],[contour_list(:).G]);
Gsz  = cellfun(@(x) numel(x),X);, 'min_response',-inf, 'min_length',5
[~,ind] = sort(Gsz,'descend');
figure;
imshow(img);
num_patches_big = 0;
for k = 1:numel(Gsz)
    contour = contour_list(G==ind(k));
    if numel([contour(:).x]) > 40
        
        num_patches_big = num_patches_big + 1;
    end
end


%num_patches_big = min(24,numel(Gsz));
patch_list = zeros(41,73,3,num_patches_big);

for k = 1:num_patches_big
    contour = contour_list(G==ind(k));
     if numel([contour(:).x]) <= 40
         continue
     end
    [patch,Rp,par_curves] = ...
        make_patch(contour,ss, ...
                   'scale_list',cfg.scale_list, ...
                   'scale_space_ratio', 10);
    
    if ~isempty(patch)
        patch_list(:,:,:,k) = patch;
        hold on;
        plot(par_curves.x(1,:),par_curves.x(2,:), ...
             'b-', 'LineWidth',2);
       % plot(par_curves.x1(1,:),par_curves.x1(2,:), ...
       %      'g-','LineWidth',2);
       % plot(par_curves.x2(1,:),par_curves.x2(2,:), ...
       %      'r-', 'LineWidth',2);
        hold off;
    end
end

size(patch_list);
figure;
montage(uint8(patch_list));
end
