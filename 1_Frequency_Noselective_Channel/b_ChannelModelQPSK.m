% Description:  Test Program for Fading Channel Model with QPSK Modulation
% Projet:       Channel Modeling - iSure 2022
% Date:         July 12, 2022
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
SNR = 0;                                  % Signal-to-noise ratio


%% Signal source
Nb = 1024;                                  % Number of sending bits
X = randi([0, 1], 1, Nb);                   % Binary sending sequence (0 and 1 seq)


%% Encode

% % (7,4) Hamming code
% nCode = 7;                                  % Codeword length
% kMsg = 4;                                   % Message length
% txEncSig = encode(X, nCode, kMsg, 'hamming/binary');
txEncSig = X;
encLen = length(txEncSig);                  % Calculate length of encoded sequence


%% Baseband Modulation

% QPSK baeband modulation
txModSigTemp = (reshape(txEncSig, 2, encLen / 2) - 0.5) * (-sqrt(2));
txModSigI = txModSigTemp(2, :);
txModSigQ = txModSigTemp(1, :);

% % Baseband modulation with 'pskmod' function
% 
% % Rearrange sneding bits in pairs of 2
% modVecTest = reshape(encSig, 2, encLen / 2);
% 
% % Modulation
% modSigTest = pskmod(modVecTest, M, pi/M, "gray", "InputType","bit");
% modSigITest = real(modSigTest);           % In-phase component of modulated signal
% modSigQTest = imag(modSigTest);           % Quadrature component of modulated signal
% 
% % Compare hand writing code and MATLAB function
% nPosMod = 1 : 32;
% figure
% subplot(2, 2, 1);
% plot(modSigI(nPosMod));
% title('Modulated In-Phase Signal (Hand written)');
% subplot(2, 2, 3);
% plot(modSigITest(nPosMod));
% title('Modulated In-Phase Signal (MATLAB Function)');
% subplot(2, 2, 2);
% plot(modSigQ(nPosMod));
% title('Modulated Quadrate Signal (Hand written)');
% subplot(2, 2, 4);
% plot(modSigQTest(nPosMod));
% title('Modulated Quadrate Signal (MATLAB Function)');

% % Plot constellation map
% scatterplot(modSig);
% title('Transmission Constellation');


%% Baseband Shaping

% Upsampling (Interpolation)
modLen = length(txModSigI);                 % Fetch the length of modulated signal
txSampZero = zeros(sps - 1, modLen);        % Zero vector added to original signal vector
txSamTempI = [txModSigI; txSampZero];       % Upsamling for each element of I signal vector
txSamTempQ = [txModSigQ; txSampZero];       % Upsamling for each element of Q signal vector
txSamSigI = reshape(txSamTempI, 1, modLen * sps);
txSamSigQ = reshape(txSamTempQ, 1, modLen * sps);

% % Upsampling with Function (Interpolation)
% upsamSigITest = upsample(modSigI, sps);     % In-phase component of upsampled signal
% upsamSigQTest = upsample(modSigQ, sps);     % Quadrature component of upsampled signal

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

% % Plot for comparison of signal before and after shaping
% figure(2);
% hold on
% plot(txFiltSigI(1:30*sps), "Color", '#0072BD');
% plot(upsamSigI(1:30*sps) + 0.8, "Color", '#D95319');
% hold off
% title("In-phase Component of Signal After Baseband Shaping")
% legend("Baseband Signal", "Upsampled Signal")


%% Fading Channel

% Consider the impact of transmit antenna
txSig = 10^(Gtx / 20) * txBbSig;            % Consider transmitter antenna gain
Ns = length(abs(txSig));                    % Number of signal samples

% Calculate large-scale fading
[~, ~, E0] = HataPathLoss(d, hb, hm, fc, env);

% Calculate small-scale fading
Feq = Fs / log2(M);                         % Equivalent sampling frequency
h0 = RayleighFadingChannel(Nw, fm, Ns, Feq, t0, phiN);

% Combined fading channel response
h = 1 * h0;

% Signal goes through channel
rxChanSig = awgn(txSig .* h, SNR, 'measured');


%% Receive Signal

% Consider the impact of receive antenna
rxSig = 10^(Grx / 20) * rxChanSig;

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
rxDemSig = reshape(rxDemSigTemp, 1, encLen);


%% Decode
% Y = decode(rxDemSig, nCode, kMsg, 'hamming/binary');
Y = rxDemSig;
bitErrTemp = Y - X;
bitErrNum = 0;
for i = 1 : Nb
    if bitErrTemp(i) ~= 0
        bitErrNum = bitErrNum + 1;
    end
end
bitErrRate = bitErrNum / Nb;


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

fprintf('------------ Transmission Result ------------\n');
fprintf('BER = %.4f%%\n', bitErrRate * 100);


%% Plot for Comparison of Transimitted and Received Modulated Signal

% Extract IQ components from complex signals
txSigI = real(txSig);                       % In-phase component of transmitted signal
txSigQ = imag(txSig);                       % Quadrature component of transmitted signal

