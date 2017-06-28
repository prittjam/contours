function [] = dlines_init(opt_path)
if nargin < 1
    opt_path = '~/opt/';
end

[cur_path, name, ext] = fileparts(mfilename('fullpath'));

addpath([cur_path]);

parent_path = fileparts(cur_path);

if ~exist('calc_curvature','dir')
    addpath(fullfile([opt_path 'mex']));
end

if ~exist('edgesDemo','file')
    addpath([parent_path '/external/edges']);
end

if ~exist('+LINE','dir')
    addpath([parent_path '/external/lines']);
end

if ~exist('cmp_splitapply','file')
    addpath([parent_path '/external/matlab_extras']);
end

if ~exist('channels','dir')
    addpath(genpath([parent_path '/external/toolbox']));
end
