function [] = test()
clear

N = 30;
rk = -0.4   ;

% generates some points on a line
n = randn(2,1); n = n / norm(n);
t = randn(2,1); t = t / norm(t);
u0 = [n t] * [-1+2*rand(1,N);ones(1,N)];

% add radial distortion
ud0 = radialdistort(u0,rk);

% add noise
ud = ud0 + 0.001*randn(size(ud0));

keyboard;
k = solver_npoint_rad_dist(ud)

plot(u0(1,:),u0(2,:),'.')
hold on
plot(ud0(1,:),ud0(2,:),'r.')
plot(ud(1,:),ud(2,:),'ro')
hold off
axis equal
axis([-1 1 -1 1]*sqrt(2))
title(sprintf('real k = %.3f, est. k = %.3f',rk,k))
