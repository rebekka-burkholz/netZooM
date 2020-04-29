function W = otter(W,P,C,lambda,gamma,Imax,eta)
% Description:
%               OTTER infers gene regulatory networks using TF DNA binding
%               motif (W), TF PPI (P), and gene coexpression (C) through 
%               minimzing the following objective:
%                                  min f(W) 
%               with f(W) = (1-lambda)/4*||WW' - P||^2 + (lambda/4)*||W'W - C||^2 + (gamma/2)*||W||^2
%
% Inputs:
%               W     : TF-gene regulatory network based on TF motifs as a
%                       matrix of size (t,g), g=number of genes, t=number of TFs
%               P     : TF-TF protein interaction network as a matrix of size (t,t)
%               C     : gene coexpression as a matrix of size (g,g) 
%               lambda: it should be in [0,1].
%               gamma : penalization term
%               Imax  : number of iterations of the algorithm
%               eta   : 
%                       
% Outputs:
%               W  : Predicted TF-gene complete regulatory network as an adjacency matrix of size (t,g).
%
% Authors: 
%               Rebekka Burkholz 4/2020

%global parameters
if nargin<4
    lambda = 0.0035;
end
if nargin<5
    gamma = 0.335;
end
if nargin<6
    Imax = 300;
end
if nargin<7
    eta = 0.00001;
end
%ADAM parameters
b1 = 0.9;
b2 = 0.999;
eps = 0.00000001;
%initial transformation
C = C/trace(C);
P = P/trace(P) + 0.0013;
W = P*W;
W = W/sqrt(trace(W*W'));

[nTF, nGenes] = size(W);
m = zeros(nTF, nGenes);
v = m;
b1t = b1;
b2t = b2;
%To save computations:
P = -P*(1-lambda) + gamma*eye(nTF);
C = -C*lambda;
%ADAM gradient descent                  
for i = 1:Imax
    %gradient
    grad = (P*W + W*C + W*W'*W);
    m = b1*m + ((1-b1)*4)*grad;
    v = b2*v + ((1-b2)*16)*grad.^2; 
    b1t = b1t*b1;
    b2t = b2t*b2;
    alpha = sqrt(1-b2t)/(1-b1t)*eta;
    epst = eps*sqrt((1-b2t));
    %update of gene ragulatory matrix
    W = W - alpha*(m./(epst+sqrt(v)));
end
end