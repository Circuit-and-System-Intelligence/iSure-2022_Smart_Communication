% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 7, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit random data or single number
%   Transmission power adjustable


clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
stdAmp = 1;                                 % Amplitude of transmission bits (V)
Np = 4;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Noise
Eb_N0 = -10;                                % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)
% Transimitter gain
idxNp = (1 : Np).';
% gainProp = 2.^(Np * ones(Np, 1) - idxNp);
% gainProp = [1; 1; 1; 1];
gainProp = [1; 0.5; 0.25; 0.5];
Gt = gainProp * stdAmp;                     % Gain of ith bit in a pack
% Gt = ones(4, 1);

%% Signal source

% Generate sending data (Decimal)
Ndata = 100000;                             % Number of sending datas (Decimalism)
% numTrans = 2;                               % Number to be transmitted
% dataSend = numTrans * ones(1, Ndata);       % Sending data (Decimal)
dataSend = randi([0, 2^Np - 1], 1, Ndata);  % Sending data (Decimal)

% Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
Nb = Ndata * Np;                            % Number of bits
txSeqTemp = zeros(Np, Ndata);
txSeqRes = dataSend;
for i = 1 : Np
    txSeqTemp(i, :) = fix(txSeqRes / 2^(Np - i));
    txSeqRes = txSeqRes - txSeqTemp(i, :) * 2^(Np - i);
end
txSeq = reshape(txSeqTemp, 1, Nb);          % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation （No phase rotation)
txModSig = 2 * (txSeq - 0.5) * stdAmp;
baseLen = length(txModSig);


%% Adjust Transmission Power According to Bit Order

txBbSig = zeros(1, Nb);
gainVar = ones(1, Nb);
for i = 1 : Np
    idxPack = i : Np : Nb;                  % Index of ith bit in a pack
    txBbSig(idxPack) = Gt(i) * txModSig(idxPack);
    gainVar(idxPack) = Gt(i);
end


%% Add Noise

% Calculate signal power
Ps = sum(txModSig.^2) / baseLen;
Eb = Ps / Fs;
N0 = Eb / (10^(Eb_N0 / 10));

% Generate gaussian white noise
sigmaN = sqrt(N0 / 2 * Fs);
chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);

% Signal goes through channel and add noise
rxBbSig = real(txBbSig + chanNoise);


%% Receiver

% Demodulation and Detection
rxSeqTemp = rxBbSig ./ abs(rxBbSig);
rxSeq = (rxSeqTemp + 1) / 2;

% Recover Sequence
dataRecvTemp = reshape(rxSeq, Np, Ndata);
recVec = 2.^(Np - 1 : -1 : 0);
dataRecv = recVec * dataRecvTemp;


%% Compute Error

bitErrTemp = rxSeq - txSeq;
bitErrNum = 0;
for j = 1 : Nb
    if bitErrTemp(j) ~= 0
        bitErrNum = bitErrNum + 1;
    end
end
bitErrRate = bitErrNum / Nb;
theorBER = qfunc(sqrt(2 * 10^(Eb_N0 / 10)));

bitErr = rxBbSig - txBbSig;
dataErr = dataRecv - dataSend;


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('SNR = %d dB\n', SNR);
fprintf('Signal Power = %d w\n', Ps);
fprintf('Noise Power for Bits = %.3d w\n', sigmaN^2);


fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Data = %d\n', Ndata);
fprintf('Data Range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack Size = %d bits\n', Np);

fprintf('\n----------- Transmission Error -----------\n');
fprintf('Actual BER = %.5d\n', bitErrRate);
fprintf('Theoretical BER = %.5d\n', theorBER);


%% Plot

% Plot bit error
transErrPlt = figure(1);
transErrPlt.Name = 'Transmission Error for AWGN with BPSK Modulation';
transErrPlt.WindowState = 'maximized';

subplot(3, 2, 1);
plot(bitErr(1 : 100 * Np), "LineWidth", 2, "Color", "#0072BD");
title('Bit Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(3, 2, 2)
hold on
histogram(bitErr, 2^(Np + 1), 'Normalization', 'pdf');
distMag = -4 * sigmaN : 0.01 : 4 * sigmaN;
idealMagPdf = normpdf(distMag, 0, sigmaN);
plot(distMag, idealMagPdf, 'Color', '#D95319', 'LineWidth', 1.5);
xlabel('Magnitude');
ylabel('PDF');
title('Bit Error Distribution', 'FontSize', 16);
legend('Simulation', 'Ideal');
hold off

subplot(3, 2, 3);
plot(dataErr(1 : 100), "LineWidth", 2, "Color", "#0072BD");
title('Data Error in Time Domain', 'FontSize', 16);
xlabel('Sequence Index');
ylabel('Error / V');

subplot(3, 2, 4)
histogram(dataErr, 2^(Np + 1), 'Normalization', 'pdf', 'BinMethod', 'integers');
xlabel('Magnitude');
ylabel('PDF');
title('Bit Error Distribution', 'FontSize', 16);

subplot(3, 2, 5)
pwrTx = 10 * log10(gainVar.^2);
plot(pwrTx(1 : 10 * Np), 'Color', '#D95319', 'LineWidth', 1.5);
title('Transmission Power', 'FontSize', 16);
xlabel('Index of Bits');
ylabel('Transmission Power / dB');







