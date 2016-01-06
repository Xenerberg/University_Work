load('IncomingIF.mat');
Fs = 5.714e6;
incoming_1ms_IF = IncomingIF(1,:);
h_figures = zeros(1,1);
h_figures(1) = figure('name', 'IF data details');

h_subplots = zeros(2,1);
h_subplots(1) = subplot(2,1,1);
h_subplots(2) = subplot(2,1,2);

h_plots = zeros(2,1);
time = (1:length(incoming_1ms_IF));
h_plots(1) = plot(h_subplots(1),time, incoming_1ms_IF);
title(h_subplots(1), 'Time Series of IF data');
ylabel(h_subplots(1), 'Amplitude');
xlabel(h_subplots(2), 'Samples (over 1 sec)');
%Compute Periodgram using FFT method
N = length(incoming_1ms_IF);
dft_result = fft(incoming_1ms_IF);
dft_result = dft_result(1:N/2 + 1);
psd_result = (1/(Fs*N))*abs(dft_result).^2;
psd_result(2:end - 1) = 2*psd_result(2:end - 1);
freq = 0:Fs/length(incoming_1ms_IF):Fs/2;
psd_result_log = 10*log10(psd_result);

h_plots(2) = loglog(h_subplots(2), freq, psd_result_log, 'color', 'r');
title(h_subplots(2), 'PSD of IF data');
ylabel(h_subplots(2), 'Power/Frequncy (dB/Hz)');
xlabel(h_subplots(2), 'frequency (Hz)');