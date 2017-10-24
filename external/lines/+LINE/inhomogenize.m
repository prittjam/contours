function l = inhomogenize(l0)
l = l0./repmat(sqrt(sum(l0(1:2,:).^2)),3,1);
end
