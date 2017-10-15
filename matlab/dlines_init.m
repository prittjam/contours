function [] = dlines_init()
[cur_path, name, ext] = fileparts(mfilename('fullpath'));

addpath([cur_path]);

parent_path = fileparts(cur_path);

if ~exist('edgesDemo','file')
    addpath([parent_path '/external/edges']);
end

if ~exist('+LINE','dir')
    addpath([parent_path '/external/lines']);
end

if ~exist('+PT','dir')
    addpath([parent_path '/external/points']);
end

if ~exist('cmp_argparse','file')
    addpath([parent_path '/external/matlab_extras']);
end

if ~exist('channels','dir')
    addpath(genpath([parent_path '/external/toolbox']));
end


