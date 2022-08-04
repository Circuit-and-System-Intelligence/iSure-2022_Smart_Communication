% Description:  Test Program for Fading Channel Model with QPSK Modulation
%               For noise test
% Projet:       Channel Modeling - iSure 2022
% Date:         July 30, 2022
% Author:       Zhiyu Shen

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 10000;                            % Bitrate (Hz)
Fs = 1e6;                                   % Sampling rate (Hz)
M = 4;                                      % Modulation order
sps = Fs / (bitrate / log2(M));             % Samples per symbol

% Define wireless communication environment parameters
% Antenna gain
Gtx = 40;                                   % Transmitter antenna gain (dB)
Grx = 0;                                    % Receiver antenna gain (dB)
% Large-Scale fading
hb = 20;                                    % Height of base station (m)
hm = 2;                                     % Height of mobile (m)
d = 1;                                      % Distance between base station and mobile (m)
env = 0;                                    % Application environment
fc = 1050;                                  % Carrier frequency (MHz)
% Small-Scale fading
Nw = 34;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)
% Noise
SNR = 0;                                    % Signal-to-noise ratio


%% Signal source
Nb = 64;                                    % Number of sending bits
X = randi([0, 1], 1, Nb);                   % Binary sending sequence (0 and 1 seq)
seqLen = length(X);                         % Calculate length of encoded sequence


%% Baseband Modulation

% QPSK baeband modulation
txModSigTemp = (reshape(X, 2, seqLen / 2) - 0.5) * (-sqrt(2));
txModSigI = txModSigTemp(2, :);
txModSigQ = txModSigTemp(1, :);


%% Baseband Shaping

% Upsampling (Interpolation)
modLen = length(txModSigI);                 % Fetch the length of modulated signal
txSampZero = zeros(sps - 1, modLen);        % Zero vector added to original signal vector
txSamTempI = [txModSigI; txSampZero];       % Upsamling for each element of I signal vector
txSamTempQ = [txModSigQ; txSampZero];       % Upsamling for each element of Q signal vector
txSamSigI = reshape(txSamTempI, 1, modLen * sps);
txSamSigQ = reshape(txSamTempQ, 1, modLen * sps);

% Generate roll-off filter (Raising Cosine Filter)
rolloffFactor = 0.5;            % Roll-off factor
rcosFir = rcosdesign(rolloffFactor, 6, sps, "sqrt");

% Baseband shaping (Eliminate the impact of dalay)
% For in-phase component
txFiltSigTempI = conv(txSamSigI, rcosFir);
txFilterHeadI = (length(rcosFir) - 1) / 2;
txFiltSigI = txFiltSigTempI(1, (txFilterHeadI + 1) : (length(txFiltSigTempI) - txFilterHeadI));
% For quadrature component
txFiltSigTempQ = conv(txSamSigQ, rcosFir);
txFilterHeadQ = (length(rcosFir) - 1) / 2;
txFiltSigQ = txFiltSigTempQ(1, (txFilterHeadQ + 1) : (length(txFiltSigTempQ) - txFilterHeadQ));
% Combine
txBbSig = txFiltSigI + 1i * txFiltSigQ;
baseLen = length(txBbSig);
% Extract IQ components from complex signals
txBbSigI = real(txBbSig);
txBbSigQ = imag(txBbSig);


%% Fading Channel

% Calculate small-scale fading
Feq = Fs / log2(M);                         % Equivalent sampling frequency
h0 = RayleighFadingChannel(Nw, fm, baseLen, Feq, t0, phiN);

% Combined fading channel response
h = 1 * h0;

% Signal goes through channel
rxChanSig = awgn(txBbSig .* h, SNR, 'measured');


%% Receive Signal

% Consider the impact of receive antenna
rxSig = rxChanSig;

% Eliminate the effect of Rayleigh fading channel
% rxBbSig = rxSig;
rxBbSig = rxSig ./ h;

% Extract IQ components from received signal
rxBbSigI = real(rxBbSig);
rxBbSigQ = imag(rxBbSig);

%% Baseband Recovery

% Raise-cosine filter
% For in-phase component
rxFiltSigTempI = conv(rxBbSigI, rcosFir);
rxFiltHeadI = (length(rcosFir) - 1) / 2;
rxFiltSigI = rxFiltSigTempI(1, (rxFiltHeadI + 1) : (length(rxFiltSigTempI) - rxFiltHeadI));
% For quadrature component
rxFiltSigTempQ = conv(rxBbSigQ, rcosFir);
rxFiltHeadQ = (length(rcosFir) - 1) / 2;
rxFiltSigQ = rxFiltSigTempQ(1, (rxFiltHeadQ + 1) : (length(rxFiltSigTempQ) - rxFiltHeadQ));

