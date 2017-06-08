function pts = segment_contours(img,varargin)
cfg = struct('min_response',1e-3, ...
             'max_kappa', 1e-1, ...
             'min_length', 15, ...
             'kappa_stride', 5, ...
             'theta_stride', 2);

cfg = cmp_argparse(cfg,varargin{:});

[ny nx] = size(img);

model = get_dollar_model();

[E,o] = edgesDetect(img,model); 
E1 = E;

E1(E1 < cfg.min_response) = 0;
E1(E1 ~= 0) = 1;

E2 = bwmorph(E1,'thin',Inf);
E3 = bwmorph(E2,'spur',5);

B = DL.edgelink(E3,cfg.min_length);
Bsz = cellfun(@(x) size(x,1),B);

G = repelem(1:numel(B),Bsz);
x = cat(1,B{:})';
[x(1,:),x(2,:)] = deal(x(2,:),x(1,:));

theta = ...
    msplitapply(@(x) dlines('calc_orientation',x, ...
                            'stride',cfg.theta_stride), ...
                x,G);
kappa = ...
    msplitapply(@(x) dlines('calc_curvature',x, ...
                            'stride',cfg.kappa_stride), ...
                x,G);

pts = struct('x',mat2cell(x,2,ones(1,size(x,2))), ...
             'G',mat2cell(G,1,ones(1,numel(G))), ...
             'theta',mat2cell(theta,1,ones(1,numel(theta))), ...
             'kappa',mat2cell(kappa,1,ones(1,numel(kappa))));

uG = unique(G);
maxGc = 0;
for g = 1:numel(uG)
    iG = find(G==g);
    Gc = break_contour(kappa(iG));
    if ~all(isnan(Gc))
        Gc = findgroups(msplitapply(@(g) rm_short_contours(g,cfg.min_length),Gc,Gc));
        Gc = Gc+maxGc;
        ng = sum(~isnan(unique(Gc)));
        maxGc = maxGc+ng;
    end
    tmp = mat2cell(Gc,1,ones(1,numel(Gc)));    
    [pts(iG).G] = tmp{:};
end

function [G,g] = break_contour(kappa)
ind = find((kappa > 0.1) & ~isnan(kappa)); 
G = nan(size(kappa));
g = 0;
s = 1;
for k = 1:numel(ind)
    if ind(k) > s
        g = g+1;
        G(s:ind(k)-1) = g;
    end
    s = ind(k)+1;
end

function x = rm_short_contours(x,min_length)
if numel(x) < min_length
    x(:) = nan;
end

function model = get_dollar_model()
% Demo for Structured Edge Detector (please see readme.txt first).
%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=1;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=1;                 % set to true to enable nms


%dtheta = abs(dy_dx(2:end)-dy_dx(1:end-1));
%ind90 = dtheta > pi/2;
%dtheta(ind90) = pi-dtheta(ind90);
