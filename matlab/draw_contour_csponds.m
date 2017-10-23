function [] = draw_contour_csponds(cspond_list,img1,contour_list1,img2,contour_list2)
G1 = [contour_list1(:).G]; 
uG1 = unique(G1);
G2 = [contour_list2(:).G];
uG2 = unique(G2);

figure;
subplot(1,2,1);
imshow(img1);
subplot(1,2,2);
imshow(img2);
for k = 1:numel(cspond_list)
    subplot(1,2,1);
    hold on;
    for k2 = 1:numel(cspond_list(k).left)
        ind = find(G1 == cspond_list(k).left(k2));
        x = [contour_list1(ind).x];
        plot(x(1,:),x(2,:),'g');
    end
    hold off;
    
    subplot(1,2,2);
    hold on;
    for k2 = 1:numel(cspond_list(k).right)
        ind = find(G2 == cspond_list(k).right(k2));
        x = [contour_list2(ind).x];
        plot(x(1,:),x(2,:),'g');
    end
    hold off;
end
