function [] = embed(pth,data_set)
T = 5;
dlines_init();
data_pth = [pth data_set '/'];
data = load([data_pth 'data.mat']);
[data,num_all_contours] = process_dir(data,data_pth);
fname_list = data.imnames;
M = sparse([],[],[],num_all_contours,size(data.U,2));
X = data.U;

cG = 0;
ind = zeros(1,numel(fname_list));
for k = 1:numel(fname_list)
    x = data.u_uncalib.points{k};
    idx = data.u_uncalib.index{k};    
    [~,contour_list] = load_data(data_pth,fname_list(k).name);
    [ii,jj,num_contours] = process_one_img(x,idx,X,contour_list, ...
                                           data_pth,fname_list(k).name,T);
    ind(k) = cG+1;
    ii = ii+cG;
    cG = cG+num_contours;
    M(sub2ind(size(M),ii,jj)) = 1;
end

save([data_pth 'embedding.mat'],'M','ind');

function [data,num_contours] = process_dir(data,data_pth)
fname_list = data.imnames;
num_all_contours = 0;
summary_file_name = [data_pth 'summary.mat'];
if ~exist(summary_file_name,'file')
    for k = 1:numel(fname_list)
        [~,~,num_contours] = ...
            load_data(data_pth,fname_list(k).name);
        num_all_contours = num_all_contours+num_contours;
    end
    save(summary_file_name,'num_all_contours');
else
    load(summary_file_name);
end
    
function [img,contour_list,num_contours] = load_data(data_pth,fname)
[~,file_name] = fileparts(fname);
img = imread([data_pth fname]);
contour_file_name = [data_pth file_name '_contours.mat'];
if ~exist(contour_file_name,'file')
    tmp = pwd;
    E = DL.extract_contours(img);
    cd(tmp); 
    contour_list = ...
        DL.segment_contours(E, ...
                            'min_response',-inf, ...
                            'max_kappa', inf, ...
                            'min_length', 10);
    save([data_pth file_name '_contours.mat'],'contour_list');
else
    load([data_pth file_name '_contours.mat']);
end
num_contours = numel(contour_list);

function [ii,jj,num_contours] = ...
    process_one_img(x,ind,X,contour_list,data_pth,fname,T)
G = [contour_list(:).G];
num_contours = max(G);
kdts = KDTreeSearcher(transpose([contour_list(:).x]));
[idx,d] = knnsearch(kdts,transpose(x(1:2,:)));
inl = find(T < 5);
gidx = G(idx);
ii = gidx(inl);
jj = ind(inl);


%function [cspond, recall] = match_contours(x,contour_list)
%Gg = [contour_list(:).G]; 
%uG = unique(G);
%sz1 = hist(G1,1:max(G1));
%
%MdlKDT = KDTreeSearcher(transpose([contour_list2(:).x]));
%[idx,d] = knnsearch(MdlKDT,transpose([contour_list1p(:).x]));
%Gidx = G2(idx);
%Gidx(d>T) = nan;
%
%modes12 = cmp_splitapply(@(x) mode_ratio(x,overlap,sz2),Gidx',G1');
%inl = ~isnan(modes12);
%st12 = [uG1(inl)' modes12(inl)+numel(uG1)]; 
%
%MdlKDT = KDTreeSearcher(transpose([contour_list1(:).x]));
%[idx,d] = knnsearch(MdlKDT,transpose([contour_list2p(:).x]));
%Gidx = G1(idx);
%Gidx(d>T) = nan;
%modes21 = cmp_splitapply(@(x) mode_ratio(x,overlap,sz1),Gidx',G2');
%inl = ~isnan(modes21);
%st21 = [modes21(inl) uG2(inl)'+numel(uG1)]; 
%
%st = unique([st12;st21],'rows');
%
%gr = graph(st(:,1),st(:,2));
%bins = conncomp(gr);
%freq = hist(bins,1:max(bins));
%matches = find(freq > 1);
%
%for k = 1:numel(matches)
%    v = find(bins == matches(k));
%    vleft = v(find(v<=numel(uG1)));
%    vright = v(find(v>numel(uG1)));
%    cspond(k) = struct('left', vleft, ...
%                       'right',vright-numel(uG1));
%end
%
%if ~exist('cspond','var')
%    cspond = struct;
%end
%
%recall = numel(cspond) / min(numel(uG1), numel(uG2));

