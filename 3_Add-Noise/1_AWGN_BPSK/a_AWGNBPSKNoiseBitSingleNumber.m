% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 8, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit single number
%   Transmission power remains unchanged

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
stdAmp = 1;                                 % Amplitude of transmission bits (V)
Np = 8;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Noise
Eb_N0 = 0;                                  % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)


%% Signal source

% Generate sending data (Decimal)
Ndata = 100000;                             % Number of sending datas (Decimalism)
numTrans = 50;                              % Number to be transmitted
dataSend = numTrans * ones(1, Ndata);       % Sending data (Decimal)

% Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
Nb = Ndata * Np;                            % Number of bits
txSeqTemp = zeros(Np, Ndata);
txSeqRes = dataSend;
for i = 1 : Np
    txSeqTemp(i, :) = fix(txSeqRes / 2^(Np - i));
    txSeqRes = txSeqRes - txSeqTemp(i, :) * 2^(Np - i);
end
txSeq = reshape(txSeqTemp, 1, Nb);          % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (txSeq - 0.5) * stdAmp;
baseLen = length(txModSig);

txBbSig = txModSig;


%% Add Noise

% Calculate signal power
Ps = sum(txBbSig.^2) / baseLen;
Eb = Ps / Fs;
N0 = Eb / (10^(Eb_N0 / 10));

% Generate gaussian white noise
sigmaN = sqrt(N0 / 2 * Fs);
chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

% Signal goes through channel and add noise
rxBbSig = real(txBbSig + chanNoise);


%% Receiver

% Demodulation and Detection
rxSeqTemp = rxBbSig ./ abs(rxBbSig);
rxSeq = (rxSeqTemp + 1) / 2;

% Recover Sequence
dataRecvTemp = reshape(rxSeq, Np, Ndata);
recVec = 2.^(Np - 1 : -1 : 0);
dataRecv = recVec * dataRecvTemp;


%% Compute Error

bitErr = (rxBbSig + 1) / 2 - txSeq;
bitErrTemp = rxSeq - txSeq;
bitErrNum = 0;
for j = 1 : Nb
    if bitErrTemp(j) ~= 0
        bitErrNum = bitErrNum + 1;
    end
end
bitErrRate = bitErrNum / Nb;
theorBER = qfunc(sqrt(2 * 10^(Eb_N0 / 10)));

dataErr = dataRecv - dataSend;


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('SNR = %d dB\n', SNR);
fprintf('Signal Power = %d w\n', Ps);
fprintf('Noise Power for Bits = %.3d w\n', sigmaN^2);


fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Data = %d\n', Ndata);
fprintf('Data Range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack Size = %d bits\n', Np);

fprintf('\n----------- Transmission Error -----------\n');
fprintf('Actual BER = %.5d\n', bitErrRate);
fprintf('Theoretical BER = %.5d\n', theorBER);


%% Plot

% Plot bit error
transErrPlt = figure(1);
transErrPlt.Name = 'Transmission Error for AWGN with BPSK Modulation';
transErrPlt.WindowState = 'maximized';

subplot(2, 2, 1);
plot(bitErr(1 : 100 * Np), "LineWidth", 2, "Color", "#0072BD");
title('Bit Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(2, 2, 2)
hold on
histogram(bitErr, 2^Np, 'Normalization', 'pdf');
distMag = -4 * sigmaN : 0.01 : 4 * sigmaN;
idealMagPdf = normpdf(distMag, 0, sigmaN / 2);
plot(distMag, idealMagPdf, 'Color', '#D95319', 'LineWidth', 1.5);
xlabel('Magnitude');
ylabel('PDF');
title('Bit Error Distribution', 'FontSize', 16);
legend('Simulation', 'Ideal');
hold off

subplot(2, 2, 3);
plot(dataErr(1 : 100), "LineWidth", 2, "Color", "#0072BD");
title('Data Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error');

subplot(2, 2, 4)
histogram(dataErr, 2^Np, 'Normalization', 'pdf');
xlabel('Magnitude');
ylabel('PDF');
title('Data Error Distribution', 'FontSize', 16);







