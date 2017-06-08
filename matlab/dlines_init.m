function [] = dlines_init(src_path,opt_path)
if nargin < 1
    src_path = '~/src/';
end

if nargin < 2
    opt_path = '~/opt/';
end

[cur_path, name, ext] = fileparts(mfilename('fullpath'));
addpath([cur_path]);

if ~exist('calc_curvature','dir')
    addpath(fullfile([opt_path 'mex']));
end

if ~exist('edgesDemo','file')
    addpath([src_path, '/edges']);
end

if ~exist('cmp_splitapply','file')
    addpath([src_path,'matlab_extras']);
end

if ~exist('channels','dir')
    addpath(genpath([src_path, '/dollar_toolbox']));
end
