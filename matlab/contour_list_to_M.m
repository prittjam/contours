function M = contour_list_to_M(contour_list, w, h)
M = [];

x = [contour_list(:).x];
G = [contour_list(:).G];

X = cmp_splitapply(@(x) { [x;ones(1,size(x,2))] }, ...
    [contour_list(:).x],[contour_list(:).G]);
Gsz  = cellfun(@(x) numel(x),X);
[~,ind] = sort(Gsz,'descend');


num_patches = numel(Gsz);


for k = 1:num_patches
    contour = contour_list(G==ind(k));
   % disp(contour);
    M_curr = zeros(numel(contour), 5);
    xy = [contour(:).x];
    M_curr(:,1) = double(xy(1,:)) / double(w);
    M_curr(:,2) = double(xy(2,:)) / double(h);
    M_curr(:,3) = [contour(:).G];
    M_curr(:,4) = [contour(:).theta];
    M_curr(:,5) = [contour(:).kappa];
    if (k > 1)
        M = [M;M_curr];
    else
        M = M_curr;
    end
end

end
