%to investigate the GPS-spreading properties
f0 = 10.23e6; %Clock frequency
f_L1 = f0*154;
f_PRN = f0/10;
sampling_rate = 1e-11;

Code = SampledCA(2, sampling_rate);
time = 0:1/sampling_rate:1023*(1/f_PRN);
Carrier = sin(2*pi*f_L1*time);

Signal = Carrier.*Code;

n_Signal = length(Signal);
dft_Signal = fft(Signal);
dft_Signal = dtf_Signal(1: n_signal/2 + 1);