% Description:  Test Program for Rayleigh Fading Channel Model
%               Adopt BPSK Modulation
%               For Noise Test
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 9, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Ignore large-scale fading and adopt Rayleigh fading channel
%   Using Jakes Model to generate Rayleigh fading channel coefficients

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Np = 4;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters
% Small-Scale fading
Nw = 98;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)
% Noise
Eb_N0 = 20;                                 % Average bit energy to single-sided noise spectrum power (dB)
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

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * sigAmp;
txBbSig = txModSig;
baseLen = length(txBbSig);


%% Go through Rayleigh Fading Channel

h0 = RayleighFadingChannel(Nw, fm, baseLen, Feq, t0, phiN);
txChanSig = txBbSig .* h0;

%% Add Noise

% Generate gaussian white noise
Ps = sigAmp^2;
sigmaN = sqrt(sigAmp^2 / 10^(SNR / 10) / 2);
chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

% Signal goes through channel and add noise
rxChanSig = txChanSig + chanNoise;

% Eliminate the effect of fading channel
rxBbSig = real(rxChanSig ./ h0);


%% Compute Error

modSigErr = rxBbSig - txBbSig;


%% Print Transmission Information

fprintf('Rayleigh Fading Channel, BPSK Modulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n\n')

fprintf('---------- Environment Information ----------\n');
fprintf('Number of Scaterred Rays = %d\n', Nw);
fprintf('Doppler Shift = %.2f Hz\n', fm);
fprintf('SNR = %d dB\n', SNR);
fprintf('Signal Power = %d w\n', Ps);
fprintf('Noise Power for Bits = %.3d w\n\n', sigmaN^2);


fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Data = %d\n', Ndata);
fprintf('Data Range = 0~9\n');
fprintf('Pack Size = %d bits\n', Np);

%% Plot

figErr = figure(1);
figErr.Name = 'Receive Error for Rayleigh Fading Channel wuth BPSK Modulation';
figErr.WindowState = 'maximized';

subplot(2, 1, 1);
plot(modSigErr, "LineWidth", 2, "Color", "#0072BD");
title('Receive Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(2, 1, 2)
histogram(modSigErr, 100, 'Normalization', 'pdf');
title('Receive Error Distribution', 'FontSize', 16);
xlabel('Magnitude');
ylabel('PDF');