% Define display parameters
nSym = 64;                                  % Number of symbols to display
nPos = 1 : nSym * sps;                      % Index of symbols to display
tPos = nPos / Fs;                           % Time index of symbols to display
fmCom = ['$f_m=\ $', num2str(fm), '$\ Hz$'];
snrCom = ['$SNR=\ $', num2str(SNR), '$\ dB$'];
brCom = ['$Bitrate=\ $', num2str(bitrate), '$\ Hz$'];
fsCom = ['$f_s=\ $', num2str(Fs), '$\ Hz$'];

figFrontCmp = figure(3);
figFrontCmp.Name = 'Modulated Baseband Signal';
figFrontCmp.WindowState = 'maximized';
plotI = 3;
plotJ = 3;

% Transmitted I signal -> Received I signal
subplot(plotI, plotJ, 0 * plotI + 1);
plot(tPos, txSigI(nPos), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted In-phase Signal', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

subplot(plotI, plotJ, 1 * plotI + 1);
plot(tPos, rxBbSigI(nPos), 'LineWidth', 2, "Color", '#D95319');
title('Received In-phase Signal', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

subplot(plotI, plotJ, 2 * plotI + 1);
plot(tPos, rxFiltSigI(nPos), 'LineWidth', 2, "Color", '#77AC30');
title('Received In-phase Signal Filtered', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

% Transmitted Q signal -> Received Q signal
subplot(plotI, plotJ, 0 * plotI + 2);
plot(tPos, txSigQ(nPos), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Quadrate Signal', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

subplot(plotI, plotJ, 1 * plotI + 2);
plot(tPos, rxBbSigQ(nPos), 'LineWidth', 2, "Color", '#D95319');
title('Received Quadrate Signal', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

subplot(plotI, plotJ, 2 * plotI + 2);
plot(tPos, rxFiltSigQ(nPos), 'LineWidth', 2, "Color", '#77AC30');
title('Received Quadrate Signal Filtered', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

% Channel character
subplot(plotI, plotJ, 0 * plotI + 3);
plot(tPos, abs(h0(nPos)), 'LineWidth', 2, "Color", '#7E2F8E');
title('Norm of Fading Channel Coefficient', 'FontSize', 16);
xlabel('time / s');
ylabel('Amplitude / V');

subplot(plotI, plotJ, 1 * plotI + 3);
plot(tPos, angle(h0(nPos))/pi, 'LineWidth', 2, "Color", '#7E2F8E');
title('Angle of Fading Channel Coefficient', 'FontSize', 16);
xlabel('time / s');
ylabel('Angle / \pi rad');

subplot(plotI, plotJ, 2 * plotI + 3);
axis off
text(0.1, 1, fmCom, 'FontSize', 16, Interpreter='latex');
text(0.1, 0.8, snrCom, 'FontSize', 16, Interpreter='latex');
text(0.1, 0.6, brCom, 'FontSize', 16, Interpreter='latex');
text(0.1, 0.4, fsCom, 'FontSize', 16, Interpreter='latex');


%% Plot for Comparison of Transimitted and Received Unresampled Signal

% Define display parameters
nMod = 1 : 64;                                  % Index of symbols to display

figModCmp = figure(4);
figModCmp.Name = 'Modulated Unresampled Signal';
figModCmp.WindowState = 'maximized';

% Transmitted I signal -> Received I signal
subplot(2, 2, 1);
plot(nMod, txModSigI(nMod), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted In-phase Modulated Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

subplot(2, 2, 3);
plot(nMod, rxSampSigI(nMod), 'LineWidth', 2, "Color", '#D95319');
title('Received In-phase Modulated Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

% Transmitted Q signal -> Received Q signal
subplot(2, 2, 2);
plot(nMod, txModSigQ(nMod), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Quadrate Signal', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

subplot(2, 2, 4);
plot(nMod, rxSampSigQ(nMod), 'LineWidth', 2, "Color", '#D95319');
title('Received Quadrate Signal', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');


%% Plot for Comparison of Transimitted and Received Non-modulated Signal

% Define display parameters
nEnc = 1 : 64;                                  % Index of symbols to display

figEncCmp = figure(5);
figEncCmp.Name = 'Encoded Signal';
figEncCmp.WindowState = 'maximized';

% Transmitted encoded signal -> Received undecoded signal
subplot(2, 2, 1);
plot(nEnc, txEncSig(nEnc), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Encoded Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

subplot(2, 2, 3);
plot(nEnc, rxDemSig(nEnc), 'LineWidth', 2, "Color", '#D95319');
title('Received Demodulated(Encoded) Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

% Transmitted original signal -> Received decoded signal
subplot(2, 2, 2);
plot(nEnc, X(nEnc), 'LineWidth', 2, "Color", '#0072BD');
title('Transmitted Original Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');

subplot(2, 2, 4);
plot(nEnc, Y(nEnc), 'LineWidth', 2, "Color", '#D95319');
title('Received Decoded Sequence', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Amplitude / V');
