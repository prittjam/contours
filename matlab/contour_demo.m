%function [] = contour_demo()
dlines_init();

[cur_path, name, ext] = fileparts(mfilename('fullpath'));
parent_path = fileparts(cur_path);

%img = imread('/home/old-ufo/dev/line_Jimmy/dlines/img/building_us.jpg');
img_fname = '/home/old-ufo/Dropbox/Mik/graf/img1.png'
img = imread(img_fname);

[ny,nx,~ ] = size(img);

pts = DL.segment_contours(img);

x = [pts(:).x];
G = [pts(:).G]; 

Gimg = nan(ny,nx);
Gimg(sub2ind([ny nx],x(2,:),x(1,:))) = [pts(:).G]; 
Gimg(isnan(Gimg)) = 0;
cmap = distinguishable_colors(max(G));
rgb = label2rgb(Gimg,cmap,'k');
imshow(rgb);
%%
%function lines,patches =  Jimmy_format_to_homoglines(pts, PE)
PE.length = 41;
PE.height_coef = 0.3;
PE.height = ceil(PE.length * PE.height_coef);
PE.px_per_pt = 100;


%%
ptscell = struct2cell(pts);
points = reshape(squeeze(cell2mat(ptscell(1,1,:))),2,[]);
labels = squeeze(cell2mat(ptscell(2,1,:)));
thetas = squeeze(cell2mat(ptscell(3,1,:)));
kappas = squeeze(cell2mat(ptscell(4,1,:)));
nans = isnan(labels);
points(:,nans) = [];
labels(nans) = [];
thetas(nans) = [];
kappas(nans) = [];
num_lines = max(labels);
lines = zeros(3, num_lines);
patches = zeros(PE.height, PE.length, num_lines);
%
test1=100;%ok
%test1 = 124;%problems
%%
%test1 = 0;
test1 = test1 - 1 ;
clc
close all
figure();
img = rgb2gray(imread(img_fname));
%img = rgb2gray(imread('/home/old-ufo/dev/line_Jimmy/dlines/img/building_us.jpg'));

[ny,nx,~ ] = size(img);


imshow(img)
hold on
for i=test1:test1%num_lines
    curr_idxs = find(labels == i);
    current_num_pts = numel(curr_idxs);
    first_point = [points(:,curr_idxs(1))' 1]';
    last_point = [points(:,curr_idxs(end))' 1]';
    
    l1 = cross(first_point,last_point);
    lines(:,i) = l1 ./ l1(3);
 
    if numel(thetas(curr_idxs)) < 8*2
        disp(numel(thetas(curr_idxs)))
        continue
    end
    %  current_patch_original_straight =  getMR_around_line(points(:,curr_idxs),thetas(curr_idxs), kappas(curr_idxs), PE);
    patch = getMR_around_line(points(:,curr_idxs),thetas(curr_idxs), kappas(curr_idxs), PE,img);
    thetas(curr_idxs)
    figure()
    imshow(patch)
    %patches(:,:,i) = imresize(current_patch_original_straight, [PE.height, PE.length]);
    %figure()
    %imshow(current_patch_original_straight)
    %figure()
    %imshow(patches(:,:,i))
    
    break
end
%%

%ends
%figure;
%subplot(1,2,1);
%imshow(img);
%subplot(1,2,2);
%imshow(rgb);
%
%Go = DL.group_orientations(pts);
%cmap = distinguishable_colors(max(Go));
%Gimg(sub2ind([ny nx],x(2,:),x(1,:))) = Go; 
%Gimg(isnan(Gimg)) = 0;
%rgb = label2rgb(Gimg,cmap,'k');
%figure;
%imshow(rgb);
%
%figure;
%quiver(x(1,iG),x(2,iG),u,v,0);
