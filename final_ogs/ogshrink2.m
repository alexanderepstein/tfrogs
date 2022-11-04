function [a, cost, weights] = ogshrink2(y, K1, K2, lam, Nit)
% [a, cost] = ogshrink2(y, K1, K2, lam, Nit);
% 2D overlapping group shrinkage (OGS)
% Minimizes the cost function with respect to a
%
% cost = 0.5*sum(sum(abs(y - a).^2)) + lam * sum(sqrt(conv(abs(a).^2, ones(K1,K2))));
%
% INPUT
% y : 2-D noisy signal (2D array)
% K1, K2 : size of group
% lam : regularization parameter
% Nit : number of iterations
%
% OUTPUT
% a : output (denoised signal)
% cost : cost function history
% Po-Yu Chen and Ivan Selesnick
% Polytechnic Institute of New York University
% New York, USA
% March 2012

a = y; % initialize
h1 = ones(K1,1); % for convolution
h2 = ones(K2,1); % for convolution
cost = zeros(1,Nit);
time_frequency_weighting = 1;
debug = 0;
noise_type = "stationary"; % Noise types are impulsive, clean, stationary

if time_frequency_weighting
    lam_scale_factor = 0.95;
else
    lam_scale_factor = 0.85;
end

if time_frequency_weighting
    % For noise with varying energy across the bands
    if noise_type == "clean" || noise_type == "impulsive"
            [N, Fo, Ao, W] = firpmord([4000, 6000]/(16000/2), [1 0.8], [0.01, 0.01]);
            b = firpm(10, Fo, Ao, W);
            [filter_magnitudes, ~] = freqz(b, 1, size(y, 1));
            filter_magnitudes = 3*abs(filter_magnitudes);
            if debug
                figure(3)
                freqz(b, 1, size(y, 1));
            end
    elseif noise_type == "stationary"
        filter_magnitudes = ones(512, 1);
    end


    time_energy = sum(abs(y).^2, 1);
    if noise_type == "impulsive"
        time_scaling = 8;
        energy_ratios = (time_energy./mean(time_energy));
    elseif noise_type == "clean"
        time_scaling = 1;
        energy_ratios = (time_energy./mean(time_energy));
    else
        time_scaling = 1;
        energy_ratios = (mean(time_energy)./time_energy);
    end
    energy_ratios = time_scaling.*energy_ratios./max(energy_ratios);
    time_weighting = repmat(energy_ratios, [size(y, 1), 1]);
    frequency_weighting = repmat(filter_magnitudes, [1, size(y, 2)]);
    weights = time_weighting.*frequency_weighting;
    if debug
        figure(4)
        subplot(2, 1, 1);
        plot((1:512).*8000/512, smooth(filter_magnitudes));
        xlabel("Frequency Hz");
        ylabel("Weight");
        title("Frequency Weights")
        
        subplot(2, 1, 2);
        plot(energy_ratios);
        xlabel("Time");
        ylabel("Weight");
        title("Time Weights")
    end
else
    weights = repmat(lam, size(y));
end

if time_frequency_weighting

end

for it = 1:Nit
    r = sqrt(conv2(h1, h2, abs(a).^2));
    if (time_frequency_weighting)
        cost(it) = 0.5*sum(sum(abs(y - a).^2)) + sum((lam_scale_factor^it)*weights .* r(1:size(a, 1), 1:size(a, 2)), 'all');
        v = 1 + (lam_scale_factor^it)*weights.*conv2(h1, h2, 1./r, 'valid');
    else
        cost(it) = 0.5*sum(sum(abs(y - a).^2)) + lam * sum(r(:));
        v = 1 + lam_scale_factor^it*lam*conv2(h1, h2, 1./r, 'valid');
    end
    a = y./v;
    if (debug)
       debugogshrink2(a, r, time_weighting.*frequency_weighting, h1, h2);
    end
end
end