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
Gstd = 1;                                   % Amplitude of transmission bits (V)
Fs = 1e6;                                   % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Noise
Eb_N0 = -10 : 0.5 : 20;                     % Average bit energy to single-sided noise spectrum density (dB)
SNR = 10 * log10(Fsym / Fs) + Eb_N0;        % Signal-to-noise ratio
SNR_U = 10.^(SNR / 10);

%% Signal source
Nb = 100000;                                % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (0.5 - txSeq) * Gstd;


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

measBER = zeros(1, length(Eb_N0));
theoBER = zeros(1, length(Eb_N0));
apprBER = zeros(1, length(Eb_N0));

for i = 1 : length(Eb_N0)

    % Generate gaussian white noise
    sigmaN = sqrt(Gstd^2 / SNR_U(i) / 2);
    chanNoise = sigmaN * (randn(1, baseLen) + 1i* randn(1, baseLen));

    % Signal goes through channel and add noise
    rxChanSig = txBbSig + chanNoise;

    % Receive signal
    rxBbSig = real(rxChanSig);

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
    measBER(i) = bitErrNum / Nb;
    theoBER(i) = qfunc(sqrt(2 * SNR_U(i)));
    apprBER(i) = exp(-SNR_U(i)) / 4;

end


%% Print Transmission Information

fprintf('---------- Environment Information ----------\n');
fprintf('Changing SNR\n');

fprintf('----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Sampling rate = %d Hz\n', Fs);
fprintf('Number of Bits = %d\n', Nb);


%% Plot the Relationship between SNR and BER

nEbn0 = Eb_N0;
nUnit = 10.^(Eb_N0 / 10);

figBer = figure(1);
figBer.Name = 'BER Test for AWGN Channel wuth BPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(nEbn0, theoBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nEbn0, apprBER, "LineWidth", 2, "Color", "#77AC30", "Marker", ".");
semilogy(nEbn0, measBER, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in dB)", ...
    "FontSize", 16);
xlabel("Eb/N0 / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Approximate BER", "Measured BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
semilogy(nUnit, theoBER, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nUnit, measBER, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in unit)", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

