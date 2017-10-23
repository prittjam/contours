function [] = match_demo(varargin)
dlines_init();
img1 = imread('/home/old-ufo/Dropbox/map2photo/1/map3.png');
img2 = imread('/home/old-ufo/Dropbox/map2photo/2/map3.png');
H = dlmread('/home/old-ufo/Dropbox/map2photo/h/map3.txt');
T = 3;
overlap = 0.5;

%tmp = pwd;
E = DL.extract_contours(img1);
contour_list1 = DL.segment_contours(E);
E = DL.extract_contours(img2);
contour_list2 = DL.segment_contours(E);
%cd(tmp)
%load('contour_list1.mat');
%load('contour_list2.mat');

cspond_list = match_contours(contour_list1,contour_list2,H,T,overlap); 
draw_contour_csponds(cspond_list,img1,contour_list1,img2,contour_list2);

%save('contour_list1.mat','contour_list1');
%save('contour_list2.mat','contour_list2');
%
%
%
