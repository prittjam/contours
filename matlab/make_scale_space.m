function [ss,sigma] = make_scale_space(in,levels,step)
[ny,nx,~] = size(in);
num_octaves = log2(min(width,height));

sigma0 = 1.6;
sigma=sigma0*2.^[0:num_octaves-1]; 

ss=zeros([size(in) levels]);
ss(:,:,1)=in;
for i = 2:levels 
    ss(:,:,i)=gaussfilter(in, sigma(i));
end
