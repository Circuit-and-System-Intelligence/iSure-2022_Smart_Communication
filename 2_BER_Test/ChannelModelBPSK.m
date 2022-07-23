% Description:  Test Program for Fading Channel Model with BPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 22, 2022
% Author:       Zhiyu Shen

% Description:
%   Ignore large-scale fading and adopt Rayleigh fading channel
%   Using Jakes Model to generate Rayleigh fading channel coefficients

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)

% Define wireless communication environment parameters
% Small-Scale fading
Nw = 34;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)
% Noise
SNR = 0;                                  % Signal-to-noise ratio


%% Signal source
Nb = 1024;                                  % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

txModSig = 2 * (0.5 - txSeq);


%% Add Signal to Channel

% Go through fading channel

h0 = RayleighFadingChannel(Nw, fm, Nb, bitrate, t0, phiN);
txChanSig = txModSig .* h0;

% Add noise
rxChanSig = awgn(txChanSig, SNR, 'measured');
noise = rxChanSig - txChanSig;
sigPwr = sum(abs(txChanSig).^2) / Nb;
noiPwr = sum(abs(noise).^2) / Nb;



%% Demodulate

rxModSig = ;
rxSeqTemp = rxModSig ./ abs(rxModSig);
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
fprintf('Number of Scaterred Rays = %d\n', Nw);
fprintf('Doppler Shift = %.2f Hz\n', fm);
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

