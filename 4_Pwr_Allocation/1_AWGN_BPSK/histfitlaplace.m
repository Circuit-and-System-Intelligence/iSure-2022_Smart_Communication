%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Histogram with a Laplace distribution fit       %
%              with MATLAB Implementation              %
%                                                      %
% Author: M.Sc. Eng. Hristo Zhivomirov        04/29/15 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function histfitlaplace(x)

% function: histfitlaplace(x)
% x - data sequence (vector)

% distribution parameters estimation
mu = mean(x);                                               % find the distribution mean
sigma = std(x);                                             % find the distribution std
xprim = mu + linspace(-3*sigma, 3*sigma, 1000);             % xprim vector generation [-3*sigma+mu 3*sigma+mu]
fx = 1/(sqrt(2)*sigma)*exp(-sqrt(2)*abs(xprim-mu)/sigma);   % calculate the Laplace PDF

% normalize the pdf using the area of the histogram
bins = round(sqrt(length(x)));  % number of the histogram bins
n = length(x);                  % length of the data
r = max(x) - min(x);            % range of the data
binwidth = r/bins;              % width of each bin
area = n*binwidth;              % area of the histogram
fx = area*fx;                   % normalize the pdf

% plot the histogram
hHist = histogram(x, bins, 'EdgeColor', 'auto');
hold on

% plot the Laplace PDF 
plot(xprim, fx, '-r', 'LineWidth', 1.5)

% set the axes limits
dxl = mu - min(x);
dxr = max(x) - mu;
xlim([mu-1.1*dxl mu+1.1*dxr])
ylim([0 1.1*max(max(fx), max(get(hHist, 'Values')))])

end