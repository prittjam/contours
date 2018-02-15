function [total_contours, contours_per_level, pyr] = detect_contours_on_pyramid(img_fname)
dlines_init();
img = imread(img_fname);

rad = 40;
T = 10.0;
Tinl = 0.75;
Tidx = 0.75;

pyr = {};
i = 1;
pyr{1} = img;
[h,w,ch] = size(img);
while min(h,w) > 2*rad
    i = i + 1;
    pyr{i} = impyramid(pyr{i-1}, 'reduce');
    [h,w,~] = size(  pyr{i} );
end
num_pyr_levels = numel(pyr);

Ms = {};

for i=1:num_pyr_levels
    [h,w,ch] = size(  pyr{i} );
    E = DL.extract_contours(pyr{i});
    contour_list = DL.segment_contours(E,...
        'min_response',1e-3, ...
        'max_kappa', inf, ...
        'min_length', 10,...
        'kappa_stride', 1, ...
        'theta_stride', 1);
    
    Ms{i} =  contour_list_to_M(contour_list, w, h);
    Ms{i} = smooth_contours(Ms{i});
end
%%
MS_out = {};

for i = num_pyr_levels - 1:-1:1
    
    idxs_get_from_prev_level = [];
    [h,w,ch] = size(  pyr{i} );
    if i == num_pyr_levels - 1
        db = Ms{i+1};
        Ms_out{i+1} = Ms{i+1};
    end
    %%Upsample db
    db_ups = zeros(2*size(db,1),5);
    db_ups_st = 1;
    for jj=1:max(db(:,3))
        c_idx = find(db(:,3) == jj);
        n_pts = numel(c_idx);
        db_ups_end = db_ups_st + 2*n_pts -1;
        db_ups(db_ups_st:db_ups_end,1) = interp1(linspace(1,n_pts,n_pts),...
            db(c_idx,1), linspace(1,n_pts,2*n_pts), 'linear');
        
        db_ups(db_ups_st:db_ups_end,2) = interp1(linspace(1,n_pts,n_pts),...
            db(c_idx,2), linspace(1,n_pts,2*n_pts),'linear');
        db_ups(db_ups_st:db_ups_end,3) = db(c_idx(1),3);
        
        db_ups(db_ups_st:db_ups_end,4) = interp1(linspace(1,n_pts,n_pts),...
            db(c_idx,4), linspace(1,n_pts,2*n_pts),'linear');
        db_ups(db_ups_st:db_ups_end,5) = interp1(linspace(1,n_pts,n_pts),...
            db(c_idx,5), linspace(1,n_pts,2*n_pts),'linear');
        db_ups_st = db_ups_end  +1;
    end
    db = db_ups;
    
    
    db(:,1) = w * db(:,1);
    db(:,2) = h * db(:,2);
    kdts = KDTreeSearcher(db(:,1:2));
    
    query = Ms{i};
    query(:,1) = w * query(:,1);
    query(:,2) = h * query(:,2);
    
    [idx_in_db,d] = knnsearch(kdts,query(:,1:2));
    
    
    inl = d <= T;
    gidx = db(idx_in_db,3);
    
    for iiii = 1:max(query(:,3))
        c_idx = find(query(:,3) == iiii);
        c1 = gidx(c_idx);
        ccc = mode(c1);
        curr_inl = inl(c_idx);
        same_idxs_score = double(sum(c1 == ccc)) / double(numel(c1));
        bigger_idx =  find(db(:,3) == ccc);
        
        inl_score = double(sum(curr_inl)) / double(numel(curr_inl));
        
        if (inl_score > Tinl) && (same_idxs_score >= Tidx)
            
            %iiii
            %inl_score
            %same_idxs_score
            %imshow(pyr{i});
            %hold on;
            %plot(query(c_idx,1),   query(c_idx,2) ,'g.');
            %plot(db(bigger_idx,1), db(bigger_idx,2),'r.');
            %hold off;
            
            %break
        else
            
            idxs_get_from_prev_level = [idxs_get_from_prev_level, iiii];
        end
    end
    keep_on_this_level = [];
    if numel(idxs_get_from_prev_level) > 0
        max_cont = max(db(:,3));
        
        for idx_to_add =1:numel(idxs_get_from_prev_level)
            c_idx = find(query(:,3) == idx_to_add);
            cont_to_add = query(c_idx, :);
            
            cont_to_add(:,3) = idx_to_add;
            keep_on_this_level = [keep_on_this_level ; cont_to_add];
        end
        
        keep_on_this_level(:,1) = keep_on_this_level(:,1) / double(w);
        keep_on_this_level(:,2) = keep_on_this_level(:,2) / double(h);
    end
    Ms_out{i} = keep_on_this_level;
    db(:,1) = db(:,1) / double(w);
    db(:,2) = db(:,2) / double(h);
    
    if numel(idxs_get_from_prev_level) > 0
        keep_on_this_level(:,3) = keep_on_this_level(:,3) + max_cont;
        db = [db;  keep_on_this_level];
    end
    size(db)
end
total_contours = db;
contours_per_level = Ms_out;
end