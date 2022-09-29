% Description:  Computation of power savings
%               Exponentially decaying transmit power
% Projet:       Channel Modeling - iSure 2022
% Date:         Sept 27, 2022
% Author:       Zhiyu Shen

clear
clc
close all

% Define transmit power of MSB
pwrMsb = 30;                    % dBm
pwrMsbUnit = 10.^(pwrMsb/10-3); % Unit

% Define number of bits in a pack
Np = 0 : 0.5 : 20;

% Calculate power savings
theoPwrSav = pwrMsbUnit * (Np - (1-exp(-2*Np))/(1-exp(-2)));

% Approximation
linApproxPwrSav = pwrMsbUnit * (Np - 1/(1-exp(-2)));

% Plot
pwrSavPlt = figure(1);
pwrSavPlt.WindowState = 'maximized';

hold on
plot(Np, theoPwrSav, 'Color', '#D95319', 'LineWidth', 2);
plot(Np, linApproxPwrSav, 'Color', '#0072BD', 'LineWidth', 2);
hold off
title("\bf Theoretical Power Savings of Exponentially Decaying Transmit Power", ...
    "Interpreter", "latex");
xlabel("$N_p$", "Interpreter", "latex");
ylabel("Power saving $(W)$", "Interpreter", "latex");
legend('Theoretical power saving', 'Linear approximation', 'Location', 'northwest');
set(gca, 'Fontsize', 20);