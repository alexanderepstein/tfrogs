function [] = debugogshrink2(a, r, w, h1, h2)
    n = istft(1./r, 16000, 'Window', sqrt(hann(256, 'periodic')), 'OverlapLength', 128, 'FFTLength', 512)';
    j = istft(conv2(h1, h2, 1./r, 'valid'), 16000, 'Window', sqrt(hann(256, 'periodic')), 'OverlapLength', 128, 'FFTLength', 512)';
    m = istft(w.*conv2(h1, h2, 1./r, 'valid'), 16000, 'Window', sqrt(hann(256, 'periodic')), 'OverlapLength', 128, 'FFTLength', 512)';
    n = real(n(1:length(n) - 73));
    j = real(j(1:length(j) - 73));
    m = real(m(1:length(m) - 73));
    figure(2)
    subplot(2, 2, 2);
    spectrogram(j, sqrt(hann(256, 'periodic')), 128, 512, 16000, 'yaxis', 'onesided')
    title("Post Convolution");
    subplot(2, 2, 1);
    spectrogram(n, sqrt(hann(256, 'periodic')), 128, 512, 16000, 'yaxis', 'onesided')
    title("Preconvolution");
    subplot(2, 2, 3);
    spectrogram(m, sqrt(hann(256, 'periodic')), 128, 512, 16000, 'yaxis', 'onesided')
    title("Post Regularization");
    subplot(2, 2, 4);
    as = istft(a, 16000, 'Window', sqrt(hann(256, 'periodic')), 'OverlapLength', 128, 'FFTLength', 512)';
    as = real(as(1:length(as) - 73));
    spectrogram(as, sqrt(hann(256, 'periodic')), 128, 512, 16000, 'yaxis', 'onesided')
    title("A Update");
end