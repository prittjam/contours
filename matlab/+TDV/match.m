function [] = match(pth,data_set)
T = 0.95;
data_pth = [pth data_set '/'];
load([data_pth 'embedding.mat']);
clear all;
load('jaccard_test.mat');
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
M = transpose(M);
A = transpose(sum(M));
AB = transpose(M)*M;
[ii,jj] = find(AB);
J = sparse(size(AB,1),size(AB,2));
ABind = nonzeros(AB);
J(find(AB)) =  ABind./(A(ii)+A(jj)-ABind);
