function patch = getMR_around_line(points,thetas,kappas,PE,img)
n_pts = numel(thetas);
n_segments = 8;
step = floor(n_pts / n_segments);
PE.height = 41;

patch_top = [];
patch_bottom = [];

thetas = -pi/2 - thetas;% - 3*pi/2;

add_top_angle = 0;%2*pi/2;

x_start = points(1,1);
y_start = points(2,1);
kappa_start = kappas(1);
theta_start = thetas(1);
if kappa_start > 0
    radius_start = min(1 / kappa_start, PE.height);
else
    radius_start = PE.height;
end
x_start_bottom = x_start + radius_start*sin(theta_start);
y_start_bottom = y_start + radius_start*cos(theta_start);

x_start_top = x_start - radius_start*sin(add_top_angle + theta_start);
y_start_top = y_start - radius_start*cos(add_top_angle + theta_start);

line([x_start_bottom, x_start_top],[y_start_bottom, y_start_top],'Color','g','LineWidth',4)
for i = 1:n_segments
    if i ~= n_segments
        x_finish = points(1,i*step);
        y_finish = points(2,i*step);
        kappa_finish = kappas(i * step);
        theta_finish = thetas(i * step);
    else
        x_finish = points(1,end);
        y_finish = points(2,end);
        kappa_finish = kappas(end);
        theta_finish = thetas(end);
    end
    
    
    if kappa_finish > 0
        radius_finish = min(1 / kappa_finish, PE.height);
    else
        radius_finish = PE.height;
    end
    x_finish_bottom = x_finish + radius_finish*sin(theta_finish);
    y_finish_bottom = y_finish + radius_finish*cos(theta_finish);
    
    x_finish_top = x_finish - radius_finish*sin(add_top_angle + theta_finish);
    y_finish_top = y_finish - radius_finish*cos(add_top_angle + theta_finish);
    
     line([x_finish_bottom, x_finish_top],[y_finish_bottom, y_finish_top],'Color','k','LineWidth',4)
     line([x_start_bottom, x_finish_bottom],[y_start_bottom, y_finish_bottom],'Color','y','LineWidth',4)
     line([x_start_top, x_finish_top],[y_start_top, y_finish_top],'Color','m','LineWidth',4)
     line([x_start, x_finish],[y_start, y_finish],'Color','c','LineWidth',4)
   
     current_img_points_top = [ x_start_top x_finish_top x_finish x_start;
        y_start_top y_finish_top y_finish  y_start]';
    
    current_norm_points = [1, 1,   41,  41;
      41, 1, 1,41]';
  
    tform = estimateGeometricTransform(current_img_points_top,current_norm_points,  'projective');

    
  pp = imwarp_same(img,tform);
  pp = flipud(pp(1:41,1:41));
  %size(pp)

  %figure()
  %imshow(pp(:,1:30))
 
 %   size(pp)
 %size()
 if size(patch_top) == 0
     patch_top = imresize(pp,[41,PE.px_per_pt], 'method', 'bicubic');
 else
     patch_top = [patch_top ;imresize(pp,[41,PE.px_per_pt], 'method', 'bicubic')];
   % patch(1:41, 1+ (i-1) * PE.px_per_pt:  (i) * PE.px_per_pt) = copy(pp(:,1:30));% 
 end
      current_img_points_bottom = [ x_start x_finish x_finish_bottom x_start_bottom;
        y_start y_finish y_finish_bottom  y_start_bottom]';
    
    current_norm_points = [1, 1,   41,  41;
      41, 1, 1,41]';
  
    tform = estimateGeometricTransform(current_img_points_bottom,current_norm_points,  'projective');

    
  pp = imwarp_same(img,tform);
  pp = flipud(pp(1:41,1:41));
  %size(pp)

  %figure()
  %imshow(pp(:,1:30))
 
 %   size(pp)
 %size()
 if size(patch_bottom) == 0
     patch_bottom = imresize(pp,[41,PE.px_per_pt], 'method', 'bicubic');
 else
     patch_bottom = [patch_bottom ;imresize(pp,[41,PE.px_per_pt], 'method', 'bicubic')];
   % patch(1:41, 1+ (i-1) * PE.px_per_pt:  (i) * PE.px_per_pt) = copy(pp(:,1:30));% 
 end
 
 
    x_start = x_finish;
    y_start = y_finish;
    x_start_bottom = x_finish_bottom;
    y_start_bottom = y_finish_bottom;
    
    x_start_top = x_finish_top;
    y_start_top = y_finish_top;
          kappa_start = kappa_finish;
        theta_start = theta_finish;
end

patch = [patch_top patch_bottom]';
%patch = patch(30:end-30,:);
end