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

function [cspond, recall] = match_contours(contour_list1,contour_list2,H,T,overlap)
G1 = [contour_list1(:).G]; 
uG1 = unique(G1);
sz1 = hist(G1,1:max(G1));

G2 = [contour_list2(:).G];
uG2 = unique(G2);
sz2 = hist(G2,1:max(G2));

contour_list1p = xfer_contour_list(contour_list1,H);
contour_list2p = xfer_contour_list(contour_list2,inv(H));

MdlKDT = KDTreeSearcher(transpose([contour_list2(:).x]));
[idx,d] = knnsearch(MdlKDT,transpose([contour_list1p(:).x]));
Gidx = G2(idx);
Gidx(d>T) = nan;

modes12 = cmp_splitapply(@(x) mode_ratio(x,overlap,sz2),Gidx',G1');
inl = ~isnan(modes12);
st12 = [uG1(inl)' modes12(inl)+numel(uG1)]; 

MdlKDT = KDTreeSearcher(transpose([contour_list1(:).x]));
[idx,d] = knnsearch(MdlKDT,transpose([contour_list2p(:).x]));
Gidx = G1(idx);
Gidx(d>T) = nan;
modes21 = cmp_splitapply(@(x) mode_ratio(x,overlap,sz1),Gidx',G2');
inl = ~isnan(modes21);
st21 = [modes21(inl) uG2(inl)'+numel(uG1)]; 

st = unique([st12;st21],'rows');

gr = graph(st(:,1),st(:,2));
bins = conncomp(gr);
freq = hist(bins,1:max(bins));
matches = find(freq > 1);

for k = 1:numel(matches)
    v = find(bins == matches(k));
    vleft = v(find(v<=numel(uG1)));
    vright = v(find(v>numel(uG1)));
    cspond(k) = struct('left', vleft, ...
                       'right',vright-numel(uG1));
end

if ~exist('cspond','var')
    cspond = struct;
end
    
recall = numel(cspond) / min(numel(uG1), numel(uG2));

function ind = mode_ratio(x,overlap,sz)
ind = nan;
if any(~isnan(x))
    freq = hist(x,1:max(x));
    [val,ind2] = max(freq);
    if val/(numel(x)+sz(ind2)) > overlap
        ind = ind2;
    end
end
