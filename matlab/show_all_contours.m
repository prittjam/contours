function show_all_contours(total_contours, pyr)

i =2;
figure()
[h,w,ch] = size(  pyr{i} );
contours = total_contours;

num_contours = max(contours(:,3));

colors = distinguishable_colors(num_contours);

imshow(pyr{i});

for k = 1:num_contours
    c_idxs  = find(contours(:,3) == k);
    x = contours(c_idxs,1) * w;
    y = contours(c_idxs,2) * h;
    
    hold on;
    plot(x,y,'g.','Color',colors(k,:));
    hold off;
end
pause(1)
end