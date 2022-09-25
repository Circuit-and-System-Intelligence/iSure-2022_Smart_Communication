% Description:  Theoretical Fit of Data Error PDF
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 22, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a exponential way

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Np = 6;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Signal power
pwrNoiseUnit = 1;                           % Noise power (W)
pwrMsb = 0;                                 % MSB transmit power (dB)
pwrMsbUnit = 10.^(pwrMsb./10);
Gstd = sqrt(pwrMsbUnit);

% Signal-to-noise ratio
ebnoUnit = (pwrMsbUnit/pwrNoiseUnit)*(Fs/bitrate);
EbNo = 10*log(ebnoUnit);

% Transimitter gain (Take MSB for reference bit)
idxNp = (Np : -1 : 1).';
gRatio = exp(idxNp - Np);
Gt = gRatio * Gstd;                         % Transmit gain of ith bit in a pack
pwrSig = Gt.^2;                             % Transmit power of ith bit in a pack

% Data error-related parameters
minErr = 0.03;                              % Minimal data error counts
maxErrProp = 1.5;                           % Propotion between the probability of two adjacent data errors


%% Calculate Some Theoretical Values

% Calculate the actual theoretical BER for each bit
trueEbN0 = ebnoUnit * gRatio.^2;
theorBER = qfunc(sqrt(2 * trueEbN0));


%% Calculate Measured and Theoretical Distribution and Their Laplace Fit

% Range of data error
Xn = -2^Np+1 : 1 : 2^Np-1;

% Calculate theoretical data error distribution
Tn = TheorDataErrorDistri(Np, EbNo);

% Second half of data error PDF (z > 0)
xnFit = (0 : 2^Np-1).';
tnHalf = Tn(2^Np : end);
funFit = fit(xnFit, tnHalf, 'exp1');
tnHalfFit = funFit(xnFit);
tnHalfFitFlip = flip(tnHalfFit);
tnFit = [tnHalfFitFlip; tnHalfFit(2:end)];


%% Plot

distriPlt = figure(1);
distriPlt.WindowState = 'maximized';

% Plot theoretical data erro distribution
hold on
% Plot theoretical distribution
stem(Xn, Tn, "LineWidth", 2, "Color", "#0072BD");
plot(Xn, tnFit, "LineWidth", 2, "Color", "#D95319");
hold off
% Set the plotting properties
xlabel('Data error value');
ylabel('Occurrence probability');
title('Theoretical Data Error Distribution and Its Laplace Fit');
xlim([-2^Np 2^Np]);
ylim([0 max(Tn) * 2]);
set(gca, 'Fontsize', 20, 'Linewidth', 2);


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Complex noise power for bits = %.2f W\n', pwrNoiseUnit);
fprintf('Tramsmit power of MSB = %.2f W\n', pwrMsbUnit);
fprintf('Eb/N0 of MSB = %.2f dB, i.e. %.2f\n', EbNo, ebnoUnit);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Data range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack size = %d bits\n', Np);

fprintf('\n----------- Power Allocation -----------\n');
pwrLog = 10 * log10(pwrSig * 1000);
pwrPrt = [idxNp, pwrSig, pwrLog].';
fprintf('Bit number %d: Transmission power = %.5e W = %.2f dBm\n', pwrPrt);

fprintf('\n----------- True Eb/N0 -----------\n');
ebn0Log = 10 * log10(trueEbN0);
ebn0Prt = [idxNp, trueEbN0, ebn0Log].';
fprintf('Bit number %d: Eb/N0 = %.5e = %.2f dB\n', ebn0Prt);

fprintf('\n----------- Transmission Error -----------\n');
berPrt = [idxNp, theorBER].';
fprintf('Bit number %d: Theoretical BER = %.3e\n', berPrt);

% fprintf('\n----------- Laplace Fit Info -----------\n')
% fprintf('mu = %.3f\n', muLap);
% fprintf('b = %.3f\n', bLap);


