function [] = demo();
[cur_pth, name, ext] = fileparts(mfilename('fullpath'));
pth = [cur_pth '/../../data/'];
dataset = 'fountain';

TDV.extract(pth,dataset);
TDV.embed(pth,dataset,'T',5);
TDV.match(pth,dataset,'T',0.95);
TDV.show_matches(pth,dataset);
