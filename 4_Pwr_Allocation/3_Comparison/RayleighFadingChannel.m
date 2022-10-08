function h = RayleighFadingChannel(Nw, fm, Ns, Fs, t0, phiN)
% 
% Rayleigh Fading Channel for Small-Scale Fading
% 
% Author:  Zhiyu Shen
% Date:    July 9, 2022
% Project: Channel Modeling - iSure 2022
%
% Description:
%   Generate Rayleigh fading channel with Jakes Model
%   Channel response is the superposition of a real and a imaginary Gaussian
%   process
%   Jakes model obtain Gaussian distribution by Sum-of-sinusoid technique
% 
% Input Argument:
%   @Nw:   Number of scattered plane waves arriving at the receiver
%   @fm:   Maximum doppler shift (Hz)
%   @Ns:   Length of transmission sequence
%   @Fs:   Sampling rate
%   @t0:   Initial time (s)
%   @phiN: Initial phase of signal with maximum doppler shift (rad)
% 
% Output Argument:
%   @h: Channel response vector
% 

% Judge if input arguments are valid
if nargin < 5
    phiN = 0;
end
if nargin < 4
    t0 = 0;
end
if nargin < 3
    error('More arguments are needed for Jakes Model.');
end

if mod(Nw/2 - 1, 2) == 1
    error('Number of plane waves should be multiples of 2 but not multiples of 4.');
end

% Calculate parameters
N0 = (Nw/2 - 1) / 2;                        % Number of sinusoid components
m = 1 : N0;                                 % Sinusoid component index
n = t0 + (1 : Ns) / Fs;                     % Channel impulse response sample index
omega0 = 2 * pi * fm;                       % Maximum doppler shift in angular frequency

% Generate factors of channel impulse response
phi = [pi / (N0 + 1) * m, phiN];            % Initial pahse of each oscillator
theta = 2 * pi / Nw * m;                    % Angle of Arrival of each plane wave
omega = omega0 * cos(theta);                % Angular frequency of each oscillator
cosVec = [2 * cos(omega' * n); sqrt(2) * cos(omega0 * n)];

h = (1 / sqrt(2*N0 + 1)) * exp(1i * phi) * cosVec;

end