% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 16, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a logrithmatic way
%   Changing the Eb/N0 to see how the distribution changes

clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Np = 4;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Signal power
pwrNoiseUnit = 1;                           % Noise power (W)
pwrMsbLb = -10;                             % Lower bound of MSB transmit power (dB)
pwrMsbUb = 20;                              % Upper bound of MSB transmit power (dB)
pwrMsbDelta = 1;                            % Increment of MSB transmit power (dB)
pwrMsb = pwrMsbLb : pwrMsbDelta : pwrMsbUb;
numPower = length(pwrMsb);
pwrMsbUnit = 10.^(pwrMsb./10);
Gstd = sqrt(pwrMsbUnit);

% Signal-to-noise ratio
ebnoUnit = (pwrMsbUnit/pwrNoiseUnit)*(Fs/bitrate);

% Transimitter gain (Take MSB for reference bit)
idxNp = (Np : -1 : 1).';
gRatio = exp(idxNp - Np);
txGainVex = gRatio * Gstd;                      % Gain of ith bit in a pack


%% Test Loop

muLap = zeros(1, numPower);
bLap = zeros(1, numPower);
for k = 1 : length(pwrMsbUnit)
    
    % Signal source
    % Generate sending data (Decimal)
    Ndata = 100000;                             % Number of sending datas (Decimalism)
    dataSend = randi([0, 2^Np - 1], 1, Ndata);  % Sending data (Decimal)
    % Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
    Nb = Ndata * Np;                            % Number of bits
    txVec = zeros(Np, Ndata);
    txSeqRes = dataSend;
    for i = 1 : Np
        txVec(i, :) = fix(txSeqRes / 2^(Np - i));
        txSeqRes = txSeqRes - txVec(i, :) * 2^(Np - i);
    end
    txSeq = reshape(txVec, 1, Nb);              % Binary sending sequence (0 and 1 seq)
    
    
    % Baseband Modulation
    % BPSK baeband modulation (No phase rotation)
    txModSig = 2 * (txSeq - 0.5) * Gstd(k);
    baseLen = length(txModSig);
    
    % Adjust Transmission Power According to Bit Order
    txBbSig = zeros(1, Nb);
    Gt = txGainVex(:, k);
    for i = 1 : Np
        idxPack = i : Np : Nb;                  % Index of ith bit in a pack
        txBbSig(idxPack) = Gt(i) * txModSig(idxPack);
    end
    txPwr = abs(txBbSig.^2);
    
    
    % Add Noise
    % Generate gaussian white noise
    sigmaN = sqrt(pwrNoiseUnit/2);
    chanNoise = sigmaN*randn(1, baseLen) + 1i*sigmaN*randn(1, baseLen);
    % Signal goes through channel and add noise
    rxBbSig = real(txBbSig + chanNoise);
    
    
    % Receiver
    % Demodulation and Detection
    rxDemTemp = reshape(rxBbSig, Np, Ndata);
    rxVecTemp = rxDemTemp ./ abs(rxDemTemp);
    rxVec = (rxVecTemp + 1) / 2;
    % Recover Sequence
    recVecIdx = 2.^(Np-1 : -1 : 0);
    dataRecv = recVecIdx * rxVec;
    
    % Compute Error
    bitErrTemp = rxVec - txVec;
    bitErrNum = zeros(Np, 1);
    measBER = ones(Np, 1);
    for i = 1 : Np  
        for j = 1 : Ndata
           if bitErrTemp(i, j) ~= 0
               bitErrNum(i) = bitErrNum(i) + 1;
            end
        end
        measBER(i) = bitErrNum(i) / Ndata;
    end
    
    dataErr = dataRecv - dataSend;

    % Laplace fit of measured data error distribution
    [~, ~, muLap(k), bLap(k)] = LaplaceFit(dataErr, Np);

end


%% Plot

laplacePlt = figure(1);
laplacePlt.WindowState = 'maximized';

% Plot theoretical data erro distribution
subplot(1, 2, 1);
hold on
plot(pwrMsbUnit, bLap, "LineWidth", 2, "Color", "#0072BD")
hold off
% Set the plotting properties
xlabel('Transmit power of MSB / W');
ylabel('Parameter "b" in Laplace distribution');
title('Relationship between Ptx of MSB and b');
set(gca, 'Fontsize', 20, 'Linewidth', 2);

% Plot measured data erro distribution and its Laplace fit
subplot(1, 2, 2);
hold on
plot(ebnoUnit, bLap, "LineWidth", 2, "Color", "#D95319")
hold off
% Set the plotting properties
xlabel('Eb/N0 of MSB');
ylabel('Parameter "b" in Laplace distribution');
title('Relationship between Eb/N0 of MSB and b');
set(gca, 'Fontsize', 20, 'Linewidth', 2);


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Complex noise power for bits = %.2f w\n', pwrNoiseUnit);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of data = %d\n', Ndata);
fprintf('Data range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack size = %d bits\n', Np);

