% Program Description:
%   Test Program for Rayleigh Fading Channel with Jakes Model
% 
% Projet:       Channel Modeling - iSure 2022
% Date:         July 11, 2022
% Author:       Zhiyu Shen
% 

clc
clear
close all


%% Parameter Definition

Nb = 1000000;                           % Number of bits
bitRate = 100000;                       % Bitrate (Hz)
Fs = 1e5;                               % Sample rate (Hz)
Ns = Nb / bitRate * Fs;                 % Number of signal samples
Nw = 98;                                % Number of scattered plane waves arriving at the receiver
fm = 50;                                % Maximum doppler shift (Hz)
t0 = 0;                                 % Initial time (s)
phiN = 0;                               % Initial phase of signal with maximum doppler shift (rad)


%% Generate Channel

% Generate channel filter factors
h = RayleighFadingChannel(Nw, fm, Ns, Fs, t0, phiN);

%% Plot
pltCom = ['$\\ f_m=\ $', num2str(fm), '$\ Hz$, ', ...
          '$N=\ $', num2str(Nw), ', ', ...
          '$Number\ of\ bits=\ $', num2str(Nb)];

% Set coordinates
M = 2^12;
tt = (0 : M - 1) / Fs;
ff = (-M/2 : M/2 - 1) / (M * fm / Fs);

figure
% Time domain channel response
figure(1);
subplot(2, 1, 1);
plot((1 : Ns) / Fs, 10 * log10(abs(h)), "Color", '#0072BD');
xlabel('Time / s');
ylabel('Fading Magnitude / dB');
title('Time Domain Wave of Channel Response Amplitude', pltCom, ...
    'FontSize', 16, 'Interpreter', 'latex');
subplot(2, 1, 2);
plot((1 : Ns) / Fs, angle(h) / pi, "Color", '#0072BD');
xlabel('Time / s');
ylabel('Angle / \pi rad');
title('Time Domain Wave of Channel Response Angle', pltCom, ...
    'FontSize', 16, 'Interpreter', 'latex');

% Distribution of channel response components
dist = figure(2);
dist.Name = 'Distribution of Jakes Model Channel Response';
% Magnitude
subplot(1, 2, 1);
hold on
histogram(abs(h), 25, 'Normalization', 'pdf');
title('\bf Fading Channel Coefficient Amplitude Distribution', ...
    'FontSize', 20, 'Interpreter', 'latex');
% Ideal distribution
distMag = 0: 0.01 : 3;
idealMagPdf = raylpdf(distMag, sqrt(1/2));
plot(distMag, idealMagPdf, 'Color', '#D95319', 'LineWidth', 2.5);
xlabel('\bf Amplitude (V)', 'Interpreter', 'latex');
ylabel('\bf PDF', 'Interpreter', 'latex');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);
legend('Simulation', 'Ideal');
hold off
% Angle
subplot(1, 2, 2);
hold on
histogram(angle(h), 25, 'Normalization', 'pdf');
title('\bf Fading Channel Coefficient Angle Distribution', ...
    'FontSize', 20, 'Interpreter', 'latex');
% Ideal distribution
distAng = -pi : 0.01 : pi;
idealAngPdf = 1 / (2*pi) * ones(length(distAng));
plot(distAng, idealAngPdf, 'Color', '#D95319', 'LineWidth', 2.5);
xlabel('\bf Phase (rad)', 'Interpreter', 'latex');
ylabel('\bf PDF', 'Interpreter', 'latex');
axis([-pi pi 0 inf]);
legend('Simulation', 'Ideal');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);
hold off

% Autocorrelation function
% ACF of simulation
corrTemp = xcorr(h, 'normalized');
chanCorr = corrTemp(Ns : length(corrTemp));
simuCorr = real(chanCorr(1 : M));
% Ideal ACF of classical Jakes Model
idealCorr = besselj(0, 2 * pi * fm * tt);
figure(3);
subplot(1, 2, 1);
hold on
plot(tt, abs(idealCorr), "Color", '#D95319', 'LineWidth', 1.5);
plot(tt, abs(simuCorr), "Color", '#0072BD', 'LineWidth', 1.5);
title('Autocorrelation Function of Channel Response', pltCom, ...
    'FontSize', 16, 'Interpreter', 'latex');
xlabel('Delay \tau/s');
ylabel('ACF');
axis([0 0.005 0 1.2]);
legend('Ideal', 'Simulation')
grid on
hold off

% Power spectrum
simuSpec = fftshift(fft(simuCorr));
idealSpec = fftshift(fft(idealCorr));
subplot(1, 2, 2);
hold on
plot(ff, abs(idealSpec), "Color", '#D95319', 'LineWidth', 1.5);
plot(ff, abs(simuSpec), "Color", '#0072BD', 'LineWidth', 1.5);
title('Doppler Spectrum', pltCom, ...
    'FontSize', 16, 'Interpreter', 'latex');
xlabel('f/fm');
ylabel('Spectrum');
axis([-1.5 1.5 0 650]);
legend('Ideal', 'Simulation')
grid on
hold off


