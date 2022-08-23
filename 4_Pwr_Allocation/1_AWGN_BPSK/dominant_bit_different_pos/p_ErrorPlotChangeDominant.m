close all
clear
clc

Np = 4;

load("./pwr_16_1.mat", "dataErr");
dataErrA = dataErr;
clear dataErr;

load("./pwr_16_2.mat", "dataErr");
dataErrB = dataErr;
clear dataErr;

load("./pwr_16_3.mat", "dataErr");
dataErrC = dataErr;
clear dataErr;

load("./pwr_16_4.mat", "dataErr");
dataErrD = dataErr;
clear dataErr;

% Assign some parameters
txPwr = 0.06250;
txPwrLog = 17.96;

% Data error distribution figure settings
dataErrPlt = figure(2);
dataErrPlt.Name = 'Transmission Data Error for AWGN channel with BPSK Modulation';
dataErrPlt.WindowState = 'maximized';
yPosRange = [0 0.7];

% Plot data error distribution (Measured, 1st bit)
i = 1;
subplot(2, 2, 1);
histogram(dataErrA, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (Dominant bit: LSB)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of LSB = ', num2str(txPwr, '%.5f'), ' W = ', num2str(txPwrLog, '%.2f'), ' dBm'];
text(-5, 0.65, pwrText, "FontSize", 16);

% Plot data error distribution (Measured, 2nd bit)
i = i + 1;
subplot(2, 2, 2);
histogram(dataErrB, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (Dominant bit: 2nd)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of 2nd bit = ', num2str(txPwr, '%.5f'), ' W = ', num2str(txPwrLog, '%.2f'), ' dBm'];
text(-8, 0.65, pwrText, "FontSize", 16);

% Plot data error distribution (Measured, 3rd bit)
i = i + 1;
subplot(2, 2, 3);
histogram(dataErrC, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (Dominant bit: 3rd)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of 3rd bit = ', num2str(txPwr, '%.5f'), ' W = ', num2str(txPwrLog, '%.2f'), ' dBm'];
text(-8, 0.65, pwrText, "FontSize", 16);

% Plot data error distribution (Measured, 4th bit)
i = i + 1;
subplot(2, 2, 4);
histogram(dataErrD, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (Dominant bit: MSB)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of MSB = ', num2str(txPwr, '%.5f'), ' W = ', num2str(txPwrLog, '%.2f'), ' dBm'];
text(-5, 0.65, pwrText, "FontSize", 16);

% sgtitle("Data Error Distribution with One Dominant Bit in The Pack", 'Fontsize', 24);