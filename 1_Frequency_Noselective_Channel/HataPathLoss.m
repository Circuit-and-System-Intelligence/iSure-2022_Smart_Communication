function [pathLossdB, powGaindB, gainPL] = HataPathLoss(d, hb, hm, fc, env)
%
% Okumura-Hata Model for Path Loss
%
% Formulas used in this function are from Wireless Communication by
% A.F.Molisch Appendices for Chapter 7
%
% Input Arguments
%   @d:   Distance between transmiter and receiver (km) - 1 ~ 20 km
%   @hb:  Transmit antenna height (m) - 30 ~ 200 m
%   @hm:  Receive antenna height (m) - 1 ~ 10 m
%   @fc:  Carrier frequency (MHz) - 150 ~ 1500 MHz
%   @env: Application environment
%         0 - small medium-size cities
%         1 - metropolitan areas
%         2 - suburban environments
%         3 - rural areas
%
% Output Arguments
%   @pathLossdB: Path loss in dB
%   @powAtten:   Power attenuation
%   @gainPL:     Channel gain caused by path loss
%

% Calculate parameter a(Hrx) and C according to environment argument
if env == 0         % For small medium-size cities
    a = (1.11 * log10(fc) - 0.7) * hm - (1.56 * log10(fc) - 0.8);
    C = 0;
elseif env == 1     % For metropolitan areas
    if fc <= 200
        a = 8.29 * (log10(1.54 * hm)^2) - 1.1;
    elseif fc >= 400
        a = 3.2 * (log10(11.75 * hm)^2) - 4.97;
    else
        error(['Error! Carrier frequency must be less than 200MHz ' ...
            'or over 400MHz in metropolitan areas!']);
    end
    C = 0;
elseif env == 2     % For suberban environments
    a = (1.11 * log10(fc) - 0.7) * hm - (1.56 * log10(fc) - 0.8);
    C = -2 * (log10(fc/28))^2 - 5.4;
elseif env == 3     % For rural areas
    a = (1.11 * log10(fc) - 0.7) * hm - (1.56 * log10(fc) - 0.8);
    C= -4.78 * (log10(fc))^2 + 18.33 * log10(fc) - 40.98;
end

% Calculate  parameter A and B according to previous results
A = 69.55 + 26.16 * log10(fc) - 13.82 * log10(hb) - a;
B = 44.9 - 6.55 * log10(hb);

% Calculate path loss gain both in dB and not
pathLossdB = A + B * log10(d) + C;      % Path loss in dB
powGaindB = -pathLossdB;                % Power gain in dB
gainPL = 1 / sqrt(10^(pathLossdB/20));  % Channel gain caused by path loss

end