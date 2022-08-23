close all
clear
clc

Np = 4;

load("./lsb_4_pwr.mat", "dataErr");
dataErrA = dataErr;
clear dataErr;

load("./lsb_16_pwr.mat", "dataErr");
dataErrB = dataErr;
clear dataErr;

load("./lsb_64_pwr.mat", "dataErr");
dataErrC = dataErr;
clear dataErr;

load("./lsb_256_pwr.mat", "dataErr");
dataErrD = dataErr;
clear dataErr;

% Store measured parameter
txPwr = [0.25, 0.0625, 0.01562, 0.00391];
ebn0 = [-6.02, -12.04, -18.06, -24.08];
measBER = [2.389e-01, 3.617e-01, 4.294e-01, 4.657e-01];

% Data error distribution figure settings
dataErrPlt = figure(2);
dataErrPlt.Name = 'Transmission Data Error for AWGN channel with BPSK Modulation';
dataErrPlt.WindowState = 'maximized';
yPosRange = [0 0.7];

% Plot data error distribution (Measured, 1/4 power)
i = 1;
subplot(2, 2, 1);
histogram(dataErrA, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (1/4 power for dominant bit)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of LSB = ', num2str(txPwr(i), '%.5f'), ' W'];
text(2, 0.65, pwrText, "FontSize", 16);
ebn0Text = ['Eb/N0 of LSB = ', num2str(ebn0(i), '%.5f'), ' dB'];
text(2, 0.58, ebn0Text, "FontSize", 16);
berText = ['BER of LSB = ', num2str(measBER(i), '%.5e')];
text(2, 0.51, berText, "FontSize", 16);

% Plot data error distribution (Measured, 1/16 power)
i = i + 1;
subplot(2, 2, 2);
histogram(dataErrB, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (1/16 power)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of LSB = ', num2str(txPwr(i), '%.5f'), ' W'];
text(2, 0.65, pwrText, "FontSize", 16);
ebn0Text = ['Eb/N0 of LSB = ', num2str(ebn0(i), '%.5f'), ' dB'];
text(2, 0.58, ebn0Text, "FontSize", 16);
berText = ['BER of LSB = ', num2str(measBER(i), '%.5e')];
text(2, 0.51, berText, "FontSize", 16);

% Plot data error distribution (Measured, 1/64 power)
i = i + 1;
subplot(2, 2, 3);
histogram(dataErrC, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (1/64 power)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of LSB = ', num2str(txPwr(i), '%.5f'), ' W'];
text(2, 0.65, pwrText, "FontSize", 16);
ebn0Text = ['Eb/N0 of LSB = ', num2str(ebn0(i), '%.5f'), ' dB'];
text(2, 0.58, ebn0Text, "FontSize", 16);
berText = ['BER of LSB = ', num2str(measBER(i), '%.5e')];
text(2, 0.51, berText, "FontSize", 16);

% Plot data error distribution (Measured, 1/256 power)
i = i + 1;
subplot(2, 2, 4);
histogram(dataErrD, 2^(Np + 1), 'Normalization', 'probability', 'BinMethod', 'integers');
xlabel('Magnitude of receivde bits');
ylabel('Occurrence probability');
ylim(yPosRange);
title('Data Error Distribution (1/256 power)');
set(gca, 'Fontsize', 20, 'FontName', 'Times New Roman', 'Linewidth', 2);
pwrText = ['Tx Power of LSB = ', num2str(txPwr(i), '%.5f'), ' W'];
text(2, 0.65, pwrText, "FontSize", 16);
ebn0Text = ['Eb/N0 of LSB = ', num2str(ebn0(i), '%.5f'), ' dB'];
text(2, 0.58, ebn0Text, "FontSize", 16);
berText = ['BER of LSB = ', num2str(measBER(i), '%.5e')];
text(2, 0.51, berText, "FontSize", 16);

% sgtitle("Data Error Distribution with One Dominant Bit in The Pack", 'Fontsize', 24);