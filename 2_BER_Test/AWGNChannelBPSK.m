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

% Noise
SNR = -10;                                  % Signal-to-noise ratio


%% Signal source
Nb = 4096;                                  % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq);


%% AWGN Channel

% Signal goes through channel and add noise
rxChanSig = awgn(txModSig, SNR, 'measured');


%% Demodulate

rxSeqTemp = rxChanSig ./ abs(rxChanSig);
rxSeq = (1 - rxSeqTemp) / 2;


%% Calculate BER

bitErrTemp = rxSeq - txSeq;
bitErrNum = 0;
for i = 1 : Nb
    if bitErrTemp(i) ~= 0
        bitErrNum = bitErrNum + 1;
    end
end
bitErrRate = bitErrNum / Nb;
theorBER = qfunc(sqrt(10^(SNR / 20)));


%% Print Transmission Information

fprintf('---------- Environment Information ----------\n');
fprintf('SNR = %.2f dB\n', SNR);

fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Bits = %d\n', Nb);

fprintf('------------ Transmission Result ------------\n');
fprintf('Theoretical BER = %.4f%%\n', theorBER * 100);
fprintf('Actual BER = %.4f%%\n', bitErrRate * 100);


%% Plot for Comparison of Transimitted and Received Non-modulated Signal

% Define display parameters
nSeq = 1 : 64;                                  % Index of symbols to display

figSeqCmp = figure(5);
figSeqCmp.Name = 'Sending and Receiving Sequence';
figSeqCmp.WindowState = 'maximized';

% Transmitted encoded signal -> Received undecoded signal
subplot(2, 1, 1);
plot(nSeq, txSeq(nSeq), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

subplot(2, 1, 2);
plot(nSeq, rxSeq(nSeq), 'LineWidth', 2, "Color", '#D95319');
title('Received Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

