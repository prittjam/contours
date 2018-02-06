function [] = embed(pth,data_set,varargin)
cfg = struct('T',5);
cfg = cmp_argparse(cfg,varargin{:});
data_pth = [pth data_set '/'];
summary_file_name = [data_pth 'summary.mat'];
load(summary_file_name);
dlines_init();
data_pth = [pth data_set '/'];
data = load([data_pth 'data.mat']);
fname_list = data.imnames;
M = sparse([],[],[],num_all_contours,size(data.U,2));
X = data.U;

cG = 1;
ind = zeros(1,numel(fname_list));
embedding_file_name = [data_pth 'embedding.mat'];
if ~exist(embedding_file_name,'file')
    for k = 1:numel(fname_list)
        x = data.u_uncalib.points{k};
        idx = data.u_uncalib.index{k};    
        [~,contour_list] = load_data(data_pth,fname_list(k).name);
        [ii,jj,num_contours] = process_one_img(x,idx,X,contour_list, ...
                                               data_pth,fname_list(k).name,cfg.T);
        ind(k) = cG;
        if ~isempty(ii)
            ii = ii+ind(k)-1;
            M(sub2ind(size(M),ii,jj)) = 1;
        end
        cG = cG+num_contours;
%        disp(['Embedding contours from image ' num2str(k) ' of ' num2str(numel(fname_list))]);
    end
    save([data_pth 'embedding.mat'],'M','ind');
end
    
function [img,contour_list,num_contours] = load_data(data_pth,fname)
[~,file_name] = fileparts(fname);
img = imread([data_pth fname]);
contour_file_name = [data_pth file_name '_contours.mat'];
load([data_pth file_name '_contours.mat']);
num_contours = numel(contour_list);

function [ii,jj,num_contours] = ...
    process_one_img(x,ind,X,contour_list,data_pth,fname,T)
G = [contour_list(:).G];
num_contours = max(G);
kdts = KDTreeSearcher(transpose([contour_list(:).x]));
[idx,d] = knnsearch(kdts,transpose(x(1:2,:)));
inl = find(d < T);
gidx = G(idx);
ii = gidx(inl);
jj = ind(inl);
