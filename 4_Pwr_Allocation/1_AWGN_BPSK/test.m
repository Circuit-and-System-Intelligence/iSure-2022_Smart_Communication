clear
clc
close all

xn = [2, 3, 4, 5, 6, 7, 8];
yn = [0.434, 1.146, 2.460, 4.993, 10.083, 20.116, 40.315];


plt = figure(1);
plt.WindowState = 'maximized';

plot(xn, yn, "LineWidth", 2, "Color", "#0072BD");
set(gca, 'Fontsize', 20, 'Linewidth', 2);