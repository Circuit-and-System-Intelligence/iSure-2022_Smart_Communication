% Description:  Laplace Fit of Theoretical Data Error PDF
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 23, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Rayleigh fading channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a exponential way

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Np = 8;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Signal power
pwrNoise = 30;                              % Noise power (dBm)
pwrNoiseUnit = 10.^(pwrNoise./10-3);        % Noise power (W)
pwrMsb = 30;                                % MSB transmit power (dBm)
pwrMsbUnit = 10.^(pwrMsb./10-3);            % MSB transmit power (W)
Gstd = sqrt(pwrMsbUnit);

% Signal-to-noise ratio
ebnoUnit = (pwrMsbUnit/pwrNoiseUnit)*(Fs/bitrate);
EbNo = 10*log(ebnoUnit);

% Transimitter gain (Take MSB for reference bit)
idxNp = (Np : -1 : 1).';
gRatio = exp(idxNp - Np);
Gt = gRatio * Gstd;                         % Transmit gain of ith bit in a pack
pwrSig = Gt.^2;                             % Transmit power of ith bit in a pack


%% Calculate Some Theoretical Values

% Calculate the actual theoretical BER for each bit
trueEbnoUnit = ebnoUnit * gRatio.^2;
theorBER = 0.5 * (1-sqrt(trueEbnoUnit./(1+trueEbnoUnit)));


%% Calculate Measured and Theoretical Distribution and Their Laplace Fit

% Range of data error
Xn = -2^Np+1 : 1 : 2^Np-1;

% Calculate theoretical data error distribution
Tn = TheorDataErrorDistri(Np, trueEbnoUnit, 1);

% % Second half of data error PDF (z > 0)
% xnFit = (0 : 2^Np-1).';
% tnHalf = Tn(2^Np : end);
% funFit = fit(xnFit, tnHalf, 'exp1');
% tnHalfFit = funFit(xnFit);
% tnHalfFitFlip = flip(tnHalfFit);
% tnFit = [tnHalfFitFlip; tnHalfFit(2:end)];

% Fit Laplace curve with point of zero
bLap = 1 / (2*Tn(2^Np));
tnFit = 1/(2*bLap) * exp(-abs(Xn)/bLap);



%% Plot

distriPlt = figure(1);
distriPlt.WindowState = 'maximized';

titleSysParam = ['\it\fontname{Times New Roman}', 'Np = ', num2str(Np), ...
    ', ', 'Noise power = ', num2str(pwrNoise), ' dBm (', ...
    num2str(pwrNoiseUnit), ' W), ', 'Transmit power of MSB = ', ...
    num2str(pwrMsb), ' dBm (', num2str(pwrMsbUnit), ' W)', '\fontname{Times New Roman}\rm'];
textStr = ['\it\fontname{Times New Roman}b = ', num2str(bLap), '\fontname{Times New Roman}\rm'];

% Plot theoretical data erro distribution
hold on
% Plot theoretical distribution
stem(Xn, Tn, "LineWidth", 1.5, "Color", "#0072BD");
plot(Xn, tnFit, "LineWidth", 4, "Color", "#D95319");
hold off
% Set the plotting properties
title('Theoretical Data Error PDF (Rayleigh Fading Channel, BPSK)', titleSysParam);
xlabel('Data error value');
ylabel('Occurrence probability');
xlim([-2^Np 2^Np]);
ylim([0 max(Tn)*2]);
legend('Theoretical PDF', 'Laplace fit');
text(0, max(Tn)*1.5, textStr, 'FontSize', 24, 'HorizontalAlignment', 'center');
set(gca, 'Fontsize', 20);

%% Print Transmission Information

fprintf('Rayleigh Fading Channel, BPSK Mdulation\n');
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
ebn0Log = 10 * log10(trueEbnoUnit);
ebn0Prt = [idxNp, trueEbnoUnit, ebn0Log].';
fprintf('Bit number %d: Eb/N0 = %.5e = %.2f dB\n', ebn0Prt);

fprintf('\n----------- Transmission Error -----------\n');
berPrt = [idxNp, theorBER].';
fprintf('Bit number %d: Theoretical BER = %.3e\n', berPrt);

fprintf('\n----------- Laplace Fit Info -----------\n')
fprintf('b = %.3f\n', bLap);


