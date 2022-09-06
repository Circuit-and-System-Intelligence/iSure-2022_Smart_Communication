% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 28, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Rayleigh fading channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a specific way

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Gstd = 1;                                   % Standard transmission gain
Np = 4;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Small-Scale fading
Nw = 34;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)

% Signal-to-noise ratio
Eb_N0 = 0;                                  % Average bit energy to single-sided noise spectrum power (dB)
Eb_N0_U = 10^(Eb_N0 / 10);
% Transimitter gain (Take MSB for reference bit)
idxNp = (Np : -1 : 1).';
gainProp = 2.^(idxNp - Np);
% gainProp = exp(idxNp - Np);
% gainProp = [1; 1; 1 / 10; 1 / 10];
Gt = gainProp * Gstd;                       % Gain of ith bit in a pack

% Data error-related parameters
minErr = 0.03;                              % Minimal data error counts
maxErrProp = 1.5;                           % Propotion between the probability of two adjacent data errors


%% Signal source

% Generate sending data (Decimal)
Ndata = 100000;                             % Number of sending datas (Decimalism)
dataSend = randi([0, 2^Np - 1], 1, Ndata);  % Sending data (Decimal)

% Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
Nb = Ndata * Np;                            % Number of bits
txVec = zeros(Np, Ndata);
txSeqRes = dataSend;
for i = 1 : Np
    txVec(i, :) = fix(txSeqRes / 2^(Np - i));
    txSeqRes = txSeqRes - txVec(i, :) * 2^(Np - i);
end
txSeq = reshape(txVec, 1, Nb);          % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation (No phase rotation)
txModSig = 2 * (txSeq - 0.5) * Gstd;
baseLen = length(txModSig);


%% Adjust Transmission Power According to Bit Order

txBbSig = zeros(1, Nb);
for i = 1 : Np
    idxPack = i : Np : Nb;                  % Index of ith bit in a pack
    txBbSig(idxPack) = Gt(i) * txModSig(idxPack);
end
txPwr = abs(txBbSig.^2);


%% Go through Rayleigh Fading Channel

h0 = RayleighFadingChannel(Nw, fm, Nb, Feq, t0, phiN);
txChanSig = txBbSig .* h0;


%% Add Noise

% Calculate signal power
Ps = Gstd^2;
Eb = Ps / Fs;
N0 = Eb / (10^(Eb_N0 / 10));

% Generate gaussian white noise
sigmaN = sqrt(N0 / 2 * Fs);
chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

% Signal goes through channel and add noise
rxChanSig = txChanSig + chanNoise;


%% Receiver

% Eliminate the effect of fading channel
rxBbSig = real(rxChanSig ./ h0);

% Demodulation and Detection
rxDemTemp = reshape(rxBbSig, Np, Ndata);
rxVecTemp = rxDemTemp ./ abs(rxDemTemp);
rxVec = (rxVecTemp + 1) / 2;

% Recover Sequence
recVecIdx = 2.^(Np - 1 : -1 : 0);
dataRecv = recVecIdx * rxVec;


%% Compute Error

bitErrTemp = rxVec - txVec;
bitErrNum = zeros(Np, 1);
measBER = ones(Np, 1);

for i = 1 : Np

    for j = 1 : Ndata
        if bitErrTemp(i, j) ~= 0
            bitErrNum(i) = bitErrNum(i) + 1;
        end
    end

    measBER(i) = bitErrNum(i) / Ndata;
end

bitErr = rxBbSig - txBbSig;
dataErr = dataRecv - dataSend;


%% Calculate Some Theoretical Values

% Calculate the actual theoretical BER for each bit
trueEbN0 = Eb_N0_U * (Gt / Gstd).^2;
theorBER = 0.5 * (1 - sqrt(trueEbN0 ./ (1 + trueEbN0)));

% Calculate ideal bit error distribution
distMag = -4 * sigmaN : 0.01 : 4 * sigmaN;
idealMagPdf = normpdf(distMag, 0, sigmaN);


%% Calculate Data Error Distribution

% Calculate data error distribution
pn = FreqCal(dataErr, Np);

% Calculate distribution range
errVal = 0;                         % Current error value
pnIdx = errVal + 2^Np;              % The index of the current error value
errProb = pn(pnIdx);                % Probability of current error value
errProp = 0;                        % The ratio of probability of last error value and current one

while (errProb > minErr) && (errProp < maxErrProp)
    errVal = errVal + 1;            % Update current error value with next one
    pnIdx = errVal + 2^Np;          % Index of the error value
    errProbPrev = errProb;          % Update probability of previous error value
    errProb = pn(pnIdx);            % Update probability of current error value
    errProp = errProbPrev / errProb;% The ratio of probability of last error value and current one
end

errLb = -errVal + 1;
errUb = errVal - 1;

%% Print Transmission Information

fprintf('Rayleigh Fading Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Eb/N0 = %.2f dB, i.e. %.2f\n', Eb_N0, Eb_N0_U);
fprintf('Signal power = %.2f w\n', Ps);
fprintf('Complex noise power for bits = %.2f w\n', 2 * sigmaN^2);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of data = %d\n', Ndata);
fprintf('Data range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack size = %d bits\n', Np);

fprintf('\n----------- Power Allocation -----------\n');
pwrWatt = Gt.^2;
pwrLog = 10 * log10(pwrWatt * 1000);
pwrPrt = [idxNp, pwrWatt, pwrLog].';
fprintf('Bit number %d: Transmission power = %.5e W = %.2f dBm\n', pwrPrt);

fprintf('\n----------- True Eb/N0 -----------\n');
ebn0Log = 10 * log10(trueEbN0);
ebn0Prt = [idxNp, trueEbN0, ebn0Log].';
fprintf('Bit number %d: Eb/N0 = %.5e = %.2f dB\n', ebn0Prt);

fprintf('\n----------- Transmission Error -----------\n');
berPrt = [idxNp, theorBER, measBER].';
fprintf('BER Comparison:\n');
fprintf('Bit number %d: Theoretical = %.3e, Measured = %.3e\n', ...
        berPrt);


%% Plot and Fit Laplace Distribution
LaplaceFit(dataErr, Np);




