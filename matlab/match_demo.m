function [] = match_demo(varargin)
dlines_init();
img1 = imread('../img/img1.png');
img2 = imread('../img/img4.png');
H = dlmread('H1to4p');
T = 5;


figure;
subplot(1,2,1);
imshow(img1);
subplot(1,2,2);
imshow(img2);
%
%tmp = pwd;
%E = DL.extract_contours(img1);
%contour_list1 = DL.segment_contours(E);
%E = DL.extract_contours(img2);
%contour_list2 = DL.segment_contours(E);
%cd(tmp)
%
%save('contour_list1.mat','contour_list1');
%save('contour_list2.mat','contour_list2');
%

load('contour_list1.mat');
load('contour_list2.mat');
G1 = [contour_list1(:).G]; 
uG1 = unique(G1);
G2 = [contour_list2(:).G];
uG2 = unique(G2);

contour_list1p = xfer_contour_list(contour_list1,H);
contour_list2p = xfer_contour_list(contour_list2,inv(H));
MdlKDT = KDTreeSearcher(transpose([contour_list2(:).x]));
Gidx = G(idx);
Gidx(d>T) = nan;
[idx,d] = knnsearch(MdlKDT,transpose([contour_list1p(:).x]));
modes12 = cmp_splitapply(@(x) mode_ratio(x),idx,G1',G1');
inl = ~isnan(modes12);
st12 = [uG1(inl)' modes12(inl)+numel(uG1)]; 

MdlKDT = KDTreeSearcher(transpose([contour_list1(:).x]));
[idx,d] = knnsearch(MdlKDT,transpose([contour_list2p(:).x]));
Gidx = G(idx);
Gidx(d>T) = nan;
modes21 = cmp_splitapply(@(x) mode_ratio(x),Gidx);
inl = ~isnan(modes21);
st21 = [uG2(inl)'+numel(uG1) modes21(inl)]; 

st = [st12;st21];

gr = graph(st(:,1),st(:,2));
bins = conncomp(gr);
freq = hist(bins,1:max(bins));
matches = find(freq > 1);

for k = 1:numel(matches)
    v = find(bins == matches(k));
    vleft = v(find(v<=numel(uG1)));
    vright = v(find(v>numel(uG1)));
    keyboard;
    cspond(k) = struct('left', vleft, ...
                       'right',vright-numel(uG1));
end

for k = 1:numel(cspond)
    subplot(1,2,1)
    hold on;
    for k2 = 1:numel(cspond(k).left)
        ind = find(G1 == cspond(k).left(k2));
        x = [contour_list1(ind).x];
        plot(x(1,:),x(2,:),'g');
    end
    
    for k2 = 1:numel(cspond(k).right)
        ind = find(G2 == cspond(k).right(k2));
        x = [contour_list2(ind).x];
        plot(x(1,:),x(2,:),'g');
    end
end


function ind = mode_ratio(x,G)
ind = nan;
if any(~isnan(x))
    freq = hist(x,1:max(x));
    [val,ind2] = max(freq);
    if val/numel(x) > 0.5
        ind = ind2;
    end
end
