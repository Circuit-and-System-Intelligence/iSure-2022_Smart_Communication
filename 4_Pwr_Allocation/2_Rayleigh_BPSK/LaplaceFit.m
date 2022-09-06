function LaplaceFit(X, Np)
% 
% Laplace distribution fit
% 
% Author:  Zhiyu Shen
% Date:    Aug 30, 2022
% Project: Channel Modeling - iSure 2022
%
% Input Argument:
%   @X:  Sequence to be fitted
%   @Np: Pack size
%

% Estimate distribution parameter
N = length(X);                                              % Length of sequence
mu = sum(X) / N;                                            % Estimate distribution's mean

sigma = sum(abs(X-mu)) / N;                                 % Estimate distribution's standard deviation
xprim = mu + linspace(-2^Np, 2^Np, 1000);                   % Generate xprim vector
fx = 1/(sqrt(2)*sigma) * exp(-abs(xprim-mu)/sigma);         % Calculate the Laplace PDF

% Normalize the pdf
pn = FreqCal(X, Np);                                         % Calculate the frequence of each error (Normalized)
xn = -2^Np + 1 : 1 : 2^Np - 1;                              % Range of data error

% Figure settings
figure(1);
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
title('Data Error Distribution and Its Laplace Fit');

% Plot actual distribution
stem(xn, pn, "LineWidth", 2, "Color", "#0072BD")
hold on

% Plot the Laplace PDF 
plot(xprim, fx, "LineWidth", 2, "Color", "#D95319")
hold off

% Set the plotting properties
xlim([-2^Np 2^Np])
ylim([0 max(pn) * 2])
set(gca, 'Fontsize', 20, 'Linewidth', 2);

end