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
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters
% Small-Scale fading
Nw = 34;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)
% Signal power
ebno = -30 : 0.5 : 30;                      % Average bit energy to single-sided noise spectrum power (dB)
ebnoUnit = 10.^(ebno/20);
numEbno = length(ebno);
ampSig = 1;                                 % Amplitude of transmission bits (V)
pwrSig = ampSig.^2;                         % Signal power
pwrNoise = (pwrSig./ebnoUnit)*(Fs/bitrate); % Noise power

%% Signal source
Nb = 500000;                                % Number of sending bits
txSeq = randi([0, 1], 1, Nb);               % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (txSeq-0.5) * ampSig;


%% Go through Rayleigh Fading Channel

h0 = RayleighFadingChannel(Nw, fm, Nb, Feq, t0, phiN);
txChanSig = txModSig .* h0;


%% Add Noise

berMeas = zeros(1, length(ebno));
berTheo = zeros(1, length(ebno));

for i = 1 : length(ebno)

    % Generate gaussian white noise
    sigmaN = sqrt(pwrNoise(i)/2);
    chanNoise = sigmaN * randn(1, Nb) + 1i * sigmaN * randn(1, Nb);

    % Signal goes through channel and add noise
    rxChanSig = txChanSig + chanNoise;

    % Eliminate the effect of fading channel
    rxBbSig = real(rxChanSig ./ h0);

    % Demodulate
    rxSeqTemp = rxBbSig ./ abs(rxBbSig);
    rxSeq = (1+rxSeqTemp) / 2;

    % Calculate BER
    bitErrTemp = rxSeq - txSeq;
    bitErrNum = 0;
    for j = 1 : Nb
        if bitErrTemp(j) ~= 0
            bitErrNum = bitErrNum + 1;
        end
    end
    berMeas(i) = bitErrNum / Nb;
    berTheo(i) = 0.5 * (1 - sqrt(ebnoUnit(i)/(1+ebnoUnit(i))));

end

% Calculate error of BER estimation
berError = (-(berMeas - berTheo)./berMeas) * 100;

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

figBer = figure(1);
figBer.Name = 'BER Test for Rayleigh Fading Channel wuth BPSK Modulation';
figBer.WindowState = 'maximized';

subplot(2, 1, 1);
semilogy(ebno, berTheo, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(ebno, berMeas, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
title("BER Characteristic of AWGN Channel with BPSK Modulation", ...
    "FontSize", 16);
xlabel("Eb/N0 (dB)", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER", "Actual BER", "Fontsize", 16);
hold off
grid on
box on

subplot(2, 1, 2);
plot(ebno, berError, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
title("BER Error of AWGN Channel with BPSK Modulation", ...
    "FontSize", 16);
xlabel("Eb/N0", "FontSize", 16);
ylabel("BER Error (%)", "FontSize", 16);
hold off
grid on
box on

% subplot(2, 1, 2);
% semilogy(ebnoUnit, berTheo, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
% hold on
% semilogy(ebnoUnit, berMeas, "LineWidth", 2, "Color", "#D95319", "Marker", "*");
% title("BER Characteristic of AWGN Channel with BPSK Modulation (SNR in unit)", ...
%     "FontSize", 16);
% xlabel("Eb/N0", "FontSize", 16);
% ylabel("BER", "FontSize", 16);
% legend("Theoretical BER", "Actual BER", "Fontsize", 16);
% hold off
% grid on
% box on
