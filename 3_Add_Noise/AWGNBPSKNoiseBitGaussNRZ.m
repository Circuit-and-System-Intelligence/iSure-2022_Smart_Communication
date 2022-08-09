% Description:  Test Program for AWGN Channel Model
%               Adopt BPSK Modulation
%               For Noise Test
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 6, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Ignore large-scale fading
%   Sending data is in NRZ code

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
stdAmp = 1;                                 % Amplitude of transmission bits (V)
Np = 4;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Noise
Eb_N0 = 0;                                 % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)


%% Signal source

% Generate sending data (Decimal)
Ndata = 10000;                              % Number of sending datas (Decimalism)
dataSend = randi(10, 1, Ndata);             % Sending data (Decimal)

% Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
Nb = Ndata * Np;                            % Number of bits
txSeqTempA = fix(dataSend / 2^(Np - 1));
txSeqResA = dataSend - txSeqTempA * 2^(Np - 1);
txSeqTempB = fix(txSeqResA / 2^(Np - 2));
txSeqTempC = fix((txSeqResA - txSeqTempB * 2^(Np - 2)) / 2^(Np - 3));
txSeqTempD = mod(dataSend, 2);
txSeqTemp = [txSeqTempA; txSeqTempB; txSeqTempC; txSeqTempD];
txSeq = reshape(txSeqTemp, 1, Nb);          % Binary sending sequence (0 and 1 seq)

clear txSeqTempA txSeqTempB txSeqTempC txSeqTempD txSeqResA txSeqTemp

%% Baseband Modulation

% NRZ code
txModSig = txSeq;
baseLen = length(txModSig);
txBbSig = txModSig;


%% Add Noise

% Calculate signal power
Ps = sum(txModSig.^2) / baseLen;

% Generate gaussian white noise
sigmaN = sqrt(Ps / 10^(SNR / 10) / 2);
chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

% Signal goes through channel and add noise
rxBbSig = real(txBbSig + chanNoise);


%% Recover data

dataRecvTemp = reshape(rxBbSig, Np, Ndata);
dataRecv = dataRecvTemp(1, :) * 2^(Np - 1) + dataRecvTemp(2, :) * 2^(Np - 2) + ...
           dataRecvTemp(3, :) * 2^(Np - 3) + dataRecvTemp(4, :) * 1;

clear dataRecvTemp


%% Compute Error

bitErr = rxBbSig - txModSig;
dataErr = dataRecv - dataSend;


%% Print Transmission Information

fprintf('AWGN Channel, NRZ Code\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n\n')

fprintf('---------- Environment Information ----------\n');
fprintf('SNR = %d dB\n', SNR);
fprintf('Signal Power = %d w\n', Ps);
fprintf('Noise Power for Bits = %.3d w\n\n', sigmaN^2);


fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Data = %d\n', Ndata);
fprintf('Data Range = 0~9\n');
fprintf('Pack Size = %d bits\n', Np);


%% Plot

% Plot bit error
transErrPlt = figure(1);
transErrPlt.Name = 'Transmission Error for AWGN with BPSK Modulation';
transErrPlt.WindowState = 'maximized';

subplot(2, 2, 1);
plot(bitErr, "LineWidth", 2, "Color", "#0072BD");
title('Bit Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(2, 2, 2)
hold on
histogram(bitErr, 100, 'Normalization', 'pdf');
distMag = -4 * sigmaN : 0.01 : 4 * sigmaN;
idealMagPdf = normpdf(distMag, 0, sigmaN);
plot(distMag, idealMagPdf, 'Color', '#D95319', 'LineWidth', 1.5);
xlabel('Magnitude');
ylabel('PDF');
title('Bit Error Distribution', 'FontSize', 16);
legend('Simulation', 'Ideal');
hold off

subplot(2, 2, 3);
plot(dataErr, "LineWidth", 2, "Color", "#0072BD");
title('Data Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(2, 2, 4)
histogram(dataErr, 100, 'Normalization', 'pdf');
title('Data Error Distribution', 'FontSize', 16);
xlabel('Magnitude');
ylabel('PDF');






