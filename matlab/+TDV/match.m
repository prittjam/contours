function [] = match(pth,data_set,varargin)
cfg = struct('T',0.95);
cfg = cmp_argparse(cfg,varargin{:});

data_pth = [pth data_set '/'];
load([data_pth 'embedding.mat']);
if exist([data_pth 'cspond.mat'], 'file') == 2 
load ([data_pth 'cspond.mat'])
return
end

J = calc_Jaccard_similarity(M);
gr = graph(J > cfg.T);
bins = conncomp(gr);
freq = hist(bins,1:max(bins));
matches = find(freq > 1);
for k = 1:numel(matches)
    v = find(bins == matches(k));
    cspond(k) = struct('idx',v);
end
save([data_pth 'cspond.mat'],'cspond','ind');
figure;
bar(freq);

function J = calc_Jaccard_similarity(M)
M = transpose(M);
A = transpose(sum(M));
AB = transpose(M)*M;
[ii,jj] = find(AB);
J = sparse(size(AB,1),size(AB,2));
ABind = nonzeros(AB);
J(find(AB)) =  ABind./(A(ii)+A(jj)-ABind);
