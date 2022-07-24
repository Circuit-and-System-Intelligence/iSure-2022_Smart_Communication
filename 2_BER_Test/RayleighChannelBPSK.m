% Description:  Test Program for Rayleigh Fading Channel Model
%               Adopt BPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 22, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   No baseband shaping process

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = Fs / log2(M);                        % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters
% Small-Scale fading
Nw = 34;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)
% Noise
SNR = 0 : 0.5 : 35;                         % Signal-to-noise ratio


%% Signal source
Nb = 1000000;                               % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * sigAmp;


%% Go through Rayleigh Fading Channel

h0 = RayleighFadingChannel(Nw, fm, Nb, Fsym, t0, phiN);
txChanSig = txModSig .* h0;


%% Add Noise

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(sigAmp^2 / 10^(SNR(i) / 10));
    chanNoise = sigmaN * randn(1, Nb) + 1i * sigmaN * randn(1, Nb);

    % Signal goes through channel and add noise
    rxChanSig = txChanSig + chanNoise;

    % Eliminate the effect of fading channel
    rxBbSig = real(rxChanSig ./ h0);

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
    bitErrRate(i) = bitErrNum / Nb;
    unitSNR = 10^(SNR(i) / 10);
    theorBER(i) = 0.5 * (1 - sqrt(unitSNR / (2 + unitSNR)));

end


%% Print Transmission Information

fprintf('---------- Environment Information ----------\n');
fprintf('Number of Scaterred Rays = %d\n', Nw);
fprintf('Doppler Shift = %.2f Hz\n', fm);
fprintf('SNR Changes\n');

fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Bits = %d\n', Nb);
fprintf('Sampling rate = %d\n', Fs);


%% Plot the Relationship between SNR and BER

nSnr = SNR;
nSnrUnit = 10.^(SNR / 10);

figBer = figure(1);
figBer.Name = 'BER Test for Rayleigh Fading Channel wuth BPSK Modulation';
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
