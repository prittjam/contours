function out= GetDist2(d1,d2,dist_type, desc_name)
min_k_pts = size(d1,1);
out = zeros(min_k_pts,4);
batch_size = 250;
real_max=1000000;
if min_k_pts > batch_size
    n_batches = floor(min_k_pts/batch_size);
    remaind = rem(min_k_pts, batch_size);
    for batch_idx=1:n_batches
        idxs=1+(batch_idx-1)*batch_size:batch_idx*batch_size;
        if strcmp(dist_type,'L2')
            distances = slmetric_pw(d1(idxs,:)', d2', 'eucdist');
        end
        if strcmp(dist_type,'L1')
            distances = slmetric_pw(d1(idxs,:)', d2', 'cityblk');
        end
        if strcmp(dist_type,'Hamming')
            if strcmp(desc_name,'BICE')
                distances = slmetric_pw(d1(idxs,:)', d2', 'hamming');
            else
                distances =  hamdist(d1(idxs,:),d2);
            end
        end
        if strcmp(dist_type,'Gav')
            distances =  hamdist2(d1(idxs,:),d2);
        end
        
        [nearest_d, nearest_ind] = min(distances,[],2);
        % disp(size(nearest_ind));
        % disp(size(out(idxs,2)));
        
        distances(:,nearest_ind) = real_max;
        [sec_nearest_d, ~] = min(distances,[],2);
        ratio=nearest_d ./ sec_nearest_d;
        
        out(idxs,1) = idxs;
        out(idxs,2) = nearest_ind(:);
        out(idxs,3) = nearest_d(:);
        out(idxs,4) = ratio(:);
        
    end
    if (remaind > 0)
        idxs=1+n_batches*batch_size:min_k_pts;
        if strcmp(dist_type,'L2')
            distances = slmetric_pw(d1(idxs,:)', d2', 'eucdist');
        end
        if strcmp(dist_type,'L1')
            distances = slmetric_pw(d1(idxs,:)', d2', 'cityblk');
        end
        if strcmp(dist_type,'Hamming')
            if strcmp(desc_name,'BICE')
                distances = slmetric_pw(d1(idxs,:)', d2', 'hamming');
            else
                distances =  hamdist(d1(idxs,:),d2);
            end
            
        end
        [nearest_d, nearest_ind] =  min(distances,[],2);
        distances(:,nearest_ind)=real_max;
        [sec_nearest_d, ~] =  min(distances,[],2);
        ratio=nearest_d ./ sec_nearest_d;
        
        out(idxs,1) = idxs;
        out(idxs,2) = nearest_ind;
        out(idxs,3) = nearest_d;
        out(idxs,4) = ratio;
        
    end
else
    idxs=1:min_k_pts;
    if strcmp(dist_type,'L2')
        distances = slmetric_pw(d1(idxs,:)', d2', 'eucdist');
    end
    if strcmp(dist_type,'L1')
        distances = slmetric_pw(d1(idxs,:)', d2', 'cityblk');
    end
    if strcmp(dist_type,'Hamming')
        if strcmp(desc_name,'BICE')
            distances = slmetric_pw(d1(idxs,:)', d2', 'hamming');
        else
            distances =  hamdist(d1(idxs,:),d2);
        end
    end
    [nearest_d, nearest_ind] = min(distances,[],2);
    distances(:,nearest_ind)=real_max;
    [sec_nearest_d, ~] = min(distances,[],2);
    ratio=nearest_d ./ sec_nearest_d;
    
    out(idxs,1) = idxs;
    out(idxs,2) = nearest_ind;
    out(idxs,3) = nearest_d;
    out(idxs,4) = ratio;
end
