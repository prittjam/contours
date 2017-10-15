function ss = make_scale_space(img)
[ny,nx,~] = size(img);
num_octaves = floor(log2(min(nx,ny)));
tmp = bsxfun(@plus,[0:num_octaves-1],transpose([0:2])/3);
sigma0 = 1.6;
sigma_list = sigma0*2.^tmp(:);

ss = struct('sigma',0.5, ...
            'img',img);

for k = 1:numel(sigma_list)
    ss(k) = struct('sigma',sigma_list(k), ...
                   'img', imgaussfilt(img,sigma_list(k)));
end
