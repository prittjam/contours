function [] = contour_demo()
img = imread(['/home/prittjam/src/gtrepeat/dggt/building_us.jpg']);
[ny,nx,~ ] = size(img);

pts = DL.segment_contours(img);

x = [pts(:).x];
G = [pts(:).G]; 

Gimg = nan(ny,nx);
Gimg(sub2ind([ny nx],x(2,:),x(1,:))) = [pts(:).G]; 
Gimg(isnan(Gimg)) = 0;
cmap = distinguishable_colors(max(G));
rgb = label2rgb(Gimg,cmap,'k');

figure;
subplot(1,2,1);
imshow(img);
subplot(1,2,2);
imshow(rgb);
