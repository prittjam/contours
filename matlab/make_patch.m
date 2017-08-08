% make_patch makes a normalized patch from a region defined by a contour
%
% Configuration options:
%
% patch_ny: number of patch rows
%
% aspect_ratio: aspect ratio of the patch, for a square, set to 1,
% implicitly defines the number of patch columns
%
% scale: diameter of the region with the contour as the center of
% the region
%
% ysampling_freq: the number of sampling points along the y-axis of
% the patch, or, equivalently, along the normal to a sampling point
% on the contour
%
% xsampling_freq: the number of sampling points along the x-axis of
% the patch, or, equivalently, along the contour. Currently the
% xsampling_freq also defines the interpolating points of the
% parammetric cubic interpolating spline
%
%
% Outputs:
%
% patch: normalized region of interest
%
% Rp: patch 2D normalized reference coordinate system 
%
% curve: the interpolating spline used to define the ROI in image
% space
% 
% xp: sampled points on the spline
%
% n: normals at the sampled points
function [patch,Rp,curve,xp,n] = make_patch(contour,img,varargin)
cfg.patch_ny = 41;
cfg.aspect_ratio = 16/9;
cfg.patch_nx = round(cfg.aspect_ratio*cfg.patch_ny);
cfg.scale = 60;
cfg.ysampling_freq = 10;
cfg.xsampling_freq = round(cfg.aspect_ratio*cfg.ysampling_freq);

x = [contour(:).x];
ind = floor(linspace(1,size(x,2),cfg.xsampling_freq));
curve = cscvn(x(:,ind));
der = fnder(curve);
xp = ppval(curve,curve.breaks);
dydx = ppval(der,curve.breaks);
n = [dydx(2,:); ...
     -dydx(1,:)];
n = bsxfun(@rdivide,n,sqrt(sum(n.^2)));

s = linspace(-cfg.scale/2,cfg.scale/2,cfg.ysampling_freq);
X = zeros(numel(s),cfg.xsampling_freq);
Y = zeros(numel(s),cfg.xsampling_freq);

for j = 1:size(X,2)
    x2 = xp(:,j)+bsxfun(@times,s,n(:,j));
    X(:,j) = x2(1,:);
    Y(:,j) = x2(2,:);
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
