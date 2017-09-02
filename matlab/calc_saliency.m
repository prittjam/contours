function rgn_stats = calc_saliency(rgn_stats)
    num_rgns = numel(rgn_stats);

    W = zeros(1,num_rgns);
    for k = 2:num_rgns-1
        W(k) = rgn_stats(k).area/(rgn_stats(k).area-rgn_stats(k-1).area) * ...
               (sum(abs(rgn_stats(k).pmf-rgn_stats(k-1).pmf))) + ...
               rgn_stats(k+1).area/(rgn_stats(k+1).area-rgn_stats(k).area) * ...
               (sum(abs(rgn_stats(k+1).pmf-rgn_stats(k).pmf)));
    end
    W = W/2;

    k = 1;
    W(1) = rgn_stats(k+1).area/(rgn_stats(k+1).area-rgn_stats(k).area) * ...
            (sum(abs(rgn_stats(k+1).pmf-rgn_stats(k).pmf)));

    k = numel(W);
    W(end) = rgn_stats(k).area/(rgn_stats(k).area-rgn_stats(k-1).area) * ...
              (sum(abs(rgn_stats(k).pmf-rgn_stats(k-1).pmf)))

    Y = W.*[rgn_stats(:).H];
    Yc = mat2cell(Y,1,ones(1,numel(Y)));
    
    [rgn_stats(:).Y] = Yc{:};
