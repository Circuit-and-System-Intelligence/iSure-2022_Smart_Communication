% Description:  Test Program for Transmission Error Distribution
% Projet:       Channel Modeling - iSure 2022
% Date:         Aug 13, 2022
% Author:       Zhiyu Shen

% Additional Description:
%   AWGN channel, BPSK modulation
%   Transmit single data and iterate through all number within range
%   Transmission power adjustable


clc
clear
close all


%% Parameter Definition

% Define baseband parameters
bitrate = 100000;                           % Bitrate (Hz)
stdAmp = 1;                                 % Amplitude of transmission bits (V)
Np = 5;                                     % Number of bits in a package
Ndata = 100000;                             % Number of sending datas (Decimalism)
Fs = bitrate;                               % Sampling rate (Hz)
M = 2;                                      % Modulation order
Fsym = bitrate / log2(M);                   % Symbol rate (Hz)
sps = Fs / Fsym;                            % Samples per symbol
Feq= Fs / log2(M);                          % Equivalent sampling rate for symbols (Hz)

% Define wireless communication environment parameters

% Noise
Eb_N0 = 0;                                  % Average bit energy to single-sided noise spectrum power (dB)
Es_N0 = log10(log2(M)) + Eb_N0;             % Average symbol energy to single-sided noise spectrum power (dB)
SNR = 10 * log10(Fsym / Fs) + Es_N0;        % Signal-to-noise ratio (dB)
% Transimitter gain
idxNp = (1 : Np).';
% gainProp = 2.^(Np * ones(Np, 1) - idxNp);
gainProp = [1; 1; 1; 0.25; 0.125];
Gt = gainProp * stdAmp;                     % Gain of ith bit in a pack
% Gt = ones(4, 1);


%% Print Transmission Information

fprintf('AWGN Channel, BPSK Mdulation\n');
fprintf('Baseband Equivalent\n');
fprintf('Bit Error Gaussian Distributed\n')

fprintf('\n---------- Environment Information ----------\n');
fprintf('SNR = %d dB\n', SNR);

fprintf('\n----------- Transmission Settings -----------\n');
fprintf('Bitrate = %d Hz\n', bitrate);
fprintf('Number of Data = %d\n', Ndata);
fprintf('Data Range = 0 ~ %d\n', 2^Np - 1);
fprintf('Pack Size = %d bits\n', Np);


%% Plot Settings
% Plot bit error
transErrPlt = figure(1);
transErrPlt.Name = 'Transmission Error of Different Numbers (AWGN Channel, BPSK Modulation)';
transErrPlt.WindowState = 'maximized';
pltLine = 2^3;
pltRow = 2^Np / pltLine;


%% Transmission Iteration

for i = 1 : 2^Np

    %%% Signal source

    % Generate sending data (Decimal)
    numTrans = i - 1;                           % Number to be transmitted
    dataSend = numTrans * ones(1, Ndata);       % Sending data (Decimal)

    % Convert decimal numbers into binary sequence (1st: MSb -> last: LSB)
    Nb = Ndata * Np;                            % Number of bits
    txSeqTemp = zeros(Np, Ndata);
    txSeqRes = dataSend;
    for j = 1 : Np
        txSeqTemp(j, :) = fix(txSeqRes / 2^(Np - j));
        txSeqRes = txSeqRes - txSeqTemp(j, :) * 2^(Np - j);
    end
    txSeq = reshape(txSeqTemp, 1, Nb);          % Binary sending sequence (0 and 1 seq)
    
    
    %%% Baseband Modulation

    % BPSK baeband modulation （No phase rotation)
    txModSig = 2 * (txSeq - 0.5) * stdAmp;
    baseLen = length(txModSig);
    
    
    %%% Adjust Transmission Power According to Bit Order
    
    txBbSig = zeros(1, Nb);
    gainVar = ones(1, Nb);
    for j = 1 : Np
        idxPack = j : Np : Nb;                  % Index of ith bit in a pack
        txBbSig(idxPack) = Gt(j) * txModSig(idxPack);
        gainVar(idxPack) = Gt(j);
    end
    
    
    %%% Add Noise
    
    % Calculate signal power
    Ps = sum(txModSig.^2) / baseLen;
    Eb = Ps / Fs;
    N0 = Eb / (10^(Eb_N0 / 10));
    
    % Generate gaussian white noise
    sigmaN = sqrt(N0 / 2 * Fs);
    chanNoise = sigmaN * randn(1, baseLen) + 1i * sigmaN * randn(1, baseLen);
    
    % Signal goes through channel and add noise
    rxBbSig = real(txBbSig + chanNoise);
    
    
    %%% Receiver
    
    % Demodulation and Detection
    rxSeqTemp = rxBbSig ./ abs(rxBbSig);
    rxSeq = (rxSeqTemp + 1) / 2;
    
    % Recover Sequence
    dataRecvTemp = reshape(rxSeq, Np, Ndata);
    recVec = 2.^(Np - 1 : -1 : 0);
    dataRecv = recVec * dataRecvTemp;    
    

    %%% Plot
    
    % Calculate error
    dataErr = dataRecv - dataSend;

    % Plot error distribution
    posRow = mod(i - 1, pltRow) + 1;
    posLine = fix((i - 1) / pltRow) + 1;
    pltPos = (posRow - 1) * pltLine + posLine;
    subplot(pltRow, pltLine, pltPos);
    histogram(dataErr, 2^(Np + 1), 'Normalization', 'pdf');
    xlabel('Magnitude');
    ylabel('PDF');
    titText = ['Error Distribution (Transmitted Number: ', num2str(i - 1), ')'];
    title(titText, 'FontSize', 16);

end

geneTit = ['Eb/N0 = ', num2str(Eb_N0), ', Pack Size = ', num2str(Np)];
sgtitle(geneTit, 'Fontsize', 16);

%% Plot Transmission Power Variation

txPwr = figure(2);
txPwr.Name = 'Transmission Power Variation';
txPwr.WindowState = 'maximized';

pwrTx = 10 * log10(gainVar.^2);
plot(pwrTx(1 : 10 * Np), 'Color', '#D95319', 'LineWidth', 1.5);
title('Transmission Power', 'FontSize', 16);
xlabel('Index of Bits');
ylabel('Transmission Power / dB');







