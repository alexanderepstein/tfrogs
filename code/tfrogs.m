function [a, cost, weights, normalized_energy_ratios] = tfrogs(y, K1, K2, lam, Nit, frequency_weighting)
% 2D Time Frequency Regularized Overlapping Group Shrinkage (TFROGS)
%
% INPUT
% y : 2-D noisy signal (2D array)
% K1, K2 : size of group
% lam : regularization parameter
% Nit : number of iterations
% frequency_weighting: weights to use for frequency, dim of [size(y, 1), 1] and normalized between 0 & 1
%
% OUTPUT
% a : output (denoised signal)
% cost : cost function history
% weights : time frequency weighting matrix
% weights: time-frequency wieghts matrix
% normalized_energy_ratios: time weights vector
%
% OGS
% Po-Yu Chen and Ivan Selesnick
% Polytechnic Institute of New York University
% New York, USA
% March 2012
%
% TFROGS
% Alex Epstein and Nimish Magre 
% Northeastern University
% Boston, USA

%% Allocating memory
a = y; % initialize
h1 = ones(K1, 1); % for convolution
h2 = ones(K2, 1); % for convolution
cost = zeros(1, Nit);

%% Calculating time frequency weights
time_energy = sum(abs(y).^2, 1);
energy_ratios = (time_energy./mean(time_energy));
% energy_ratios = (mean(time_energy)./time_energy); % Alternative is to use inverse of the typical ratios, useful for stationary noise
normalized_energy_ratios = energy_ratios./max(energy_ratios);
time_weighting = repmat(normalized_energy_ratios, [size(y, 1), 1]);
weights = lam*(time_weighting.*frequency_weighting);
%weights = repmat(lam, size(y)); % OGS

%% Optimization iterations
for it = 1:Nit
    r = sqrt(conv2(h1, h2, abs(a).^2));
    cost(it) = 0.5*sum(sum(abs(y - a).^2)) + sum(weights .* r(1:size(a, 1), 1:size(a, 2)), 'all');
    v = 1 + weights.*conv2(h1, h2, 1./r, 'valid');
    a = y./v;
end
end