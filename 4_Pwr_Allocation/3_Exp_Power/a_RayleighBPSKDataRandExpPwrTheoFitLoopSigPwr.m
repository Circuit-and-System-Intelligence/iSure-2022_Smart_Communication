% Description:  Laplace Fit of Theoretical Data Error PDF (Changing Signal Power)
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 27, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   Rayleigh channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a exponential way

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Fs = bitrate;                               % Sampling rate (Hz)
Np = 4;                                     % Number of bits in a pack
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Signal power
pwrNoise = 30;                              % Noise power (dBm)
pwrNoiseUnit = 10.^(pwrNoise./10-3);        % Noise power (W)

% Gain ratio
idxNp = (Np : -1 : 1).';
gRatio = exp(idxNp - Np);

% Range of data error
Xn = -2^Np + 1 : 1 : 2^Np -  1;


%% Loop of Varying Transmit Power

pwrMsb = 20 : 0.5 : 40;               % MSB transmit power (dBm)
pwrMsbUnit = 10.^(pwrMsb./10-3);      % MSB transmit power (W)
numPwr = length(pwrMsb);
bLap = zeros(1, numPwr);
for i = 1 : numPwr

    Gstd = sqrt(pwrMsbUnit(i));
    
    % Signal-to-noise ratio
    ebnoUnit = (pwrMsbUnit(i)/pwrNoiseUnit)*(Fs/bitrate);
    EbNo = 10*log(ebnoUnit);

    % Transimitter gain (Take MSB for reference bit)
    Gt = gRatio * Gstd;                         % Transmit gain of ith bit in a pack
    pwrSig = Gt.^2;                             % Transmit power of ith bit in a pack

    % Calculate the actual theoretical BER for each bit
    trueEbnoUnit = ebnoUnit * gRatio.^2;
    
    % Calculate theoretical data error distribution
    Tn = TheorDataErrorDistri(Np, trueEbnoUnit, 1);
    
    % Fit Laplace curve with point of zero
    bLap(i) = 1 / (2*Tn(2^Np));

end


%% Plot

distriPlt = figure(1);
distriPlt.WindowState = 'maximized';

titleSysParam = ['\it\fontname{Times New Roman}', 'Np = ', num2str(Np), '  Noise power = ', ...
    num2str(pwrNoise), ' dBm (', num2str(pwrNoiseUnit), ' W), ', '\fontname{Times New Roman}\rm'];
textStr = ['\it\fontname{Times New Roman}b = ', num2str(bLap), '\fontname{Times New Roman}\rm'];

% Plot relationship between transmit power of MSB and original b
subplot(2, 1, 1);
plot(pwrMsb, bLap, 'LineWidth', 2, 'Color', '#D95319', 'Marker', '*', 'MarkerSize', 8);
% Set the plotting properties
title("Relationship between Transmit Power of MSB and Laplace Fit's Parameter 'b' (Rayleigh Fading Channel)", ...
    titleSysParam);
xlabel("Transmit power of MSB (dBm)");
ylabel("b");
set(gca, 'Fontsize', 20);

% Plot relationship between transmit power of MSB and logrithmatic value of b
subplot(2, 1, 2);
plot(pwrMsb, log(bLap), 'LineWidth', 2, 'Color', '#0072BD', 'Marker', '*', 'MarkerSize', 8);
% Set the plotting properties
xlabel("Transmit power of MSB (dBm)");
ylabel("ln(b)");
set(gca, 'Fontsize', 20);


%% Print Transmission Information

fprintf('Rayleigh Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Complex noise power for bits = %.2f W\n', pwrNoiseUnit);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);

