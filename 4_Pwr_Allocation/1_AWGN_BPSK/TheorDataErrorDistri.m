function pn = TheorDataErrorDistri(Np, ebnoUnit, channel)
% 
% Calculate theoretical data error distribution
% Used for BPSK modulation
% A theiretical BER calculation function is defined in the end
% 
% Author:  Zhiyu Shen
% Date:    Sept 8, 2022
% Project: Channel Modeling - iSure 2022
%
% Input Argument:
%   @Np      : Number of bits in a pack
%   @ebnoUnit: Eb/N0 for each bit
%   @channel : Type of channel model
%                0: AWGN channel
%                1: Rayleigh fading channel
%                ......
% 
% Output Argument:
%   @pn: Theoretical probability dencity function of data error
%

%%% Calculate theoretical BER for each bit

% Calculate theoretical BER for each bit
pe = BerFun(ebnoUnit, channel);


%%% Calculate data error ditribution according to recurrence formula

% Initial data error PDF when Np = 1, k = 0
k = 0;
Nerr = 2^(k+2) - 1;
fn = zeros(Nerr, 1);
fn(1) = pe(Np)/2;
fn(2) = 1-pe(Np);
fn(3) = fn(1);
zeroIdx = 2^(k+1);                              % Index of zero dat error point
    
% Calculate data error ditribution according to recurrence formula
% fn represents PDF of data error when pack size is k
% gn represents PDF of data error when pack size is k + 1
for k = 1 : Np-1
    
    % Define parameters and allocate space for vector
    Nerr = 2^(k+2) - 1;
    zeroIdxPre = zeroIdx;                       % Index of zero dat error point at previous iteration
    zeroIdx = 2^(k+1);                          % Index of zero dat error point
    gn = zeros(Nerr, 1);
    % Calculate value of PDF at zero data error and middle data error point
    gn(zeroIdx) = prod(1 - pe(Np-k : Np));
    gn(zeroIdx+2^k) = 1/2 * pe(Np-k) * fn(zeroIdxPre);
    % Calculate value of PDF at points larger than 0
    for i = 1 : 2^k-1
        gn(zeroIdx+i) = 1/2 * pe(Np-k) * fn(zeroIdxPre+i-2^k) + ...
                        (1-pe(Np-k)) * fn(zeroIdxPre+i);
        gn(zeroIdx+2^k+i) = 1/2 * pe(Np-k) * fn(zeroIdxPre+i);
    end
    % Assign value of PDF at points smaller than 0
    tn = flip(gn(zeroIdx+1 : Nerr));
    gn(1 : zeroIdx-1) = tn;
    fn = gn;

end

pn = gn;

end


function theorBER = BerFun(EbNo, channel)
% 
% Calculate theoretical BER according to Eb/N0
% BPSK modulation
%
% Input Argument:
%   @Eb_N0  : Eb/N0 for each bit
%   @Channel: Type of channel model
%               0: AWGN channel
%               1: Rayleigh fading channel
%               ......
% 
% Output Argument:
%   @theorBER: Theoretical BER for each bit
%

% AWGN channel
if channel == 0
    theorBER = qfunc(sqrt(2*EbNo));
% Rayleigh fading channel
elseif channel == 1
    theorBER = 0.5 * (1- sqrt(EbNo./(1+EbNo)));
end

end