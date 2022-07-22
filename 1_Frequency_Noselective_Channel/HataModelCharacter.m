% Program Description:
%   Test Program for Okumura-Hata Model
% 
% Projet:       Channel Modeling - iSure 2022
% Date:         July 8, 2022
% Author:       Zhiyu Shen
% 

clc
clear
close all

%% Parameter Definition

hb = 20;                                % Height of base station
hm = 2;                                 % Height of mobile
d0 = 1;                                 % Initial distance
dn = 20;                                % Final distance
dd = 0.5;                               % Distance increment
vecLen = (dn - d0) / dd + 1;

% Initialize vectors
% D-1 for different carrier frequency
% D-2 for different environment
% D-3 for different distance
pathLossVec = zeros(2, 3, vecLen);
powGaindBVec = zeros(2, 3, vecLen);
gainVec = zeros(2, 3, vecLen);
    
%% Carrier Frequency: fc = 433MHz

fc = 433;

% Small medium-size city
env = 0;
d = d0;
for i = 1 : vecLen
    d = d + dd;
    [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env);
    pathLossVec(1, 1, i) = pathLossdB;
    powGaindBVec(1, 1, i) = powGaindB;
    gainVec(1, 1, i) = gainPL;
end

% Suburban environment
env = 2;
d = d0;
for i = 1 : vecLen
    d = d + dd;
    [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env);
    pathLossVec(1, 2, i) = pathLossdB;
    powGaindBVec(1, 2, i) = powGaindB;
    gainVec(1, 2, i) = gainPL;
end

% Rural areas
env = 3;
d = d0;
for i = 1 : vecLen
    d = d + dd;
    [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env);
    pathLossVec(1, 3, i) = pathLossdB;
    powGaindBVec(1, 3, i) = powGaindB;
    gainVec(1, 3, i) = gainPL;
end

%% Carrier Frequency: fc = 900MHz

fc = 900;

% Small medium-size city
env = 0;
d = d0;
for i = 1 : vecLen
    d = d + dd;
    [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env);
    pathLossVec(2, 1, i) = pathLossdB;
    powGaindBVec(2, 1, i) = powGaindB;
    gainVec(2, 1, i) = gainPL;
end

% Suburban environment
env = 2;
d = d0;
for i = 1 : vecLen
    d = d + dd;
    [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env);
    pathLossVec(2, 2, i) = pathLossdB;
    powGaindBVec(2, 2, i) = powGaindB;
    gainVec(2, 2, i) = gainPL;
end

% Rural areas
env = 3;
d = d0;
for i = 1 : vecLen
    d = d + dd;
    [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env);
    pathLossVec(2, 3, i) = pathLossdB;
    powGaindBVec(2, 3, i) = powGaindB;
    gainVec(2, 3, i) = gainPL;
end


%% Plotting
figure
dPos = d0 : dd : dn;

% Plot path loss in dB
subplot(1, 3, 1)
xlabel('Distance Between Base Station and Mobile / km', 'FontSize', 14);
ylabel('Path Loss / dB', 'FontSize', 14);
% 433MHz
hold on
yPos = reshape(pathLossVec(1, 1, :), 1, vecLen);
y11a = plot(dPos, yPos, "LineWidth", 2, "Color", '#0072BD', "Marker", "o");
yPos = reshape(pathLossVec(1, 2, :), 1, vecLen);
y12a = plot(dPos, yPos, "LineWidth", 2, "Color", '#D95319', "Marker", "o");
yPos = reshape(pathLossVec(1, 3, :), 1, vecLen);
y13a = plot(dPos, yPos, "LineWidth", 2, "Color", '#77AC30', "Marker", "o");
% 900MHz
yPos = reshape(pathLossVec(2, 1, :), 1, vecLen);
y21a = plot(dPos, yPos, "LineWidth", 2, "Color", '#0072BD', "Marker", "x");
yPos = reshape(pathLossVec(2, 2, :), 1, vecLen);
y22a = plot(dPos, yPos, "LineWidth", 2, "Color", '#D95319', "Marker", "x");
yPos = reshape(pathLossVec(2, 3, :), 1, vecLen);
y23a = plot(dPos, yPos, "LineWidth", 2, "Color", '#77AC30', "Marker", "x");
hold off
legend([y21a y11a], {'433MHz', '900MHz'}, "Location", "southeast", 'FontSize', 14);

% Plot path loss in dB
subplot(1, 3, 2)
xlabel('Distance Between Base Station and Mobile / km', 'FontSize', 14);
ylabel('Power Gain / dB', 'FontSize', 14);
% 433MHz
hold on
yPos = reshape(powGaindBVec(1, 1, :), 1, vecLen);
y11b = plot(dPos, yPos, "LineWidth", 2, "Color", '#0072BD', "Marker", "o");
yPos = reshape(powGaindBVec(1, 2, :), 1, vecLen);
y12b = plot(dPos, yPos, "LineWidth", 2, "Color", '#D95319', "Marker", "o");
yPos = reshape(powGaindBVec(1, 3, :), 1, vecLen);
y13b = plot(dPos, yPos, "LineWidth", 2, "Color", '#77AC30', "Marker", "o");
% 900MHz
yPos = reshape(powGaindBVec(2, 1, :), 1, vecLen);
y21b = plot(dPos, yPos, "LineWidth", 2, "Color", '#0072BD', "Marker", "x");
yPos = reshape(powGaindBVec(2, 2, :), 1, vecLen);
y22b = plot(dPos, yPos, "LineWidth", 2, "Color", '#D95319', "Marker", "x");
yPos = reshape(powGaindBVec(2, 3, :), 1, vecLen);
y23b = plot(dPos, yPos, "LineWidth", 2, "Color", '#77AC30', "Marker", "x");
hold off
legend([y21b y11b], {'433MHz', '900MHz'}, "Location", "northeast", 'FontSize', 14);

% Plot path gain
subplot(1, 3, 3)
xlabel('Distance Between Base Station and Mobile / km', 'FontSize', 14);
ylabel('Path Gain', 'FontSize', 14);
% 433MHz
hold on
yPos = reshape(gainVec(1, 1, :), 1, vecLen);
y11c = plot(dPos, yPos, "LineWidth", 2, "Color", '#0072BD', "Marker", "o");
yPos = reshape(gainVec(1, 2, :), 1, vecLen);
y12c = plot(dPos, yPos, "LineWidth", 2, "Color", '#D95319', "Marker", "o");
yPos = reshape(gainVec(1, 3, :), 1, vecLen);
y13c = plot(dPos, yPos, "LineWidth", 2, "Color", '#77AC30', "Marker", "o");
% 900MHz
yPos = reshape(gainVec(2, 1, :), 1, vecLen);
y21c = plot(dPos, yPos, "LineWidth", 2, "Color", '#0072BD', "Marker", "x");
yPos = reshape(gainVec(2, 2, :), 1, vecLen);
y22c = plot(dPos, yPos, "LineWidth", 2, "Color", '#D95319', "Marker", "x");
yPos = reshape(gainVec(2, 3, :), 1, vecLen);
y23c = plot(dPos, yPos, "LineWidth", 2, "Color", '#77AC30', "Marker", "x");
hold off
legend([y21c y11c], {'433MHz', '900MHz'}, "Location", "northeast", 'FontSize', 14);