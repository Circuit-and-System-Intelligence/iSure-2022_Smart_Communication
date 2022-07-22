% Description:  Test Program for Fading Channel Model (Simple Wave)
% Projet:       Channel Modeling - iSure 2022
% Date:         July 12, 2022
% Author:       Zhiyu Shen

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                       % Bitrate (Hz)
Fs = 1e6;                               % Sampling rate (Hz)

% Define wireless communication environment parameters
% Large-Scale fading
hb = 20;                                % Height of base station (m)
hm = 2;                                 % Height of mobile (m)
d = 2;                                  % Distance between base station and mobile (m)
env = 0;                                % Application environment
fc = 1050;                              % Carrier frequency (MHz)
% Small-Scale fading
Nw = 34;                                % Number of scattered plane waves arriving at the receiver
fm = 100;                                % Maximum doppler shift (Hz)
t0 = 0;                                 % Initial time (s)
phiN = 0;                               % Initial phase of signal with maximum doppler shift (rad)
% Noise
SNR = 1000;                             % Signal-to-noise ratio


%% Signal Source
t = 0 : 1/Fs : 0.1 - 1/Fs;
fs_limH = 3000;                         % Signal upper cut-off frequency (Hz)
fs_limL = 2500;                         % Signal lower cut-off frequency (Hz)
df = 10;                                % Signal frequency interval
fs = fs_limL : df : fs_limH;            % Signal frequency vector
txSig = 0;
for ii = 1 : length(fs)
    txSig = cos(2 * pi * fs(ii) * t) + txSig;
end

% txSig = square(2*pi*fs*t);              % Square signal
% txSig = [1,zeros(1,n-1)];               % Impulse signal
% flim_low = 0;
% flim_high = 100;
% txSig = FreSquare(n, fsamp, flim_low, flim_high);
% txSig = txSig .* sin(2 * pi * fc * t);  % Sinusoid
% 
% txSig = ones(1,n);


%% Fading Channel

Ns = length(abs(txSig));                % Number of signal samples

% Calculate large-scale fading
E0 = HataPathLoss(d, hb, hm, fc, env);

% Calculate small-scale fading
h0 = RayleighFadingChannel(Nw, fm, Ns, Fs, t0, phiN);

% Combined fading channel response
h = 1 * h0;

% Received signal
rxSig = txSig .* h0;
% rxSig = awgn(txSig .* h0, SNR);


%% Plot for Comparison of Transimitted and Received Signal

% Original signal
sigCom = ['$f_t=\ $', num2str(fs_limL), '$\sim$', num2str(fs_limH), '$\ Hz$,', ...
          '$\quad \Delta f=\ $', num2str(df), '$\ Hz$,', ...
          '$\quad f_m=\ $', num2str(fm), '$\ Hz$'];
figure(1)
box on
grid on

subplot(4, 1, 1);
plot(t, txSig, 'linewidth', 2, "Color", '#0072BD');
title("Transmitted Signal", sigCom, 'FontSize', 16, 'Interpreter', 'latex');
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude", 'FontSize', 16);

subplot(4, 1, 2);
plot(t, real(rxSig/(max(rxSig)-min(rxSig)))*2, 'linewidth', 2, "Color", '#D95319');
title("Received Signal", 'FontSize', 16);
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude", 'FontSize', 16);

subplot(4, 1, 3);
plot(t, abs(h), 'linewidth', 2, "Color", '#77AC30');
title("Magnitude of Channel Response", 'FontSize', 16);
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude", 'FontSize', 16);

subplot(4, 1, 4);
plot(t, angle(h)/pi, 'linewidth', 2, "Color", '#7E2F8E');
title("Angle of Channel Response", 'FontSize', 16);
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude / \pi rad", 'FontSize', 16);
% 
% % Zoom in
% figure(2)
% hold on
% box on
% grid on
% 
% subplot(2, 1, 1);
% plot(t, txSig, 'linewidth', 2, "Color", '#0072BD');
% title("Transmitted Signal (Partial)");
% xlim([0.0045,0.0055]);
% xlabel("Time / s");
% ylabel("Magnitude");
% 
% subplot(2, 1, 2);
% plot(t, real(rxSig/(max(rxSig)-min(rxSig)))*2, 'linewidth', 2, "Color", '#D95319');
% title("Received Signal (Partial)");
% xlim([0.0045,0.0055]);
% xlabel("Time / s");
% ylabel("Magnitude");
% 
% hold off

