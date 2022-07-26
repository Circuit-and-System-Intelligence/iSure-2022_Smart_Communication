% Description:  Test Program for AWGN Channel Model with QPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 24, 2022
% Author:       Zhiyu Shen

% Description:
%   Adopt AWGN channel

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Fs = 1e6;                                   % Sampling rate (Hz)
M = 4;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Noise
Eb_N0 = 0 : 0.5 : 40;                       % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)


%% Signal source
Nb = 50000;                                 % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% QPSK baeband modulation
txModSigTemp = (reshape(txSeq, 2, Nb / 2) - 0.5) * (-2 * sigAmp);
txModSigI = txModSigTemp(2, :);
txModSigQ = txModSigTemp(1, :);


%% Baseband Shaping

% Upsampling (Interpolation)
modLen = length(txModSigI);                 % Fetch the length of modulated signal
txSampZero = zeros(sps - 1, modLen);        % Zero vector added to original signal vector
txSamTempI = [txModSigI; txSampZero];       % Upsamling for each element of I signal vector
txSamTempQ = [txModSigQ; txSampZero];       % Upsamling for each element of Q signal vector
txSamSigI = reshape(txSamTempI, 1, modLen * sps);
txSamSigQ = reshape(txSamTempQ, 1, modLen * sps);

% Generate roll-off filter (Raising Cosine Filter)
rolloffFactor = 0.5;            % Roll-off factor
rcosFir = rcosdesign(rolloffFactor, 6, sps, "sqrt");

% Baseband shaping (Eliminate the impact of dalay)
% For in-phase component
txFiltSigTempI = conv(txSamSigI, rcosFir);
txFilterHeadI = (length(rcosFir) - 1) / 2;
txFiltSigI = txFiltSigTempI(1, (txFilterHeadI + 1) : (length(txFiltSigTempI) - txFilterHeadI));
% For quadrature component
txFiltSigTempQ = conv(txSamSigQ, rcosFir);
txFilterHeadQ = (length(rcosFir) - 1) / 2;
txFiltSigQ = txFiltSigTempQ(1, (txFilterHeadQ + 1) : (length(txFiltSigTempQ) - txFilterHeadQ));
% Combine
txBbSig = txFiltSigI + 1i * txFiltSigQ;
baseLen = length(txBbSig);


%% AWGN Channel

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(2 * sigAmp^2 / 10^(SNR(i) / 10) / 2);
    chanNoise = sigmaN * (randn(1, baseLen) + 1i * randn(1, baseLen));

    % Signal goes through channel and add noise
    rxChanSig = txBbSig + chanNoise;

    % Extract IQ components from received signal
    rxBbSigI = real(rxChanSig);
    rxBbSigQ = imag(rxChanSig);

    % Raise-cosine filter
    % For in-phase component
    rxFiltSigTempI = conv(rxBbSigI, rcosFir);
    rxFiltHeadI = (length(rcosFir) - 1) / 2;
    rxFiltSigI = rxFiltSigTempI(1, (rxFiltHeadI + 1) : (length(rxFiltSigTempI) - rxFiltHeadI));
    % For quadrature component
    rxFiltSigTempQ = conv(rxBbSigQ, rcosFir);
    rxFiltHeadQ = (length(rcosFir) - 1) / 2;
    rxFiltSigQ = rxFiltSigTempQ(1, (rxFiltHeadQ + 1) : (length(rxFiltSigTempQ) - rxFiltHeadQ));

    % Sampling
    rxSampSigITemp = reshape(rxFiltSigI, sps, modLen);
    rxSampSigQTemp = reshape(rxFiltSigQ, sps, modLen);
    rxSampSigI = rxSampSigITemp(1, :);
    rxSampSigQ = rxSampSigQTemp(1, :);

    % Demodulate
    rxDemSigITemp = rxSampSigI ./ abs(rxSampSigI);
    rxDemSigQTemp = rxSampSigQ ./ abs(rxSampSigQ);
    rxDemSigI = (1 - rxDemSigQTemp) / 2;
    rxDemSigQ = (1 - rxDemSigITemp) / 2;
    rxDemSigTemp = [rxDemSigI; rxDemSigQ];
    rxSeq = reshape(rxDemSigTemp, 1, Nb);

    % Calculate BER
    bitErrTemp = rxSeq - txSeq;
    bitErrNum = 0;
    for j = 1 : Nb
        if bitErrTemp(j) ~= 0
            bitErrNum = bitErrNum + 1;
        end
    end
    bitErrRate(i) = bitErrNum / Nb;
    theorBER(i) = qfunc(sqrt(10^(SNR(i) / 10)));
end


%% Print Transmission Information

fprintf('---------- Environment Information ----------\n');
fprintf('Changing SNR\n');

fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Bits = %d\n', Nb);


%% Plot the Relationship between SNR and BER

nEbn0 = Eb_N0;
nUnit = 10.^(nEbn0 / 10);

figBer = figure(1);
figBer.Name = 'BER Test for AWGN Channel wuth QPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nEbn0, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "square");
hold on
semilogy(nEbn0, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "o");
title("BER Characteristic of AWGN Channel with QPSK Modulation (Eb/N0 in dB)", ...
    "FontSize", 16);
xlabel("Eb/N0 / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
semilogy(nUnit/2, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "square");
hold on
semilogy(nUnit/2, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "o");
title("BER Characteristic of AWGN Channel with QPSK Modulation (Eb/N0 in unit)", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on
