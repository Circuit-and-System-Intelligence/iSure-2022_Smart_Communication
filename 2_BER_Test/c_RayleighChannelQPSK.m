% Description:  Test Program for Rayleigh Fading Channel Model
%               Adopt QPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 25, 2022
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
M = 4;                                      % Modulation order
Fsym = Fs / log2(M);                        % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters
% Small-Scale fading
Nw = 98;                                   % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)

% Noise
Eb_N0 = 0 : 0.5 : 30;                       % Average bit energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(2 / Fs * bitrate) + Eb_N0; % Signal-to-noise ratio (dB)


%% Signal source
Nb = 100000;                                % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% QPSK baeband modulation
txModSigTemp = (reshape(txSeq, 2, Nb / 2) - 0.5) * (-2 * sigAmp);
txModSigI = txModSigTemp(2, :);
txModSigQ = txModSigTemp(1, :);
txModSig = txModSigI + 1i * txModSigQ;


%% Go through Rayleigh Fading Channel

h0 = RayleighFadingChannel(Nw, fm, Nb / 2, Fsym, t0, phiN);
% h0 = (randn(1, Nb / 2) + 1i * randn(1, Nb / 2)) / sqrt(2);
txChanSig = txModSig .* h0;


%% Add Noise

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(sigAmp^2 / 10^(SNR(i) / 10));
    chanNoise = sigmaN * (randn(1, Nb / 2) + 1i * randn(1, Nb / 2));

    % Signal goes through channel and add noise
    rxChanSig = txChanSig + chanNoise;

    % Eliminate the effect of fading channel
    rxBbSig = rxChanSig ./ h0;

    % Demodulate
    rxSampSigI = real(rxBbSig);
    rxSampSigQ = imag(rxBbSig);
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

nEbn0 = Eb_N0;
nUnit = 10.^(Eb_N0 / 10);

figBer = figure(1);
figBer.Name = 'BER Test for Rayleigh Fading Channel wuth QPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nEbn0, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "square");
hold on
semilogy(nEbn0, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "o");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in dB)", ...
    "FontSize", 16);
xlabel("Eb/N0 / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
semilogy(nUnit, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "square");
hold on
semilogy(nUnit, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "o");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in unit)", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on