%% Channel response with time varying

figure(3)
hold on
box on
grid on
zoomArea = [0.0005,0.0035];

subplot(4, 1, 1);
plot(t, txSig, 'linewidth', 2, "Color", '#0072BD');
title("Transmitted Signal", sigCom, 'FontSize', 16, 'Interpreter', 'latex');
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude", 'FontSize', 16);
xlim(zoomArea);

subplot(4, 1, 2);
plot(t, real(rxSig/(max(rxSig)-min(rxSig)))*2, 'linewidth', 2, "Color", '#D95319');
title("Received Signal", 'FontSize', 16);
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude", 'FontSize', 16);
xlim(zoomArea);

subplot(4, 1, 3);
plot(t, abs(h), 'linewidth', 2, "Color", '#77AC30');
title("Channel Response", 'FontSize', 16);
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude", 'FontSize', 16);
xlim(zoomArea);

subplot(4, 1, 4);
plot(t, angle(h)/pi, 'linewidth', 2, "Color", '#7E2F8E');
title("Angle of Channel Response", 'FontSize', 16);
xlabel("Time / s", 'FontSize', 16);
ylabel("Magnitude / \pi rad", 'FontSize', 16);
xlim(zoomArea);


% %% FFT
% 
% txFFT = fftshift(fft(txSig));
% chFFT = fftshift(fft(h));
% rxFFT = fftshift(fft(rxSig));
% 
% % Calculate X coordinate
% M = length(txFFT);
% ff = (-M/2 : M/2 - 1) / (M / Fs);
% 
% figure(1)
% 
% subplot(3, 1, 1);
% hold on
% plot(ff, real(txFFT), 'linewidth', 2, "Color", '#0072BD');
% plot(ff, real(rxFFT), 'linewidth', 2, "Color", '#D95319');
% title("FFT for Signal");
% xlim([-5000 5000]);
% xlabel("Frequency / Hz");
% ylabel("Magnitude");
% legend('Tx Signal', 'Rx Signal')
% 
% subplot(3, 1, 2);
% plot(ff, real(chFFT), 'linewidth', 2, "Color", '#D95319');
% title("FFT for Channel");
% xlim([-5000 5000]);
% xlabel("Frequency / Hz");
% ylabel("Magnitude");
% 
% subplot(3, 1, 3);
% plot(ff, real(rxFFT), 'linewidth', 2, "Color", '#0072BD');
% title("FFT for Rx Signal");
% xlim([-5000 5000]);
% xlabel("Frequency / Hz");
% ylabel("Magnitude");


% %% Spectrum Comparison
% 
% % Calculate transmission signal's spectrum
% txCorrTemp = xcorr(txSig, 'normalized');
% txCorr = real(txCorrTemp(Ns : Ns + M - 1));
% txSpec = fftshift(fft(txCorr));
% 
% % Calculate fading channel coefficient's spectrum
% chanCorrTemp = xcorr(h0, 'normalized');
% chanCorr = real(chanCorrTemp(Ns : Ns + M - 1));
% chanSpec = fftshift(fft(chanCorr));
% 
% % Calculate received signal's spectrum
% rxCorrTemp = xcorr(rxSig, 'normalized');
% rxCorr = real(rxCorrTemp(Ns : Ns + M - 1));
% rxSpec = fftshift(fft(rxCorr));
% 
% % Plot
% figure(3)
% hold on
% box on
% grid on
% 
% plot(ff, real(chanSpec), 'linewidth', 2, "Color", '#0072BD');
% plot(ff, real(txSpec), 'linewidth', 2, "Color", '#D95319');
% plot(ff, real(rxSpec), 'linewidth', 2, "Color", '#77AC30');
% xlim([-5000 5000]);
% title("Channel Spectrum and Signal Spectrum");
% xlabel('f / Hz');
% ylabel('Spectrum');
% legend('Channel Spectrum', 'Tx Signal Spectrum', 'Rx Signal Spectrum');
% 
% hold off








