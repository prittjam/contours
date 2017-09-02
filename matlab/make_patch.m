function [patch,Rp] = make_patch(contour,img,varargin)
cfg = struct('patch_ny', 41, ...
             'aspect_ratio', 16/9, ...
             'scale_list', 30, ...
             'ysampling_freq', 10);

cfg.patch_nx = round(cfg.aspect_ratio*cfg.patch_ny);
cfg.xsampling_freq = round(cfg.aspect_ratio*cfg.ysampling_freq);

[cfg,leftover] = cmp_argparse(cfg,varargin{:});

N = size(par_contour.x1,2);
ind = floor(linspace(1,N,cfg.xsampling_freq));

X = zeros(cfg.ysampling_freq,cfg.xsampling_freq);
Y = zeros(cfg.ysampling_freq,cfg.xsampling_freq);

par_contour = select_par_contour(contour,img,scale_list);

for k = 1:size(X,2)
    s = linspace(0, ...
                 norm(par_contour.x1(:,ind(k))-par_contour.x2(:,ind(k))), ...
                 cfg.ysampling_freq);
    x2 = par_contour.x1(:,ind(k))+bsxfun(@times,s,n(:,k));
    X(:,k) = x2(1,:);
    Y(:,k) = x2(2,:);
end

[xxn,yyn] = ...
    meshgrid(linspace(-cfg.aspect_ratio/2,cfg.aspect_ratio/2,cfg.xsampling_freq), ....
           linspace(-0.5,0.5,cfg.ysampling_freq));
fixed_points = [xxn(:) yyn(:)];
moving_points = [X(:) Y(:)];

tform = fitgeotrans(moving_points,fixed_points,'lwm',12);

R = imref2d([cfg.patch_ny cfg.patch_nx]);
R.XWorldLimits = [-cfg.aspect_ratio/2 cfg.aspect_ratio/2];
R.YWorldLimits = [-0.5 0.5];

[patch,Rp] = imwarp(img,tform,'OutputView',R);
patch = patch(end:-1:1,:,:);

function par_contour = selct_par_contour(contour,img,sc_list)
if numel(sc_list) > 1
    for k2 = 1:numel(sc_list);
        [par_contour_list(k2),n] = ...
            make_par_contours(contour,2*cfg.scale);    
        rgn_stats(k2) = ...
            calc_entropy(par_contour_list(k2),grey_img);
    end
    rgn_stats = calc_saliency(rgn_stats);
    [ind,best_scale] = select_scale(rgn_stats);
    par_contour = par_contour_list(ind);
else
    [par_contour_list(k2),n] = ...
        make_par_contours(contour,cfg.scale);    
end
