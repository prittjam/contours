function [patch,Rp,par_curves] = make_patch(contour,ss,varargin)
cfg = struct('patch_ny', 41, ...
             'aspect_ratio', 16/9, ...
             'scale_list', 30, ...
             'ysampling_freq', 10, ...
             'clip_border', true, ...
             'scale_space_ratio', 10);

cfg.patch_nx = round(cfg.aspect_ratio*cfg.patch_ny);
cfg.xsampling_freq = round(cfg.aspect_ratio*cfg.ysampling_freq);

[cfg,leftover] = cmp_argparse(cfg,varargin{:});

patch = [];
Rp = [];

N = size([contour(:).x],2);
ind = floor(linspace(1,N,cfg.xsampling_freq));

X = zeros(cfg.ysampling_freq,cfg.xsampling_freq);
Y = zeros(cfg.ysampling_freq,cfg.xsampling_freq);

[par_curves,n] = select_par_curves(contour,ss(1).img,cfg.scale_list);

sigma_list = [ss(:).sigma];

if ~isempty(par_curves)
    for k = 1:size(X,2)
        s = linspace(0, ...
                     norm(par_curves.x1(:,ind(k))-par_curves.x2(:,ind(k))), ...
                     cfg.ysampling_freq);
        x2 = bsxfun(@plus,par_curves.x1(:,ind(k)),bsxfun(@times,s,n(:,ind(k))));
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
    
    [~,idx] = min(abs(cfg.scale_list/cfg.scale_space_ratio-sigma_list));
    
    [patch,Rp] = imwarp(ss(idx).img,tform,'OutputView',R);
    patch = patch(end:-1:1,:,:);
end
    
function [opt_par_curves,opt_n] = select_par_curves(contour,img,sc_list)
border = [1 1; ...
          size(img,2) 1; ...
          size(img,2) size(img,1) ; ...
          1 size(img,1);]';

opt_par_curves = [];
opt_n = [];

if numel(sc_list) > 1
    num_rgns = 0;
    grey_img = im2double(rgb2gray(img));
    for k = 1:numel(sc_list);
        [par_curves,n] = make_par_curves(contour,sc_list(k));    
        xx = [par_curves.x1 par_curves.x2];
        in = inpolygon(xx(1,:),xx(2,:),border(1,:),border(2,:)); 
        if all(in)
            par_curves_list(k) = par_curves;
            rgn_stats(k) = calc_entropy(par_curves_list(k), ...
                                        grey_img);
            num_rgns = num_rgns+1;
        else
            break;
        end
    end

    if num_rgns == numel(sc_list)
        rgn_stats = calc_saliency(rgn_stats);
        [ind,best_scale] = select_scale(rgn_stats);
        opt_par_curves = par_curves_list(ind);
        opt_n = n;
    end
else
    [par_curves,n] = make_par_curves(contour,sc_list);    
    xx = [par_curves.x1 par_curves.x2];
    in = inpolygon(xx(1,:),xx(2,:),border(1,:),border(2,:)); 
    if all(in)
        opt_par_curves = par_curves;
        opt_n = n;
    end
end
