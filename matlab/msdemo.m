function [] = msdemo(varargin)
dlines_init();

[cur_path, name, ext] = fileparts(mfilename('fullpath'));
parent_path = fileparts(cur_path);

%img = imread('/home/old-ufo/dev/line_Jimmy/dlines/img/building_us.jpg');
%img_fname = [parent_path '/img/pyramid.jpg']
%img_fname = ['img3.png'];

img_fname = ['building_us.jpg'];
img = imread(img_fname);
patch_demo(img, ...
           'scale_list',[5:2:40]);

small_img = imresize(img,0.5);
patch_demo(small_img, ...
           'scale_list',[5:2:40]);