% Sampling
rxSampSigITemp = reshape(rxFiltSigI, sps, modLen);
rxSampSigQTemp = reshape(rxFiltSigQ, sps, modLen);
rxSampSigI = rxSampSigITemp(1, :);
rxSampSigQ = rxSampSigQTemp(1, :);


%% Demodulate
rxDemSigITemp = rxSampSigI ./ abs(rxSampSigI);
rxDemSigQTemp = rxSampSigQ ./ abs(rxSampSigQ);
rxDemSigI = (1 - rxDemSigQTemp) / 2;
rxDemSigQ = (1 - rxDemSigITemp) / 2;
rxDemSigTemp = [rxDemSigI; rxDemSigQ];
rxDemSig = reshape(rxDemSigTemp, 1, seqLen);
Y = rxDemSig;


%% Print Transmission Information

fprintf('---------- Environment Information ----------\n');
fprintf('Carrier Frequency = %.3f GHz\n', fc / 1000);
fprintf('Distance = %.2f km\n', d);
fprintf('Base Station Antenna Height = %.2f m\n', hb);
fprintf('Mobile Antenna Height = %.2f m\n', hm);
fprintf('Tx Antenna Gain = %.2f dB\n', Gtx);
fprintf('Rx Antenna Gain = %.2f dB\n', Grx);
fprintf('Number of Scaterred Rays = %d\n', Nw);
fprintf('Doppler Shift = %.2f Hz\n', fm);
fprintf('SNR = %.2f dB\n', SNR);

fprintf('----------- Transmission Settings -----------\n');
fprintf('Sampling Rate = %d Hz\n', Fs);
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Bits = %d\n', Nb);


%%

fmCom = ['$f_m=\ $', num2str(fm), '$\ Hz$'];
snrCom = ['$SNR=\ $', num2str(SNR), '$\ dB$'];
brCom = ['$Bitrate=\ $', num2str(bitrate), '$\ Hz$'];
fsCom = ['$f_s=\ $', num2str(Fs), '$\ Hz$'];

figure(1)
axis off
text(0.1, 1, fmCom, 'FontSize', 16, Interpreter='latex');
text(0.1, 0.8, snrCom, 'FontSize', 16, Interpreter='latex');
text(0.1, 0.6, brCom, 'FontSize', 16, Interpreter='latex');
text(0.1, 0.4, fsCom, 'FontSize', 16, Interpreter='latex');


%% Plot for Comparison of Transimitted and Received Non-modulated Signal

% Define display parameters
nSeq = 1 : 64;
nMod = 1 : 32;
nSym = 32;                                  % Number of symbols to display
nPos = 1 : nSym * sps;                      % Index of symbols to display
tPos = nPos / Fs;                           % Time index of symbols to display
fmCom = ['$f_m=\ $', num2str(fm), '$\ Hz$'];
snrCom = ['$SNR=\ $', num2str(SNR), '$\ dB$'];
brCom = ['$Bitrate=\ $', num2str(bitrate), '$\ Hz$'];
fsCom = ['$f_s=\ $', num2str(Fs), '$\ Hz$'];

figEncCmp = figure(2);
figEncCmp.Name = 'Original Signal';
figEncCmp.WindowState = 'maximized';

% Transmitted sequence
subplot(2, 3, 1);
stem(nSeq, X(nSeq), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Binary Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

% Transmitted modulated signal
subplot(2, 3, 2);
plot(nMod, txModSigI(nMod), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted In-phase Modulated Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

% Transmitted baseband signal
subplot(2, 3, 3);
plot(tPos, txBbSigI(nPos), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Baseband Quadrate Signal', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

% Received sequence
subplot(2, 3, 4);
stem(nSeq, Y(nSeq), 'LineWidth', 2, "Color", '#D95319');
title('Received Binary Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

% Received modulated signal
subplot(2, 3, 5);
plot(nMod, rxSampSigI(nMod), 'LineWidth', 2, "Color", '#0072BD');
title('Received In-phase Modulated Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

% Transmitted baseband signal
subplot(2, 3, 6);
plot(tPos, rxBbSigI(nPos), 'LineWidth', 2, "Color", '#0072BD');
title('Received Baseband Quadrate Signal', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');
