function [] = demo();
[cur_pth, name, ext] = fileparts(mfilename('fullpath'));
pth = [cur_pth '/../../data/'];
dataset = 'fountain';

keyboard;
TDV.embed(pth,dataset);
TDV.match(pth,dataset);
TDV.show_matches(pth,dataset);
