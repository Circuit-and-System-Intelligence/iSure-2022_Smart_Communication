figure(1)
hold on
plot(Xn, Mn, 'Color', '#0072BD');
plot(Xn, Tn2, 'Color', '#D95319');
plot(Xn, Tn, 'Color', '#77AC30');
hold off
legend('Measured', 'Theoretical', 'Fixed');