function [] = checkers()
img = imread(['/home/prittjam/Dropbox/gopro/Hero 4 Session/' ...
              'checkerboard/wide/vlcsnap-error016.png']);
gray_img = uint8(rgb2gray(img));
pattern_size = [9 6];         % interior number of corners

[corner_list,is_found] = cv.findChessboardCorners(gray_img, pattern_size);

if is_found
    corner_list = cv.cornerSubPix(gray_img, corner_list);
end

for k = 1:numel(corner_list)
    corner_list{k} = [corner_list{k}';1];   
end

corner_list = reshape(corner_list,9,6)';
corners =   [ corner_list{1,:} ];
dr = struct('u',mat2cell(corners,3,ones(1,size(corners,2))));

[h,w,~] = size(img);
cc = [w/2 h/2];
solver = RANSAC.WRAP.pt1x3_to_q(cc);
corresp = ones(1,numel(dr));

model_list = solver.fit(dr,corresp,numel(corresp));

uimg = IMG.ru_div(img,model_list{2}.q);
figure;imshow(uimg);
uimg = IMG.output_undistortion(img,uimg);


figure;
imshow(uimg);
