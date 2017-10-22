function contour_listp = xfer_contour_list(contour_list,H)
x = [contour_list(:).x];
theta = [contour_list(:).theta];
G = [contour_list(:).G];

xp = PT.renormI(H*[x;ones(1,size(x,2))]);

a = cos(theta);
b = sin(theta);
c = -dot([a;b],xp(1:2,:));

l = [cos(theta); sin(theta); c];
lp = inv(H)'*l;
nlp = LINE.inhomogenize(lp);

thetap = atan2(nlp(2,:),nlp(1,:));

contour_listp = struct('x',mat2cell(xp(1:2,:),2,ones(1,size(x,2))), ...
                       'G',mat2cell(G,1,ones(1,numel(G))), ...
                       'thetap',mat2cell(theta,1,ones(1,numel(theta))));
