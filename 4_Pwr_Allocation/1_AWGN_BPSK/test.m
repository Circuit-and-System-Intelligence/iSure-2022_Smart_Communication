clear
clc
close all

Np = 4;
EbNo = 0;

pn = TheorDataErrorDistri(Np, EbNo);

%%% Plot

% Data error distribution figure settings
dataErrPlt = figure(1);
dataErrPlt.Name = 'Theoretical Data Error for AWGN channel with BPSK Modulation';
dataErrPlt.WindowState = 'maximized';

% Plot data error distribution (Theoretical)
xn = -2^Np + 1 : 1 : 2^Np - 1;
stem(xn, pn, "LineWidth", 2, "Color", "#0072BD")
xlabel('Data error value');
ylabel('Occurrence probability');
title('Data Error Distribution');
set(gca, 'Fontsize', 20, 'Linewidth', 2);

