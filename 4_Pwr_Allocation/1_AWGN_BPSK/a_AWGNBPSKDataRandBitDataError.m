% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 17, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit random data uniformly distributted
%   Allocate transmission power in a logrithmatic way


clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
Gstd = 1;                                   % Standard transmission gain
Np = 4;                                     % Number of bits in a package
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq = Fs / log2(M);                         % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Signal-to-noise ratio
Eb_N0 = 0;                                 % Average bit energy to single-sided noise spectrum power (dB)
Eb_N0_U = 10^(Eb_N0 / 10);
% Transimitter gain (Take MSB for reference bit)
idxNp = (1 : Np).';
% gainProp = 2.^(ones(Np, 1) - idxNp);
% gainProp = [1; 1; 1; 0.5];
% gainProp = [1; 1; 1; 1; 1; 1; 0.125; 0.125];
gainProp = ones(Np, 1);
Gt = gainProp * Gstd;                     % Gain of ith bit in a pack


%% Signal source

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
txSeq = reshape(txVec, 1, Nb);          % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation (No phase rotation)
txModSig = 2 * (txSeq - 0.5) * Gstd;
baseLen = length(txModSig);


%% Adjust Transmission Power According to Bit Order

txBbSig = zeros(1, Nb);
for i = 1 : Np
    idxPack = i : Np : Nb;                  % Index of ith bit in a pack
    txBbSig(idxPack) = Gt(i) * txModSig(idxPack);
end
txPwr = abs(txBbSig.^2);


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
rxDemTemp = reshape(rxBbSig, Np, Ndata);
rxVecTemp = rxDemTemp ./ abs(rxDemTemp);
rxVec = (rxVecTemp + 1) / 2;

% Recover Sequence
recVecIdx = 2.^(Np - 1 : -1 : 0);
dataRecv = recVecIdx * rxVec;


%% Compute Error

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

bitErr = rxBbSig - txBbSig;
dataErr = dataRecv - dataSend;


%% Calculate Some Theoretical Values

% Calculate the actual theoretical BER for each bit
trueEbN0 = Eb_N0_U * (Gt / Gt(1)).^2;
theorBER = qfunc(sqrt(2 * trueEbN0));

% Calculate ideal bit error distribution
distMag = -4 * sigmaN : 0.01 : 4 * sigmaN;
idealMagPdf = normpdf(distMag, 0, sigmaN);


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Eb/N0 = %.2f dB, i.e. %.2f\n', Eb_N0, Eb_N0_U);
fprintf('Signal power = %.2f w\n', Ps);
fprintf('Complex noise power for bits = %.2f w\n', 2 * sigmaN^2);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of data = %d\n', Ndata);
fprintf('Data range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack size = %d bits\n', Np);

fprintf('\n----------- Power Allocation -----------\n');
pwrWatt = Gt.^2;
pwrLog = 10 * log10(pwrWatt * 1000);
pwrPrt = [idxNp, pwrWatt, pwrLog].';
fprintf('Bit number %d: Transmission power = %.5f W = %.2f dBm\n', pwrPrt);

fprintf('\n----------- True Eb/N0 -----------\n');
ebn0Log = 10 * log10(trueEbN0);
ebn0Prt = [idxNp, ebn0Log].';
fprintf('Bit number %d: Eb/N0 = %.2f dB\n', ebn0Prt);

fprintf('\n----------- Transmission Error -----------\n');
berPrt = [idxNp, theorBER, measBER].';
fprintf('BER Comparison:\n');
fprintf('Bit number %d: Theoretical = %.3e, Measured = %.3e\n', ...
        berPrt);


%% Plot

% Bit error distribution figure settings
bitErrPlt = figure(1);
bitErrPlt.Name = 'Transmission Bit Error for AWGN channel with BPSK Modulation';
bitErrPlt.WindowState = 'maximized';
% Plot bit error in time domain
subplot(1, 2, 1);
plot(bitErr(1 : 100 * Np), "LineWidth", 2, "Color", "#0072BD");
title('Bit Error in Time Domain');
xlabel('Sequence index');
ylabel('Error (V)');
set(gca, 'Fontsize', 20, 'Linewidth', 2);
% Plot bit error distribution (Theoretical and measured)
subplot(1, 2, 2)
hold on
histogram(bitErr, 2^(Np + 1), 'Normalization', 'pdf');
plot(distMag, idealMagPdf, 'Color', '#D95319', 'LineWidth', 2);
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
title('Data Error Distribution');
legend('Measured', 'Theoretical');
set(gca, 'Fontsize', 20, 'Linewidth', 2);
hold off

pwrNoiseUnit = 2 * sigmaN^2;
pwrNoise = 10 * log10(pwrNoiseUnit*1000);
pwrMsbUnit = Ps;
pwrMsb = 10 * log10(pwrMsbUnit*1000);
textSysParam = ['$Np=', num2str(Np), ',\quad ', 'P_N=', ...
    num2str(pwrNoise), '\ dBm\ (', num2str(pwrNoiseUnit), 'W),\quad ', ...
    'P_{TX}=', num2str(pwrMsb), '\ dBm\ (', num2str(pwrMsbUnit), ...
    'W)$'];

% Data error distribution figure settings
dataErrPlt = figure(2);
dataErrPlt.Name = 'Transmission Data Error for AWGN channel with BPSK Modulation';
dataErrPlt.WindowState = 'maximized';
% Plot data error distribution (Measured)
histogram(dataErr, 2^(Np + 1), 'Normalization', 'probability',...
    'BinMethod', 'integers');
title('\bf Data Error Distribution (AWGN Channel, BPSK)', textSysParam, ...
    'Interpreter', 'latex', 'FontName', 'Times New Roman');
xlabel('\bf Data Error Value', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylabel('\bf PDF', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
set(gca, 'Fontsize', 20);

% Data error distribution figure settings
pwrAlloPlt = figure(3);
pwrAlloPlt.Name = 'Transmission Power Allocation for AWGN channel with BPSK Modulation';
pwrAlloPlt.WindowState = 'maximized';
% Plot transmit power variation
txPwrLog = 10 * log10(txPwr * 1000);
plot(txPwrLog(1 : 10 * Np), 'Color', '#D95319', 'LineWidth', 2);
title('\bf Transmission Power Variation (AWGN Channel, BPSK)', textSysParam, ...
    'Interpreter', 'latex', 'FontName', 'Times New Roman');
xlabel('\bf Bit index', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylabel('\bf Power (dBm)', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
set(gca, 'Fontsize', 20, 'Linewidth', 2);



