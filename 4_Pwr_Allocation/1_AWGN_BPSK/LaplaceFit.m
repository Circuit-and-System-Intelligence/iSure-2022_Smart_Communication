function [Ln, Idx, mu, b] = LaplaceFit(X, Np)
% 
% Laplace distribution fit (Improved for data error distribution)
% 
% Author:  Zhiyu Shen
% Date:    Sept 6, 2022
% Project: Channel Modeling - iSure 2022
%
% Input Argument:
%   @X:    Sequence to be fitted
%   @Np:   Pack size
%
% Output Argument:
%   @Ln:  Laplace distribution fit sequence
%   @Idx: Index of distribution sequence
%   @mu:  Estimated mean of Laplace distribution
%   @b:   Estimated standard variance of Laplace distribution
%

% Estimate distribution parameter
N = length(X);                                              % Length of sequence
mu = sum(X) / N;                                            % Estimate distribution's mean

b = sum(abs(X-mu)) / N;                                     % Estimate distribution's standard deviation
% Idx = mu + linspace(-2^Np+1, 2^Np-1, 1000);                 % Generate xprim vector
Idx = -2^Np+1 : 1 : 2^Np-1;
Ln = 1 / (2*b) * exp(-abs(Idx)/b);                          % Calculate the Laplace PDF

end