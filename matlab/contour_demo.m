function [] = contour_demo()
% Demo for Structured Edge Detector (please see readme.txt first).

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=1;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=1;                 % set to true to enable nms


%% detect edge and visualize results

img = imread(['/home/prittjam/Dropbox/gopro/Hero 4 Black/gopro2/' ...
              'rotunda/scaled30/GOPR0383.JPG']);
%img = imresize(img,[750 1000]);
%img = imread(['/home/prittjam/src/gtrepeat/dggt/134509092_4e69559100_o.jpg']);
%img = imresize(img,0.5);
%img = imread(['/home/prittjam/src/gtrepeat/dggt/building_us.jpg']);
[ny nx] = size(img);
[E,o]=edgesDetect(img,model); 
pts = DL.segment_contours(E);

%img0 = checkerboard(100,10,10);
%c = cos(pi/4);
%s = sin(-pi/4);
%T = maketform('affine',[c -s 0; s c 0; 0 0 1]');
%img = imtransform(img0,T);
%[E,o]=edgesDetect(uint8(repmat(floor(255*img),1,1,3)),model);  
%E

x = [pts(:).x];
G = [pts(:).G];
Gimg = nan(size(E));
Gimg(sub2ind([ny nx],x(2,:),x(1,:))) = G; 
Gimg(isnan(Gimg)) = 0;
cmap = distinguishable_colors(max(G));
rgb = label2rgb(Gimg, cmap,'k');

figure;imshow(img);
figure;
imshow(rgb);



