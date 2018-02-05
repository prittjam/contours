function [] = dddemo();
[cur_pth, name, ext] = fileparts(mfilename('fullpath'));
pth = [cur_pth '/../../data/'];
datasets = dir(pth);
datasets = datasets(3:end)
for d=numel(datasets):-1:1
dataset = datasets(d).name
%dataset = 'fountain';
TDV.extract(pth,dataset);
TDV.embed(pth,dataset,'T',7);
TDV.match(pth,dataset,'T',0.95);
%TDV.show_matches(pth,dataset);
end
end
