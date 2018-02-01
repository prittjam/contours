function [] = match()
data_pth = '../data/fountain/';
tmp = load('Jaccard_sim_M.mat');
load([data_pth 'embedding.mat']);
T = 0.95;
J = calc_Jaccard_similarity(M);
gr = graph(J > T);
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
A = sum(M,2);
AB = M*transpose(M);
J = M2./(A+transpose(A)-M2);
