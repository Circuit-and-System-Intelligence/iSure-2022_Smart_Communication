function pn = TheorDataErrorDistri(Np, Eb_N0)
% 
% Calculate theoretical data error distribution
% BPSK modulation
% 
% Author:  Zhiyu Shen
% Date:    Sept 8, 2022
% Project: Channel Modeling - iSure 2022
%
% Input Argument:
%   @Np:    Number of bits in a pack
%   @Eb_N0: Eb/N0 for MSB
% 
% Output Argument:
%   @pn: Theoretical probability dencity function of data error
%

% Calculate transmission power ratio for each bit
idxNp = (Np : -1 : 1).';
txPwrRat = (exp(idxNp - Np)).^2;            % Ratio of transmission power

% Calculate true Eb/N0 for each bit
rou = 10^(Eb_N0 / 10);                      % Eb/N0 of MSB in units of 1
trueEbN0 = rou * txPwrRat;                  % Actual Eb/N0 for each bit

% Calculate theoretical BER for each bit
theorBER = BERFun(trueEbN0);

end


function theorBER = BERFun(Eb_N0)
% 
% Calculate theoretical BER according to Eb/N0
% BPSK modulation
%
% Input Argument:
%   @Eb_N0: Eb/N0 for each bit
% 
% Output Argument:
%   @theorBER: Theoretical BER for each bit
%

theorBER = qfunc(sqrt(2 * Eb_N0));

end