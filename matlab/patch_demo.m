function [] = new_patch_demo()
dlines_init();
[cur_path, name, ext] = fileparts(mfilename('fullpath'));
parent_path = fileparts(cur_path);

%img = imread('/home/old-ufo/dev/line_Jimmy/dlines/img/building_us.jpg');
img_fname = [parent_path '/img/building_us.jpg']
img = imread(img_fname);
[ny,nx,~ ] = size(img);

E = DL.extract_contours(img);
pts = DL.segment_contours(E);

x = [pts(:).x];
G = [pts(:).G]; 

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
                   [pts(:).x],[pts(:).G]);
Gsz  = cellfun(@(x) numel(x),X);
[~,ind] = sort(Gsz,'descend');

contour = pts(G==ind(1));
[patch,Rp,curve,xp,n] = make_patch(contour,img);
figure;
imshow(img);
hold on;
fnplt(curve);
quiver(xp(1,:),xp(2,:),n(1,:),n(2,:),'LineWidth',3);
hold off;

figure;
imshow(patch);
