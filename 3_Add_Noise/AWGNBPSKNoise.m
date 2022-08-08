% Description:  Test Program for AWGN Channel Model
%               Adopt BPSK Modulation
%               For Noise Test
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 4, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Ignore large-scale fading

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Np = 4;                                     % Number of bits in a package
Fs = 1e6;                                   % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Noise
Eb_N0 = 20;                                 % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)
% Transimitter gain
Ps = sigAmp^2;                              % Standard signal power
Gt1 = 2^(Np - 1) * sigAmp;                  % Gain of MSB in a pack
Gt2 = 2^(Np - 2) * sigAmp;                  % Gain of 2nd bit in a pack
Gt3 = 2^(Np - 3) * sigAmp;                  % Gain of 3rd bit in a pack
Gt4 = sigAmp;


%% Signal source

% Generate sending data (Decimal)
Ndata = 10000;                              % Number of sending datas (Decimalism)
dataSend = randi(10, 1, Ndata);             % Sending data (Decimal)

% Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
txSeqTempA = fix(dataSend / 2^(Np - 1));
txSeqResA = dataSend - txSeqTempA * 2^(Np - 1);
txSeqTempB = fix(txSeqResA / 2^(Np - 2));
txSeqTempC = fix((txSeqResA - txSeqTempB * 2^(Np - 2)) / 2^(Np - 3));
txSeqTempD = mod(dataSend, 2);
txSeqTemp = [txSeqTempA; txSeqTempB; txSeqTempC; txSeqTempD];
txSeq = reshape(txSeqTemp, 1, Ndata * Np);   % Binary sending sequence (0 and 1 seq)

clear txSeqTempA txSeqTempB txSeqTempC txSeqTempD txSeqResA txSeqTemp

%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * sigAmp;


%% Baseband Shaping

% Upsampling (Interpolation)
modLen = length(txModSig);                  % Fetch the length of modulated signal
txSampZero = zeros(sps - 1, modLen);        % Zero vector added to original signal vector
txSamTemp = [txModSig; txSampZero];         % Upsamling for each element of I signal vector
txSamSig = reshape(txSamTemp, 1, modLen * sps);

clear txSampZero txSamTemp

% Generate roll-off filter (Raising Cosine Filter)
rolloffFactor = 0.5;                        % Roll-off factor
rcosFir = rcosdesign(rolloffFactor, 6, sps, "sqrt");

% Baseband shaping (Eliminate the impact of dalay)
txFiltSigTemp = conv(txSamSig, rcosFir);
txFilterHead = (length(rcosFir) - 1) / 2;
txFiltSig = txFiltSigTemp(1, (txFilterHead + 1) : (length(txFiltSigTemp) - txFilterHead));
txBbSig = txFiltSig;
baseLen = length(txBbSig);

clear txFiltSigTemp txFilterHead


%% Adjust Transmission Power According to Bit Order



%% Add Noise

% Generate gaussian white noise
sigmaN = sqrt(Ps / 10^(SNR / 10) / 2);
chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

% Signal goes through channel and add noise
rxBbSig = real(txBbSig + chanNoise);


%% Baseband Recovery

% Raise-cosine filter
rxFiltSigTemp = conv(rxBbSig, rcosFir);
rxFiltHead = (length(rcosFir) - 1) / 2;
rxFiltSig = rxFiltSigTemp(1, (rxFiltHead + 1) : (length(rxFiltSigTemp) - rxFiltHead));

clear rxFiltSigTemp rxFilterHead

% Sampling
rxSampSigTemp = reshape(rxFiltSig, sps, modLen);
rxSampSig = rxSampSigTemp(1, :);

clear rxSampSigTemp


%% Recover data
dataRecvTemp = reshape((rxSampSig + 1) / 2, Np, Ndata);
dataRecv = dataRecvTemp(1, :) * 2^(Np - 1) + dataRecvTemp(2, :) * 2^(Np - 2) + ...
           dataRecvTemp(3, :) * 2^(Np - 3) + dataRecvTemp(4, :) * 1;

clear dataRecvTemp


%% Compute Error

bitErr = rxSampSig - txModSig;
dataErr = dataRecv - dataSend;


%% Print Transmission Information

fprintf('---------- Environment Information ----------\n');
fprintf('SNR Changes\n');

fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Data = %d\n', Ndata);
fprintf('Sampling rate = %d\n', Fs);


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

subplot(2, 2, 3)
histogram(bitErr, 100, 'Normalization', 'pdf');
title('Bit Error Distribution', 'FontSize', 16);
xlabel('Magnitude');
ylabel('PDF');

subplot(2, 2, 2);
plot(dataErr, "LineWidth", 2, "Color", "#0072BD");
title('Data Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(2, 2, 4)
histogram(dataErr, 100, 'Normalization', 'pdf');
title('Data Error Distribution', 'FontSize', 16);
xlabel('Magnitude');
ylabel('PDF');







