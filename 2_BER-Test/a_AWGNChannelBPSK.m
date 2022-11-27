% Description:  Test Program for AWGN Channel Model with BPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 22, 2022
% Author:       Zhiyu Shen

% Description:
%   Adopt AWGN channel

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Gstd = 1;                                   % Amplitude of transmission bits (V)
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Noise
Eb_N0 = -20 : 0.1 : 5;                      % Average bit energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(2 / Fs * Fsym) + Eb_N0;    % Signal-to-noise ratio (dB)
SNR_U = 10.^(SNR / 10);


%% Signal source
Nb = 1000000;                               % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * Gstd;

% Form baseband signal
txBbSig = txModSig;
baseLen = length(txBbSig);


%% AWGN Channel

measBER = zeros(1, length(Eb_N0));      % Measured BER
theoBER = zeros(1, length(Eb_N0));      % Theoretical BER
apprBER = zeros(1, length(Eb_N0));      % APproximate theoretical BER

for i = 1 : length(Eb_N0)

    % Generate gaussian white noise
    sigmaN = sqrt(Gstd^2 / SNR_U(i) / 2);
    chanNoise = sigmaN * (randn(1, baseLen) + 1i* randn(1, baseLen));

     % Signal goes through channel and add noise
    rxChanSig = txBbSig + chanNoise;

    % Receive signal
    rxBbSig = real(rxChanSig);

    % Demodulate
    rxSeqTemp = rxBbSig ./ abs(rxBbSig);
    rxSeq = (1 - rxSeqTemp) / 2;

    % Calculate BER
    bitErrTemp = rxSeq - txSeq;
    bitErrNum = 0;
    for j = 1 : Nb
        if bitErrTemp(j) ~= 0
            bitErrNum = bitErrNum + 1;
        end
    end
    measBER(i) = bitErrNum / Nb;
    theoBER(i) = qfunc(sqrt(2 * SNR_U(i)));
    apprBER(i) = exp(-SNR_U(i)) / 2;
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

% Plot BER variation in logarithmatic form
figBer = figure(1);
figBer.Name = 'BER Test for AWGN Channel wuth BPSK Modulation (Logarithmatic)';
figBer.WindowState = 'maximized';

semilogy(nEbn0, theoBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nEbn0, apprBER, "LineWidth", 2, "Color", "#77AC30", "Marker", ".");
semilogy(nEbn0, measBER, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Variation Curve with Eb/N0 (AWGN Channel, BPSK Modulation)");
xlabel("Eb/N0 / dB");
ylabel("BER");
legend("Theoretical BER", "Approximate BER", "Measured BER", "Fontsize", 16);
set(gca, "Fontsize", 20, "FontName", "Times New Roman");
hold off
grid on
box on

% % Plot BER variation
% figBer = figure(2);
% figBer.Name = 'BER Test for AWGN Channel wuth BPSK Modulation';
% figBer.WindowState = 'maximized';
% 
% semilogy(nUnit, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
% hold on
% semilogy(nUnit, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
% title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in unit)", ...
%     "FontSize", 16);
% xlabel("Eb/N0", "FontSize", 16);
% ylabel("BER", "FontSize", 16);
% legend("Theoretical BER", "Actual BER", "Fontsize", 16);
% hold off
% grid on
% box on


