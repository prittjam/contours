function [] = contour_demo()
img = imread(['/home/prittjam/src/gtrepeat/dggt/building_us.jpg']);
[ny,nx,~ ] = size(img);

pts = DL.segment_contours(img);
Go = DL.group_orientations(pts);

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



cmap = distinguishable_colors(max(Go));
Gimg(sub2ind([ny nx],x(2,:),x(1,:))) = Go; 
Gimg(isnan(Gimg)) = 0;
rgb = label2rgb(Gimg,cmap,'k');
figure;
imshow(rgb);

figure;
quiver(x(1,iG),x(2,iG),u,v,0);
