function [] = line_fit_demo()
dlines_init();

[cur_path, name, ext] = fileparts(mfilename('fullpath'));
parent_path = fileparts(cur_path);

img = imread([parent_path '/img/building_us.jpg']);
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

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
                   [pts(:).x],[pts(:).G]);
Gsz  = cellfun(@(x) numel(x),X);
[~,ind] = max(Gsz);

xx = X{ind};

l  = LINE.fit(xx);
LINE.draw_extents(gca,l,'Linewidth',4);
hold on;
plot(xx(1,:),xx(2,:),'w.');
hold off;
