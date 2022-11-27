% Description:  Laplace fit of theoretical data error PDF (Changing Signal Power)
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 26, 2022
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
Fs = bitrate;                               % Sampling rate (Hz)
Np = 4;                                     % Number of bits in a pack
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Small-Scale fading
Nw = 98;                                    % Number of scattered plane waves arriving at the receiver
fm = 50;                                    % Maximum doppler shift (Hz)
t0 = 0;                                     % Initial time (s)
phiN = 0;                                   % Initial phase of signal with maximum doppler shift (rad)

% Noise power
pwrNoise = 30;                              % Noise power (dBm)
pwrNoiseUnit = 10.^(pwrNoise./10-3);        % Noise power (W)

% Signal power
pwrMsb = 20 : 0.5 : 40;                     % MSB transmit power (dBm)
pwrMsbUnit = 10.^(pwrMsb./10-3);            % MSB transmit power (W)
numPwr = length(pwrMsb);
Gstd = sqrt(pwrMsbUnit);

% Signal-to-noise ratio
ebnoMsbUnit = (pwrMsbUnit/pwrNoiseUnit)*(Fs/bitrate);
ebnoMsb = 20.*log10(ebnoMsbUnit);


%% Loop of Varying Np

bLapTheo = zeros(1, numPwr);
bLapMeas = zeros(1, numPwr);
for i = 1 : numPwr
    
    % Transimitter gain (Take MSB for reference bit)
    idxNp = (Np : -1 : 1).';
    gRatio = exp(idxNp - Np);
    txGain = gRatio * Gstd(i);                      % Transmit gain of ith bit in a pack
    
    % Generate sending data (Decimal)
    numData = 1000000;                              % Number of sending datas (Decimalism)
    dataSend = randi([0, 2^Np-1], 1, numData);      % Sending data (Decimal)
    
    % Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
    numBit = numData * Np;                          % Number of bits
    txVec = zeros(Np, numData);
    txSeqRes = dataSend;
    for j = 1 : Np
        txVec(j, :) = fix(txSeqRes / 2^(Np - j));
        txSeqRes = txSeqRes - txVec(j, :) * 2^(Np - j);
    end
    txSeq = reshape(txVec, 1, numBit);          % Binary sending sequence (0 and 1 seq)
       
    % BPSK baeband modulation (No phase rotation)
    txModSig = 2 * (txSeq - 0.5);
    baseLen = length(txModSig);
    
    % Adjust Transmission Power According to Bit Order
    txBbSig = zeros(1, numBit);
    for j = 1 : Np
        idxPack = j : Np : numBit;              % Index of ith bit in a pack
        txBbSig(idxPack) = txGain(j) * txModSig(idxPack);
    end

    % Go through Rayleigh Fading Channel
    h0 = RayleighFadingChannel(Nw, fm, baseLen, Feq, t0, phiN);
    txChanSig = txBbSig .* h0;

    % Generate gaussian white noise
    sigmaN = sqrt(pwrNoiseUnit/2);
    chanNoise = sigmaN*randn(1, baseLen) + 1i*sigmaN*randn(1, baseLen);
    
    % Signal goes through channel and add noise
    rxChanSig = real(txChanSig + chanNoise);
    
    % Eliminate the effect of fading channel
    rxBbSig = real(rxChanSig ./ h0);
    
    % Demodulation and Detection
    rxDemTemp = reshape(rxBbSig, Np, numData);
    rxVecTemp = rxDemTemp ./ abs(rxDemTemp);
    rxVec = (rxVecTemp + 1) / 2;
    
    % Recover Sequence
    recVecIdx = 2.^(Np - 1 : -1 : 0);
    dataRecv = recVecIdx * rxVec;
    
    % Compute Error
    bitErrTemp = rxVec - txVec;
    bitErrNum = zeros(Np, 1);
    measBER = ones(Np, 1);
    for j = 1 : Np
        for k = 1 : numData
            if bitErrTemp(j, k) ~= 0
                bitErrNum(j) = bitErrNum(j) + 1;
            end
        end
        measBER(j) = bitErrNum(j) / numData;
    end
    dataErr = dataRecv - dataSend;
    
    % Calculate measured data error distribution
    Mn = FreqCal(dataErr, Np);
    
    % Calculate the actual theoretical BER for each bit
    trueEbnoUnit = ebnoMsbUnit(i) * gRatio.^2;
    trueEbno = 20 * log10(trueEbnoUnit);
    theoBER = qfunc(sqrt(2*trueEbnoUnit));
    
    % Fit the theoretical PDF into Laplace distribution with point of zero
    tnZero = prod(1-theoBER);
    bLapTheo(i) = 1 / (2*tnZero);
    
    % Laplace fit of measured data error distribution
    [~, ~, ~, bLapMeas(i)] = LaplaceFit(dataErr, Np);


end


%% Plot

% Plot relationship between Ps(dBm) and original b
originPlt = figure(1);
originPlt.Name = "Relationship between Np and Laplace Fit's Parameter 'b' (Rayleigh Fading Channel)";
originPlt.WindowState = 'maximized';
% Plot curve
hold on
plot(pwrMsb, log(bLapTheo), 'LineWidth', 2, 'Color', '#D95319', 'Marker', '*', 'MarkerSize', 8);
plot(pwrMsb, log(bLapMeas), 'LineWidth', 2, 'Color', '#0072BD', 'Marker', '+', 'MarkerSize', 8);
hold off
% Set the plotting properties
xlabel("$P_S$ (dBm)", "Interpreter", "latex");
ylabel("$\mathrm{ln}(b)$", "Interpreter", "latex");
legend('Calculated by Theoretical BER', 'Calculated by Measured BER');
set(gca, 'Fontsize', 20);

% Plot relationship between Ps(W) and logrithmatic value of b
logPlt = figure(2);
logPlt.Name = "Relationship between Np and Laplace Fit's Parameter 'b' (AWGN Channel)";
logPlt.WindowState = 'maximized';
% Plot curve
hold on
plot(pwrMsbUnit, bLapTheo, 'LineWidth', 2, 'Color', '#D95319', 'Marker', '*', 'MarkerSize', 8);
plot(pwrMsbUnit, bLapMeas, 'LineWidth', 2, 'Color', '#0072BD', 'Marker', '+', 'MarkerSize', 8);
hold off
% Set the plotting properties
xlabel("$P_S$ (W)", "Interpreter", "latex");
ylabel("$b$", "Interpreter", "latex");
legend('Calculated by Theoretical BER', 'Calculated by Measured BER');
set(gca, 'Fontsize', 20);


%% Print Transmission Information

fprintf('Rayleigh Fading Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Complex noise power for bits = %.2f W\n', pwrNoiseUnit);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);

