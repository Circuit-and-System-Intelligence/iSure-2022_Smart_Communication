% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 17, 2022
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
bitrate = 1000000;                          % Bitrate (Hz)
Np = 4;                                     % Number of bits in a package
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
ebnoMsbUnit = (pwrMsbUnit/pwrNoiseUnit)*(Fs/bitrate);
ebnoMsb = 10*log(ebnoMsbUnit);

% Transimitter gain (Take MSB for reference bit)
idxNp = (Np : -1 : 1).';
gRatio = exp(idxNp - Np);
txGain = gRatio * Gstd;                     % Transmit gain of ith bit in a pack
pwrSigUnit = txGain.^2;                     % Transmit power of ith bit in a pack


%% Signal source

% Generate sending data (Decimal)
numData = 1000000;                              % Number of sending datas (Decimalism)
dataSend = randi([0, 2^Np-1], 1, numData);      % Sending data (Decimal)

% Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
numBit = numData * Np;                          % Number of bits
txVec = zeros(Np, numData);
txSeqRes = dataSend;
for i = 1 : Np
    txVec(i, :) = fix(txSeqRes / 2^(Np - i));
    txSeqRes = txSeqRes - txVec(i, :) * 2^(Np - i);
end
txSeq = reshape(txVec, 1, numBit);          % Binary sending sequence (0 and 1 seq)


%% Baseband Modulation

% BPSK baeband modulation (No phase rotation)
txModSig = 2 * (txSeq - 0.5) * Gstd;
baseLen = length(txModSig);


%% Adjust Transmission Power According to Bit Order

txBbSig = zeros(1, numBit);
for i = 1 : Np
    idxPack = i : Np : numBit;              % Index of ith bit in a pack
    txBbSig(idxPack) = txGain(i) * txModSig(idxPack);
end
txPwr = abs(txBbSig.^2);


%% Add Noise

% Generate gaussian white noise
sigmaN = sqrt(pwrNoiseUnit/2);
chanNoise = sigmaN*randn(1, baseLen) + 1i*sigmaN*randn(1, baseLen);

% Signal goes through channel and add noise
rxBbSig = real(txBbSig + chanNoise);


%% Receiver

% Demodulation and Detection
rxDemTemp = reshape(rxBbSig, Np, numData);
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

    for j = 1 : numData
        if bitErrTemp(i, j) ~= 0
            bitErrNum(i) = bitErrNum(i) + 1;
        end
    end

    measBER(i) = bitErrNum(i) / numData;
end

dataErr = dataRecv - dataSend;


%% Calculate Some Theoretical Values

% Range of data error
Xn = -2^Np+1 : 1 : 2^Np-1;

% Calculate measured data error distribution
Mn = FreqCal(dataErr, Np);

% Calculate the actual theoretical BER for each bit
trueEbnoUnit = ebnoMsbUnit * gRatio.^2;
trueEbno = 20 * log10(trueEbnoUnit);
theorBER = qfunc(sqrt(2*trueEbnoUnit));

% Calculate theoretical data error distribution
Tn = TheorDataErrorDistri(Np, trueEbnoUnit, 0);

% Fit the theoretical PDF into Laplace distribution with point of zero
bLapTheo = 1 / (2*Tn(2^Np));
tnFit = 1/(2*bLapTheo) * exp(-abs(Xn)/bLapTheo);

% Laplace fit of measured data error distribution
[mnFit, IdxMnFit, muLapMeas, bLapMeas] = LaplaceFit(dataErr, Np);



%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('Eb/N0 = %.2f dB, i.e. %.2f\n', ebnoMsb, ebnoMsbUnit);
fprintf('Signal power of MSB = %.2f W\n', pwrMsbUnit);
fprintf('Complex noise power = %.2f W\n', pwrNoiseUnit);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of data = %d\n', numData);
fprintf('Data range = 0 ~ %d\n', 2^Np-1);
fprintf('Pack size = %d bits\n', Np);

fprintf('\n----------- Power Allocation -----------\n');
pwrSig = 10 * log10(pwrSigUnit*1000);
pwrPrt = [idxNp, pwrSigUnit, pwrSig].';
fprintf('Bit number %d: Transmission power = %.5f W = %.2f dBm\n', pwrPrt);

fprintf('\n----------- True Eb/N0 -----------\n');
ebn0Prt = [idxNp, trueEbno].';
fprintf('Bit number %d: Eb/N0 = %.2f dB\n', ebn0Prt);

fprintf('\n----------- Transmission Error -----------\n');
berPrt = [idxNp, theorBER, measBER].';
fprintf('BER Comparison:\n');
fprintf('Bit number %d: Theoretical = %.3e, Measured = %.3e\n', ...
        berPrt);

