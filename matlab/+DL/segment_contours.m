function pts = segment_contours(E)
[ny,nx] = size(E);
E1 = E;

E1(E1 < 0.001) = 0;
E1(E1 ~= 0) = 1;

E2 = bwmorph(E1,'thin',Inf);
E3 = bwmorph(E2,'spur',5);

B = edgelink(E3,15);
Bsz = cellfun(@(x) size(x,1),B);

G = repelem(1:numel(B),Bsz);

x = cat(1,B{:})';

[x(1,:),x(2,:)] = deal(x(2,:),x(1,:));
ind = sub2ind([ny nx],x(2,:),x(1,:));
pts = struct('x',mat2cell(x,2,ones(1,size(x,2))), ...
             'G',mat2cell(G,1,ones(1,numel(G))));

tmp = mat2cell(findgroups([pts(:).G]), ...
               1,ones(1,numel(pts)));
[pts(:).G] = tmp{:}; 

x = [pts(:).x];
G = [pts(:).G];
 
dy_dx = ...
    msplitapply(@(x) dlines('calc_orientation',x,'stride',2), ...
                x,G);
kappa = msplitapply(@(x) dlines('calc_curvature',x,'stride',5), ...
                    x,G);
uG = unique(G);
maxGc = 0;
for g = 1:numel(uG)
    iG = find(G==g);
    Gc = break_contour(dy_dx(iG),kappa(iG));
    if ~all(isnan(Gc))
        Gc = findgroups(msplitapply(@(g) min_size(g),Gc,Gc));
        Gc = Gc+maxGc;
        ng = sum(~isnan(unique(Gc)));
        maxGc = maxGc+ng;
    end
    tmp = mat2cell(Gc,1,ones(1,numel(Gc)));    
    [pts(iG).G] = tmp{:};
end

function [G,g] = break_contour(dy_dx,kappa)
%dtheta = abs(dy_dx(2:end)-dy_dx(1:end-1));
%ind90 = dtheta > pi/2;
%dtheta(ind90) = pi-dtheta(ind90);
ind = find((kappa > 0.1) & ~isnan(kappa)); 
G = nan(size(kappa));
g = 0;s = 1;
for k = 1:numel(ind)
    if ind(k) > s
        g = g+1;
        G(s:ind(k)-1) = g;
    end
    s = ind(k)+1;
end

function x = min_size(x)
if numel(x) < 20
    x(:) = nan;
end

