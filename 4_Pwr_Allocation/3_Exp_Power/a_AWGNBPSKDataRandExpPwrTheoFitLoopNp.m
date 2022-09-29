% Description:  Laplace fit of theoretical data error PDF (Changing Np)
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 26, 2022
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


%% Loop of Varying Np

Np = 3 : 16;
numNp = length(Np);
bLap = zeros(1, numNp);
for i = 1 : numNp

    % Transimitter gain (Take MSB for reference bit)
    idxNp = (Np(i) : -1 : 1).';
    gRatio = exp(idxNp - Np(i));
    Gt = gRatio * Gstd;                         % Transmit gain of ith bit in a pack
    pwrSig = Gt.^2;                             % Transmit power of ith bit in a pack

    % Calculate the actual theoretical BER for each bit
    trueEbnoUnit = ebnoUnit * gRatio.^2;
    
    % Range of data error
    Xn = -2^Np(i) + 1 : 1 : 2^Np(i) -  1;
    
    % Calculate theoretical data error distribution
    Tn = TheorDataErrorDistri(Np(i), trueEbnoUnit, 0);
    
    % Fit Laplace curve with point of zero
    bLap(i) = 1 / (2*Tn(2^Np(i)));

end


%% Plot

distriPlt = figure(1);
distriPlt.WindowState = 'maximized';

titleSysParam = ['\it\fontname{Times New Roman}', 'Noise power = ', ...
    num2str(pwrNoise), ' dBm (', num2str(pwrNoiseUnit), ' W), ', 'Transmit power of MSB = ', ...
    num2str(pwrMsb), ' dBm (', num2str(pwrMsbUnit), ' W)', '\fontname{Times New Roman}\rm'];
textStr = ['\it\fontname{Times New Roman}b = ', num2str(bLap), '\fontname{Times New Roman}\rm'];

% Plot relationship between Np and original b
subplot(2, 1, 1);
plot(Np, bLap, 'LineWidth', 2, 'Color', '#D95319', 'Marker', '*', 'MarkerSize', 8);
% Set the plotting properties
title("Relationship between Np and Laplace Fit's Parameter 'b' (AWGN Channel)", titleSysParam);
xlabel("Np (Number of bit in a pack)");
ylabel("b");
set(gca, 'Fontsize', 20);

% Plot relationship between Np and logrithmatic value of b
subplot(2, 1, 2);
plot(Np, log(bLap), 'LineWidth', 2, 'Color', '#0072BD', 'Marker', '*', 'MarkerSize', 8);
% Set the plotting properties
xlabel("Np (Number of bit in a pack)");
ylabel("ln(b)");
set(gca, 'Fontsize', 20);


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

