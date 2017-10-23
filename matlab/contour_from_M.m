function contour =  contour_from_M(M,idx, w, h)

related_idxs = M(:,3) == idx;
xy = M(related_idxs,1:2)';
xy(1,:) = xy(1,:) * double(w);
xy(2,:) = xy(2,:) * double(h);
G = mat2cell(M(related_idxs,3)',1,ones(1,numel(M(related_idxs,3)))');
theta = mat2cell(M(related_idxs,4)',1,ones(1,numel(M(related_idxs,4)))');
kappa = mat2cell(M(related_idxs,5)',1,ones(1,numel(M(related_idxs,5)))');
x = mat2cell(xy, 2,ones(1,numel(M(related_idxs,1))));
contour = struct('x', x, 'G', G, 'theta', theta, 'kappa', kappa);

end