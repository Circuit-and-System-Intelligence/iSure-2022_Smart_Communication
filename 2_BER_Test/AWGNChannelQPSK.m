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
Fs = bitrate;                               % Sampling rate (Hz)
M = 4;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Noise
Eb_N0 = 0 : 0.1 : 10;                       % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(2 * Fsym / Fs) + Es_N0;    % Signal-to-noise ratio (dB)


%% Signal source
Nb = 100000;                                % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% QPSK baeband modulation
txModSigTemp = (reshape(txSeq, 2, Nb / 2) - 0.5) * (-2 * sigAmp);
txModSigI = txModSigTemp(2, :);
txModSigQ = txModSigTemp(1, :);
txModSig = txModSigI + 1i * txModSigQ;


%% AWGN Channel

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(sigAmp^2 / 10^(SNR(i) / 10));
    chanNoise = sigmaN * (randn(1, Nb/2) + 1i * randn(1, Nb/2));

    % Signal goes through channel and add noise
    rxChanSig = txModSig + chanNoise;

    % Demodulate
    rxSampSigI = real(rxChanSig);
    rxSampSigQ = imag(rxChanSig);
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
nUnit = 10.^(Eb_N0 / 10);

figBer = figure(1);
figBer.Name = 'BER Test for AWGN Channel wuth QPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nEbn0, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nEbn0, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with QPSK Modulation (Eb/N0 in dB)", ...
    "FontSize", 16);
xlabel("Eb/N0 / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
semilogy(nUnit/2, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nUnit/2, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with QPSK Modulation (Eb/N0 in unit)", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on
