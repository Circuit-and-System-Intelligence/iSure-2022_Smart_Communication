% Description:  Test Program for Rayleigh Fading Channel Model
%               Adopt BPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 22, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Ignore large-scale fading and adopt Rayleigh fading channel
%   Using Jakes Model to generate Rayleigh fading channel coefficients

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
sigAmp = 1;                                 % Amplitude of transmission bits (V)
Fs = 1e6;                                   % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters
% Small-Scale fading
Nw = 98;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)
% Noise
Eb_N0 = -10 : 0.5 : 30;                       % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)


%% Signal source
Nb = 50000;                                 % Number of sending bits
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


%% Go through Rayleigh Fading Channel

h0 = RayleighFadingChannel(Nw, fm, baseLen, Feq, t0, phiN);
txChanSig = txBbSig .* h0;

%% Add Noise

bitErrRate = zeros(1, length(SNR));
theorBER = zeros(1, length(SNR));

for i = 1 : length(SNR)

    % Generate gaussian white noise
    sigmaN = sqrt(sigAmp^2 / 10^(SNR(i) / 10) / 2);
    chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

    % Signal goes through channel and add noise
    rxChanSig = txChanSig + chanNoise;

    % Eliminate the effect of fading channel
    rxBbSig = real(rxChanSig ./ h0);

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
    unitSNR = 10^(SNR(i) / 10);
    theorBER(i) = 0.5 * (1 - sqrt(unitSNR / (1 + unitSNR)));

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
figBer.Name = 'BER Test for Rayleigh Fading Channel wuth BPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nEbn0, theorBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nEbn0, bitErrRate, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of Rayleigh Channel with BPSK Modulation (SNR in dB)", ...
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
title("BER Characteristic of Rayleigh Channel with BPSK Modulation (SNR in unit)", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on
