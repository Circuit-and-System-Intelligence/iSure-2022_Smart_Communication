close all
clear
clc

load("./data/ebn0_awgn_bpsk.mat", "Eb_N0");
ebn0AwgnBpsk = Eb_N0;
load("./data/ther_ber_awgn_bpsk.mat", "theorBER");
berTheoAwgnBpsk = theorBER;
load("./data/ber_awgn_bpsk.mat", "bitErrRate");
berAwgnBpsk = bitErrRate;
load("./data/ebn0_rayleigh_bpsk.mat", "Eb_N0");
ebn0RayBpsk = Eb_N0;
load("./data/ther_ber_rayleigh_bpsk.mat", "theorBER");
berTheoRayBpsk = theorBER;
load("./data/ber_rayleigh_bpsk_rrc_5.mat", "bitErrRate");
berRayBpsk = bitErrRate;

clear Eb_N0 theorBER bitErrRate


%% Plot the Relationship between SNR and BER

nEbn0 = ebn0AwgnBpsk;

figBer = figure(1);
figBer.Name = 'BER Test for Wireless Transmission with BPSK Modulation';
figBer.WindowState = 'maximized';

semilogy(nEbn0, berTheoAwgnBpsk, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
hold on
semilogy(nEbn0, berTheoRayBpsk, "LineWidth", 2, "Color", "#0072BD", "Marker", "x");
semilogy(nEbn0, berAwgnBpsk, "LineWidth", 2, "Color", "#D95319", "Marker", "o");
semilogy(nEbn0, berRayBpsk, "LineWidth", 2, "Color", "#D95319", "Marker", "o");
title("BER Characteristic with BPSK Modulation (Eb/N0 in dB)", ...
    "FontSize", 16);
xlabel("Eb/N0 / dB", "FontSize", 16);
ylabel("BER", "FontSize", 16);
legend("Theoretical BER for AWGN Channel", "Theoretical BER for Rayleigh Channel", ...
    "Actual BER for AWGN Channel", "Actual BER for Rayleigh Channel", "Fontsize", 16);
hold off
grid on
box on
