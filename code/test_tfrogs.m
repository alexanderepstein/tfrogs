%% Setup 
% Set constant RNG for reproducible deterministic results
rng(100);
addpath(dir("../data").folder)

% Reading in our audio files
[clean_signal, clean_speech_rate] = audioread("../data/speech_files/sp01.wav");
[noise_signal, noise_signal_rate] = audioread("../data/noise_files/keyboard_noise.wav");
noise_signal = noise_signal'; clean_signal = clean_signal';

% Ensuring noise signal length matches clean signl length through reptition
% and cropping
noise_signal = noise_signal(mod(0:length(clean_signal)-1, numel(noise_signal)) + 1);
assert(length(clean_signal) == length(noise_signal));

% Combining to create noisy signal
SNR = -10; % in dB
noisy_signal = clean_signal + (noise_signal / norm(noise_signal) * norm(clean_signal) / 10.0^(0.05*SNR));
% Uncomment the following line following line for using gaussian noise
%noisy_signal = awgn(clean_signal, SNR, "measured");

% Setting this changes what we take the STFT of
yo = noisy_signal;

% Some parameters for our test
noise_type = "impulsive"; % Noise types are impulsive, clean, stationary, used for weighting
lambda = 30; % Higher values when using both T & F weightings
Nit = 6;
K1 = 2;
K2 = 8;
window = sqrt(hann(256, 'periodic')); 
overlap_length = 128;
fft_length = 512;

%% Preprocess Data
% Take STFT
% ensure to use both a cola compliant window and overlap length and k needs to
% be an int in this eq. k = (length(yo) - overlap_length) / (length(window) - overlap_length)
% otherwise we can pad signal to make k an integer and remove padded 0's
% from our output
if (~iscola(window, overlap_length))
    error("COLA noncompliant parameters, imperfect reconstruction");
end
k = (length(yo) - overlap_length) / (length(window) - overlap_length);
if (k ~= floor(k))
    warning("Padding signal to provide sample reconstruction post istft, results may be off for groups that stretch across to these padded zeros");
    padding = ceil(k) * overlap_length + overlap_length - length(noisy_signal);
    yo = [yo zeros(1, padding)];
else
    padding = 0;
end
tf = stft(yo, noise_signal_rate, 'Window', window, 'OverlapLength', overlap_length, 'FFTLength', fft_length);

%% Creating our frequency weighting 
% For noise with varying energy across the bands
if noise_type == "clean" || noise_type == "impulsive" || noise_type == "stationary"
    [N, Fo, Ao, W] = firpmord([4000, 6000]/(noise_signal_rate/2), [1 0.8], [0.01, 0.01]);
    b = firpm(10, Fo, Ao, W);
    [filter_magnitudes, ~] = freqz(b, 1, size(tf, 1));
    filter_magnitudes = abs(filter_magnitudes);
elseif noise_type == "stationary"
    filter_magnitudes = ones(fft_length, 1);
end
frequency_weighting = repmat(filter_magnitudes, [1, size(tf, 2)]);

%% Denoising Signal
% Running TFROGS algorithm
[tf_denoised, cost, weights, energy_ratios] = tfrogs(tf, K1, K2, lambda, Nit, frequency_weighting);
denoised_signal = real(istft(tf_denoised, noise_signal_rate, 'Window', window, 'OverlapLength', overlap_length, 'FFTLength', fft_length)');

% Undoing the padding if any was necessary
if (padding ~= 0)
    yo = yo(1:length(yo)-padding);
    denoised_signal = denoised_signal(1:length(denoised_signal)-padding);
end

%% Plots, SNR Readout & Playing Denoised Signal
time = (1:length(denoised_signal))/noise_signal_rate;
figure(1)
clf;
subplot(3,3,1);
hold on;
plot(time, denoised_signal, 'Color', [1, 0, 0, 0.2]);
plot(time, clean_signal, 'Color', [0, 1, 0, 0.05]);
axis tight;
hold off;
title("Clean vs Denoised Signal");
legend("Denoised Signal", "Clean Signal");

subplot(3,3,2);
plot(time, clean_signal - denoised_signal, 'Color', [1, 0, 0, 1]);
axis tight;
title("Delta of Clean vs Denoised");

subplot(3,3,3);
hold on;
plot(time, denoised_signal, 'Color', [1, 0, 0, 0.2]);
plot(time, noisy_signal, 'Color', [0, 1, 0, 0.05]);
axis tight;
hold off;
title("Noisy vs Denoised Signal");
legend("Denoised Signal", "Noisy Signal");

subplot(3,3,4);
plot(cost)
title("Cost Per Iteration");
legend("Cost");

subplot(3, 3, 5);
mesh(mag2db(weights));
c = colorbar;
c.Label.String = "Power/Frequency db/Hz";
shading interp;
view(0, 90);
xlim([0 size(weights, 2)])
ylim([0 size(weights, 1)])
title ("Time & Frequency Attenutation Weighting");

subplot(3, 3, 6);
spectrogram(clean_signal, window, overlap_length, fft_length, noise_signal_rate, 'yaxis');
title("Spectrogram of Clean Signal");

subplot(3, 3, 7);
spectrogram(noisy_signal, window, overlap_length, fft_length, noise_signal_rate, 'yaxis');
title("Spectrogram of Noisy Signal");

subplot(3, 3, 8);
spectrogram(denoised_signal, window, overlap_length, fft_length, noise_signal_rate, 'yaxis');
title("Spectrogram of Denoised Signal");

subplot(3, 3, 9);
spectrogram(clean_signal - denoised_signal, window, overlap_length, fft_length, noise_signal_rate, 'yaxis');
title("Spectrogram of Delta Between Clean & Denoised Signal");

if noise_type ~= "stationary"
    figure(2)
    freqz(b, 1, size(tf, 1));
end

figure(3)
subplot(2, 1, 1);
plot((1:fft_length).*(noise_signal_rate/2)/fft_length, smooth(filter_magnitudes));
xlabel("Frequency Hz");
ylabel("Weight");
title("Frequency Weights")

subplot(2, 1, 2);
plot(energy_ratios);
axis tight;
xlabel("Time");
ylabel("Weight");
title("Time Weights")

% Get the SNR and play the denoised signal
if (sum(clean_signal(:).^2) == 0) || (sum((clean_signal(:)-yo(:)).^2) == 0)
    preSNR = 0;
else
    preSNR = 10*log10(sum(clean_signal(:).^2) / (sum((clean_signal(:)-yo(:)).^2)));
end

if (sum(clean_signal(:).^2) == 0) || (sum((clean_signal(:)-denoised_signal(:)).^2) == 0)
    postSNR = 0;
else
    postSNR = 10*log10(sum(clean_signal(:).^2) / (sum((clean_signal(:)-denoised_signal(:)).^2)));
end
fprintf("SNR Pre-Denoising: %.2f SNR Post-Denoising: %.2f dB\n", preSNR, postSNR);
sound(denoised_signal, noise_signal_rate);
