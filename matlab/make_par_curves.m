function [curve_list,un] = make_par_contours(contour,sc_list)
xc = [contour(:).x];
sigma = 5;
xg = -3*sigma:3*sigma;
g = exp(-xg.^2/(2*sigma^2));
g = g / sum(g); % normalizea
xcx = reshape(padarray([xc(1,:)]',3*sigma,'replicate'),1,[]);
xcxfilt = conv(xcx, g, 'valid');
xcy= reshape(padarray([xc(2,:)]',3*sigma,'replicate'),1,[]);
xcyfilt = conv(xcy, g, 'valid');

x = [xcxfilt;xcyfilt];

df = gradient(x,10);
df2 = gradient(df,10);

n = [df(2,:); -df(1,:)];
un = n./sqrt(sum(n.^2));

% % determine radius of curvature
R=(df(1,:).^2+df(2,:).^2).^(3/2)./abs(df(1,:).*df2(2,:)-df(2,:).*df2(1,:));

% % Determine concavity
concavity=2*(df2(2,:) > 0)-1;

% % Determine overlap points for inner normal curve
for k = 1:numel(sc_list)
    curve_list(k).overlap = R < sc_list(k);
    curve_list(k).x1 = x-sc_list(k)*un;
    curve_list(k).x2 = x+sc_list(k)*un;
    curve_list(k).scale = sc_list(k);
end
