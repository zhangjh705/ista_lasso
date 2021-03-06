function x = opt_ista_lasso(h,y,x0,opt,hfun)
% The objective function: F(x) = 1/2 ||y - hx||^2 + lambda |x|
% Input: 
%   h: impulse response (lexicographically arranged)
%   y: degraded image (vector)
%   x0: initialization (vector)
%   opt.lambda: weight constant for the regularization term
%   hfun: functions
% Output:
%   x: output image
%
% Author: Seunghwan Yoo

fprintf(' - Running ISTA Method\n');

A = h; b = y;
AtA = A'*A;
evs = eig(AtA);
L = max(evs);
l = 1/L;

lambda = opt.lambda;
maxiter = opt.maxiter; %10000;
tol = opt.tol;
vis = opt.vis;

% k-th (k=0) function, gradient, hessian
objk  = func(x0,b,A,lambda);
%gradk = grad(x0,b,A);
xk = x0;

tic;
fprintf('%6s %9s %9s\n','iter','f','sparsity');
fprintf('%6i %9.2e %9.2e\n',0,objk,nnz(xk)/numel(xk));
for i = 1:maxiter
    x_old = xk;
    
    y = xk - l*(AtA*xk-A'*b); 
    %y = xk - l*A'*(A*xk-b);
    xk = subplus(abs(y)-lambda/L) .* sign(y); % shrinkage operation

    if vis > 0
        fprintf('%6i %9.2e %9.2e\n',i,func(xk,b,A,lambda),nnz(xk)/numel(xk));
    end
    if norm(xk-x_old)/norm(x_old) < tol
        fprintf('%6i %9.2e %9.2e\n',i,func(xk,b,A,lambda),nnz(xk)/numel(xk));
        fprintf('  converged at %dth iterations\n',i);
        break;
    end
end
toc;
x = xk;


function objk = func(xk,b,A,lambda)
e = b - A*xk;
objk = 0.5*(e)'*e + lambda*sum(abs(xk));
