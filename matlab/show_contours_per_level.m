function show_contours_per_level(contours_per_level, pyr)

for i = 1:numel(contours_per_level)

    [h,w,ch] = size(  pyr{i} );
    contours = contours_per_level{i};
    if numel(contours) > 0
            
    figure()
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
end
end


