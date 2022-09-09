% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 22, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a logrithmatic way

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

% Signal-to-noise ratio
EbNo = 0;                                   % Average bit energy to single-sided noise spectrum power (dB)
EbNoUnit = 10^(EbNo / 10);
% Transimitter gain (Take MSB for reference bit)
idxNp = (Np : -1 : 1).';
% gRatio = 2.^(idxNp - Np);
gRatio = exp(idxNp - Np);
% gRatio = [1; 1 / 2; 1 / 4; 1 / 8];
% gRatio = [1; 1 / 2];
Gt = gRatio * Gstd;                         % Gain of ith bit in a pack

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
txSeq = reshape(txVec, 1, Nb);              % Binary sending sequence (0 and 1 seq)


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


%% Add Noise

% Calculate signal power
Ps = Gstd^2;
Eb = Ps / Fs;
N0 = Eb / (10^(EbNo/10));

% Generate gaussian white noise
sigmaN = sqrt(N0*Fs/2);
chanNoise = sigmaN*randn(1, baseLen) + 1i*sigmaN*randn(1, baseLen);

% Signal goes through channel and add noise
rxBbSig = real(txBbSig + chanNoise);


%% Receiver

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
trueEbN0 = EbNoUnit * (Gt / Gstd).^2;
theorBER = qfunc(sqrt(2 * trueEbN0));


%% Calculate Measured and Theoretical Distribution and Their Laplace Fit

% Range of data error
Xn = -2^Np + 1 : 1 : 2^Np - 1;

% Calculate measured data error distribution
Mn = FreqCal(dataErr, Np);                                        % Calculate the frequence of each error (Normalized)

% Calculate theoretical data error distribution
Tn = TheorDataErrorDistri(Np, EbNo);

% Laplace fit of measured data error distribution
[Lnm, IdxLnm, muLap, bLap] = LaplaceFit(dataErr, Np);


%% Plot

distriPlt = figure(1);
distriPlt.WindowState = 'maximized';

% Plot theoretical data erro distribution
subplot(1, 2, 1);
hold on
% Plot theoretical distribution
stem(Xn, Tn, "LineWidth", 2, "Color", "#0072BD");
hold off
% Set the plotting properties
xlabel('Data error value');
ylabel('Occurrence probability');
title('Theoretical Data Error Distribution and Its Laplace Fit');
xlim([-2^Np 2^Np]);
ylim([0 max(Tn) * 2]);
set(gca, 'Fontsize', 20, 'Linewidth', 2);

% Plot measured data erro distribution and its Laplace fit
subplot(1, 2, 2);
hold on
% Plot measured distribution
stem(Xn, Mn, "LineWidth", 2, "Color", "#0072BD")
% Plot the Laplace PDF 
plot(IdxLnm, Lnm, "LineWidth", 2, "Color", "#D95319")
hold off
% Set the plotting properties
xlabel('Data error value');
ylabel('Occurrence probability');
title('Measured Data Error Distribution and Its Laplace Fit');
legend('Measured distribution', 'Laplace fit');
xlim([-2^Np 2^Np]);
ylim([0 max(Tn) * 2]);
set(gca, 'Fontsize', 20, 'Linewidth', 2);


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Eb/N0 = %.2f dB, i.e. %.2f\n', EbNo, EbNoUnit);
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

fprintf('\n----------- Laplace Fit Info -----------\n')
fprintf('mu = %.3f\n', muLap);
fprintf('b = %.3f\n', bLap);


%% Write Data into File
% 
% dataWrite = [Np, EbNo, bLap];
% writematrix

