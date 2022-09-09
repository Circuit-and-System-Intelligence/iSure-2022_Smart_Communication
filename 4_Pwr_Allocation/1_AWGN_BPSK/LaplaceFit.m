function [Ln, Idx] = LaplaceFit(X, Np)
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
%

% Estimate distribution parameter
N = length(X);                                              % Length of sequence
mu = sum(X) / N;                                            % Estimate distribution's mean

sigma = sum(abs(X-mu)) / N;                                      % Estimate distribution's standard deviation
Idx = mu + linspace(-2^Np, 2^Np, 1000);                     % Generate xprim vector
Ln = 1 / (2*sigma) * exp(-abs(Idx)/sigma);                  % Calculate the Laplace PDF

end