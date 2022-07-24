% Description:  Test Program for AWGN Channel Model with BPSK Modulation
%               Add Baseband Shaping Process
% Projet:       Channel Modeling - iSure 2022
% Date:         July 22, 2022
% Author:       Zhiyu Shen

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Fs = 1e6;                                   % Sampling rate (Hz)
M = 2;                                      % Modulation order
sps = Fs / (bitrate / log2(M));             % Samples per symbol

% Noise
SNR = -10 : 0.1 : 10;                       % Signal-to-noise ratio


%% Signal source
Nb = 16384;                                 % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * sigAmp;


%% Baseband Shaping

% Upsampling (Interpolation)
modLen = length(txModSig);                  % Fetch the length of modulated signal
txSampZero = zeros(sps - 1, modLen);        % Zero vector added to original signal vector
txSamTemp = [txModSig; txSampZero];         % Upsamling for each element of I signal vector
txSamSig = reshape(txSamTemp, 1, modLen * sps);

% Generate roll-off filter (Raising Cosine Filter)
rolloffFactor = 0.5;                        % Roll-off factor
rcosFir = rcosdesign(rolloffFactor, 6, sps, "sqrt");

% Baseband shaping (Eliminate the impact of dalay)
txFiltSigTemp = conv(txSamSig, rcosFir);
txFilterHead = (length(rcosFir) - 1) / 2;
txFiltSig = txFiltSigTemp(1, (txFilterHead + 1) : (length(txFiltSigTemp) - txFilterHead));
txBbSig = txFiltSig;
baseLen = length(txBbSig);


%% AWGN Channel

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(sigAmp^2 / 10^(SNR(i) / 10));
    chanNoise = sigmaN * randn(1, baseLen);

    % Signal goes through channel and add noise
    rxBbSig = txBbSig + chanNoise;

    % Raise-cosine filter
    rxFiltSigTemp = conv(rxBbSig, rcosFir);
    rxFiltHead = (length(rcosFir) - 1) / 2;
    rxFiltSig = rxFiltSigTemp(1, (rxFiltHead + 1) : (length(rxFiltSigTemp) - rxFiltHead));

    % Sampling
    rxSampSigTemp = reshape(rxFiltSig, sps, modLen);
    rxSampSig = rxSampSigTemp(1, :);

    % Demodulate
    rxSeqTemp = rxSampSig ./ abs(rxSampSig);
    rxSeq = (1 - rxSeqTemp) / 2;

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
fprintf('Sampling rate = %d Hz\n', Fs);
fprintf('Number of Bits = %d\n', Nb);


%% Plot the Relationship between SNR and BER

nSnr = SNR;
nSnrUnit = 10.^(SNR / 10);

figBer = figure(1);
figBer.Name = 'BER Test for AWGN Channel wuth BPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nSnr, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nSnr, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in dB)", ...
    "FontSize", 16);
xlabel("SNR / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
semilogy(nSnrUnit, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nSnrUnit, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in unit)", ...
    "FontSize", 16);
xlabel("SNR", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

