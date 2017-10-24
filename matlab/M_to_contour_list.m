function out = M_to_contour_list(M, w, h)

xy = M(:,1:2)';
xy(1,:) = xy(1,:) * double(w);
xy(2,:) = xy(2,:) * double(h);
G = mat2cell(M(:,3)',1,ones(1,numel(M(:,3)))');
theta = mat2cell(M(:,4)',1,ones(1,numel(M(:,4)))');
kappa = mat2cell(M(:,5)',1,ones(1,numel(M(:,5)))');
x = mat2cell(xy, 2,ones(1,numel(M(:,1))));
out = struct('x', x, 'G', G, 'theta', theta, 'kappa', kappa);

end