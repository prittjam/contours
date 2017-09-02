function rgn_stats = calc_entropy(par_contours,grey_img,varargin)
cfg = struct('img_type','intensity', ...
             'quantization', 1/16);

%cfg = cmp_argparse(cfg,varargin{:});

[ny,nx] = size(grey_img);
edges = [0:cfg.quantization:1];
outline = [par_contours.x1 par_contours.x2];
rgn = outline(:,convhull(outline'));

tl = floor(min(rgn,[],2));
br = ceil(max(rgn,[],2));
sz = br-tl;
rgn = rgn-tl+1;
mask = poly2mask(rgn(1,:),rgn(2,:),sz(2),sz(1));
[yy,xx] = find(mask);
ind = sub2ind([ny nx],yy+tl(2),xx+tl(1));
patch = grey_img(ind);
h = histc(patch(:), edges);
h = h(1:end-1);
h = h/sum(h);
idx = find(h > 0);
rgn_stats = struct('pmf', h, ...
                   'H', -sum(h(idx).*log(h(idx))), ...
                   'area', numel(ind), ...
                   'scale',par_contours.scale);
