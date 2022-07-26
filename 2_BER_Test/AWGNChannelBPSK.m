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
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Noise
Eb_N0 = 0 : 0.1 : 10;                       % Average bit energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(2 / Fs * Fsym) + Eb_N0;    % Signal-to-noise ratio (dB)


%% Signal source
Nb = 1000000;                               % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * sigAmp;


%% AWGN Channel

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(sigAmp^2 / 10^(SNR(i) / 10));
    chanNoise = sigmaN * randn(1, Nb);

    % Signal goes through channel and add noise
    rxChanSig = txModSig + chanNoise;

%     % Noise test
%     noisePwr = sum(chanNoise.^2) / Nb;
%     sigPwr = sum(txModSig.^2) / Nb;

    % Demodulate
    rxSeqTemp = rxChanSig ./ abs(rxChanSig);
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
% fprintf('SNR = %.2f dB\n', SNR);
fprintf('Changing SNR\n');

fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Bits = %d\n', Nb);

% fprintf('------------ Transmission Result ------------\n');
% fprintf('Theoretical BER = %f%%\n', theorBER * 100);
% fprintf('Actual BER = %f%%\n', bitErrRate * 100);


%% Plot the Relationship between SNR and BER

nEbn0 = Eb_N0;
nUnit = 10.^(Eb_N0 / 10);

figBer = figure(1);
figBer.Name = 'BER Test for AWGN Channel wuth BPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nEbn0, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nEbn0, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in dB)", ...
    "FontSize", 16);
xlabel("Eb/N0 / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
semilogy(nUnit, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nUnit, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in unit)", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on


%% Plot for Comparison of Transimitted and Received Non-modulated Signal
% 
% % Define display parameters
% nSeq = 1 : 64;                                  % Index of symbols to display
% 
% figSeqCmp = figure(5);
% figSeqCmp.Name = 'Sending and Receiving Sequence';
% figSeqCmp.WindowState = 'maximized';
% 
% % Transmitted encoded signal -> Received undecoded signal
% subplot(2, 1, 1);
% plot(nSeq, txSeq(nSeq), 'LineWidth', 2, "Color", '#0072BD');
% title('Transmitted Sequence', 'FontSize', 16);
% xlabel('Sequence Index');
% ylabel('Amplitude / V');
% 
% subplot(2, 1, 2);
% plot(nSeq, rxSeq(nSeq), 'LineWidth', 2, "Color", '#D95319');
% title('Received Sequence', 'FontSize', 16);
% xlabel('Sequence Index');
% ylabel('Amplitude / V');

