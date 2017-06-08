syms u1 v1 u2 v2 u3 v3 q real
xb

x1 = transpose([u1 v1 1+q*(u1^2+v1^2)]);
x2 = transpose([u2 v2 1+q*(u2^2+v2^2)]);
x3 = transpose([u3 v3 1+q*(u3^2+v3^2)]);

expr = dot(x2,cross(x1,x3));
res = solve(expr == 0,q,'ReturnCondition',true);
