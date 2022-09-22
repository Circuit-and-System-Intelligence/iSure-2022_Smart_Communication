function pn = FreqCal(fn, Np)
% 
% Calculate the frequency of different error values in a receive sequence
% 
% Author:  Zhiyu Shen
% Date:    Aug 19, 2022
% Project: Channel Modeling - iSure 2022
%
% Input Argument:
%   @fn: Received data error sequence
%   @Np: Number of bits in a pack
% 
% Output Argument:
%   @pn: Probability dencity function of data error
%

N = length(fn);
Ne = 2^(Np + 1) - 1;
cn = zeros(1, Ne);

for i = 1 : N
    eIdx = fn(i) + 2^Np;
    cn(eIdx) = cn(eIdx) + 1;
end

pn = cn / N;

end

