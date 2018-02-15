function M =  smooth_contours(M)
gausw = gausswin(11);
gausw = gausw / sum(gausw);
for j = 1:max(M(:,3))
    idxs  = find(M(:,3) == j);
    Cc = M(idxs,:);
    
    y = filter(gausw,1,padarray(Cc(:,1),10,'replicate'));
    yy = y(11:end-10,:);
    M(idxs,1) = yy;
    
    y = filter(gausw,1,padarray(Cc(:,2),10,'replicate'));
    yy = y(11:end-10,:);
    M(idxs,2) = yy;
    y = filter(gausw,1,padarray(Cc(:,4),10,'replicate'));
    yy = y(11:end-10,:);
    M(idxs,4) = yy;
    y = filter(gausw,1,padarray(Cc(:,5),10,'replicate'));
    yy = y(11:end-10,:);
    M(idxs,5) = yy;
end
end