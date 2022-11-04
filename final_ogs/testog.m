% Set constant RNG for reproducible deterministic results
rng(100);

% Reading in our audio files
[noise_signal, noise_speech_rate] = audioread("sp01_keyboard_sn-10.wav"); %audioread("moz1_5dBnoisy.wav");%audioread("sp05_casino_sn-5.wav");
[clean_signal, clean_speech_rate] = audioread("sp01.wav"); %audioread("moz1_11kHz.wav"); %audioread("sp05.wav");
noise_signal = noise_signal'; clean_signal = clean_signal';
noise_signal = clean_signal + normrnd(0, 0.05, 1, length(clean_signal));

% Setting this changes what we take the STFT of, we may want to use typical
% denoising first through something like wavelet thresholding
yo = noise_signal; %  % Paper mentions typical noise reduction techniques will introduce musical noise...

% Take STFT, run denoise algorithm, take ISTFT to go back into time domain,
% ensure to use both a cola compliant window and overlap length and k needs to
% be an int in this eq. k = (length(yo) - overlap_length) / (length(window) - overlap_length)
% otherwise we can pad signal to make k an integer and remove padded 0's
% from our output
window = sqrt(hann(256, 'periodic')); 
overlap_length = 128;
fft_length = 512;
if (~iscola(window, overlap_length))
    error("COLA noncompliant parameters, imperfect reconstruction");
end
k = (length(yo) - overlap_length) / (length(window) - overlap_length);
if (k ~= floor(k))
    warning("Padding signal to provide sample reconstruction post istft, results may be off for groups that stretch across to these padded zeros");
    padding = ceil(k) * overlap_length + overlap_length - length(noise_signal);
    yo = [yo zeros(1, padding)];
else
    padding = 0;
end
tf = stft(yo, noise_speech_rate, 'Window', window, 'OverlapLength', overlap_length, 'FFTLength', fft_length);
[tf_denoised, cost, weights] = ogshrink2(tf, 2, 8, 0.35, 6);
noise = tf-tf_denoised;
[U S V flag] = svt(noise,'k',25);
lrn = (U*S*V');
tf_denoised = bm(tf_denoised, tf_denoised, lrn);
%[U S V flag] = svt(tf_denoised,'k',300);
%tf_denoised = (U*S*V');

denoised_signal = istft(tf_denoised, noise_speech_rate, 'Window', window, 'OverlapLength', overlap_length, 'FFTLength', fft_length)';
if (~isreal(denoised_signal)) 
    warning("Denoised signal came back as complex, not sure how to interpret this and only taking real part");
    denoised_signal = real(denoised_signal); % abs(denoised_signal).*sign(real(denoised_signal));
end
if (padding ~= 0)
    yo = yo(1:length(yo)-padding);
    denoised_signal = denoised_signal(1:length(denoised_signal)-padding);
end

% Just some plots for interpreting our results
time = (1:length(denoised_signal))/noise_speech_rate;
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
plot(time, noise_signal, 'Color', [0, 1, 0, 0.05]);
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
spectrogram(clean_signal, window, overlap_length, fft_length, noise_speech_rate, 'yaxis');
title("Spectrogram of Clean Signal");

subplot(3, 3, 7);
spectrogram(noise_signal, window, overlap_length, fft_length, noise_speech_rate, 'yaxis');
title("Spectrogram of Noise Signal");

subplot(3, 3, 8);
spectrogram(denoised_signal, window, overlap_length, fft_length, noise_speech_rate, 'yaxis');
title("Spectrogram of Denoised Signal");

subplot(3, 3, 9);
spectrogram(clean_signal - denoised_signal, window, overlap_length, fft_length, noise_speech_rate, 'yaxis');
title("Spectrogram of Delta Between Clean & Denoised Signal");


% Get the SNR and play the denoised signal
fprintf("SNR Pre-Denoising: %.2f SNR Post-Denoising: %.2f dB\n", get_SNR(clean_signal, yo), get_SNR(clean_signal, denoised_signal)); % Need to check the SNR calculation here
sound(denoised_signal, noise_speech_rate);
%sound(clean_signal - denoised_signal, noise_speech_rate);