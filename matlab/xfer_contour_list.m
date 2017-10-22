function contour_listp = xfer_contour_list(contour_list,H)
x = [contour_list(:).x];
theta = [contour_list(:).theta];
G = [contour_list(:).G];

xp = PT.renormI(H*[x;ones(1,size(x,2))]);
l = [cos(theta); ...
     sin(theta); 
     ones(1,numel(theta))];
lp = inv(H)'*l;
thetap = atan2(lp(2,:),lp(1,:));

contour_listp = struct('x',mat2cell(xp(1:2,:),2,ones(1,size(x,2))), ...
                       'G',mat2cell(G,1,ones(1,numel(G))), ...
                       'thetap',mat2cell(theta,1,ones(1,numel(theta))));
