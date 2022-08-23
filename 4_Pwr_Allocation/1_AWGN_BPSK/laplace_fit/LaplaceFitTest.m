clc
clear
close all

load("data_error.mat", 'dataErr');

histfitlaplace(dataErr)
grid on
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Amplitude')
ylabel('Number of samples')
title('Amplitude distribution of the random signal')
legend('Distribution of the signal', 'PDF of the Laplace distribution')
