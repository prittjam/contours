function [idx,best_scale] = select_scale(rgn_stats)
fxx = [1 -2 1]/2;
Hxx = conv([rgn_stats(:).H],fxx,'valid');
ind = find(Hxx < 0)+1;
Y = [rgn_stats(ind).Y];
[~,ind2] = max(Y);
idx = ind(ind2);
best_scale = rgn_stats(idx).scale;