fprintf('\n----------- Laplace Fit Info -----------\n')
fprintf('Theoretical mu = %.3f\n', 0);
fprintf('Theoretical b = %.3f\n', bLapTheo);
fprintf('Measured mu = %.3f\n', muLapMeas);
fprintf('Measured b = %.3f\n', bLapMeas);


%% Plot

% % Write comments
% textPwrVar = ['$Np=', num2str(Np), '$', newline, '$N_{data}=', ...
%     num2str(numData), '$', newline, '$N_{bits}=', num2str(numBit), '$', ...
%     newline, '$Bitrate=', num2str(bitrate), '$'];
% textTheoParam = ['$Np=', num2str(Np), ',\quad ', 'P_N=', ...
%     num2str(pwrNoise), '\ dBm\ (', num2str(pwrNoiseUnit), 'W),\quad ', ...
%     'P_{TX}=', num2str(pwrMsb), '\ dBm\ (', num2str(pwrMsbUnit), ...
%     'W)$'];
% textMeasParam = ['$Np=', num2str(Np), ',\quad ', 'N_{data}=', ...
%     num2str(numData), ',\quad ', 'P_N=', num2str(pwrNoise), ...
%     '\ dBm\ (', num2str(pwrNoiseUnit), 'W),\quad ', 'P_{TX}=', ...
%     num2str(pwrMsb), '\ dBm\ (', num2str(pwrMsbUnit), 'W)$'];

% Theoretical data error distribution figure settings
dataErrPlt = figure(1);
dataErrPlt.Name = 'Theoretical Data Error Distribution (AWGN Channel, BPSK)';
dataErrPlt.WindowState = 'maximized';
% Plot data error distribution and its Laplace fit (Theoretical)
hold on
stem(Xn, Mn, 'LineWidth', 2.5, 'Color', '#0072BD');
plot(IdxMnFit, mnFit, 'LineWidth', 2, 'Color', '#D95319')
hold off
xlabel('\bf Data Error Value', 'Interpreter', 'latex', 'FontName', ...
    'Times New Roman');
ylabel('\bf PDF', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylim([0 max(Mn)*1.2]);
legend('Measured Data Error PDF', 'Laplace Fit');
set(gca, 'Fontsize', 24);

% Measure data error distribution figure settings
dataErrPlt = figure(2);
dataErrPlt.Name = 'Measured Data Error Distribution (AWGN Channel, BPSK)';
dataErrPlt.WindowState = 'maximized';
% Plot data error distribution and its Laplace fit (Measured)
hold on
stem(Xn, Tn, 'LineWidth', 2.5, 'Color', '#0072BD');
plot(Xn, tnFit, 'LineWidth', 2, 'Color', '#D95319')
hold off
xlabel('\bf Data Error Value', 'Interpreter', 'latex', 'FontName', ...
    'Times New Roman');
ylabel('\bf PDF', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylim([0 max(Mn)*1.2]);
legend('Theoretical Data Error PDF', 'Laplace Fit');
set(gca, 'Fontsize', 24);

% Transmit power variation figure settings
pwrAlloPlt = figure(3);
pwrAlloPlt.Name = 'Transmission Power Variation (AWGN Channel, BPSK)';
pwrAlloPlt.WindowState = 'maximized';
% Plot transmit power variation
txPwrLog = 10 * log10(txPwr * 1000);
plot(txPwrLog(1 : 40), 'Color', '#D95319', 'LineWidth', 2.5);
xlabel('\bf Bit index', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylabel('\bf Power (dBm)', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
set(gca, 'Fontsize', 24, 'Linewidth', 2);

% Eb/N0 variation figure settings
ebnoVarPlt = figure(4);
ebnoVarPlt.Name = 'Eb/N0 Variation (AWGN Channel, BPSK)';
ebnoVarPlt.WindowState = 'maximized';
% Plot Eb/N0 variation
ebnoVec = repmat(trueEbno, 10, 1);
plot(ebnoVec, 'Color', '#D95319', 'LineWidth', 2.5);
xlabel('\bf Bit index', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylabel('\bf $E_b/N_0$ (dBm)', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
set(gca, 'Fontsize', 24, 'Linewidth', 2);

% Theoretical BER variation figure settings
berVarPlt = figure(5);
berVarPlt.Name = 'Theoretical BER Variation (AWGN Channel, BPSK)';
berVarPlt.WindowState = 'maximized';
% Plot theoretical BER variation
theoBerVec = repmat(theorBER, 10, 1);
semilogy(theoBerVec, 'Color', '#D95319', 'LineWidth', 2.5);
xlabel('\bf Bit index', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylabel('\bf Theoretical BER', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
set(gca, 'Fontsize', 24, 'Linewidth', 2);


