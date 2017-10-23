function cspond = match_contours(contour_list1,contour_list2,H,T)
G1 = [contour_list1(:).G]; 
uG1 = unique(G1);
G2 = [contour_list2(:).G];
uG2 = unique(G2);

contour_list1p = xfer_contour_list(contour_list1,H);
contour_list2p = xfer_contour_list(contour_list2,inv(H));

MdlKDT = KDTreeSearcher(transpose([contour_list2(:).x]));
[idx,d] = knnsearch(MdlKDT,transpose([contour_list1p(:).x]));
Gidx = G2(idx);
Gidx(d>T) = nan;
modes12 = cmp_splitapply(@(x) mode_ratio(x),Gidx',G1');
inl = ~isnan(modes12);
st12 = [uG1(inl)' modes12(inl)+numel(uG1)]; 

MdlKDT = KDTreeSearcher(transpose([contour_list1(:).x]));
[idx,d] = knnsearch(MdlKDT,transpose([contour_list2p(:).x]));
Gidx = G1(idx);
Gidx(d>T) = nan;
modes21 = cmp_splitapply(@(x) mode_ratio(x),Gidx',G2');
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

function ind = mode_ratio(x)
ind = nan;
if any(~isnan(x))
    freq = hist(x,1:max(x));
    [val,ind2] = max(freq);
    if val/numel(x) > 0.5
        ind = ind2;
    end
end

