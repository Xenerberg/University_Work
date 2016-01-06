%Script for Navigation Labs - Ex-4
close all;
PRN_1 = 1;
Code = CA(PRN_1);
n_Shifts = 8;
v_delay = floor(linspace(1,1022,n_Shifts));
h_subplots = zeros(n_Shifts,1);
Fs = 16.3676e6; %Hz
F_IF = 4.1304e6; %Hz
t_CA = 0.001; %s
freq_bin = 250; %Hz
doppler_range = (-10000:freq_bin:10000)';
n_freq_bins = (doppler_range(length(doppler_range)) - doppler_range(1))/freq_bin;
n_CA_samples = floor(t_CA*Fs);
figure;

for i_Count = 1:length(v_delay)   
   Shifted_Code = ShiftedCA(PRN_1,v_delay(i_Count));
   auto_corr = fcxcorr(Shifted_Code,Code)/(norm(Code)*norm(Shifted_Code));
   h_subplots(i_Count) = subplot(n_Shifts,1,i_Count);
   stem(h_subplots(i_Count),auto_corr);
   grid on;
end
PRN_2 = 2;
Code_2 = CA(PRN_2);
cross_corr = fcxcorr(Code_2, Code)/(norm(Code)*norm(Code_2));
figure;
stem(cross_corr);

filename = 'C:\Users\Iseberg\Documents\MATLAB\ReceiverTech\Week1874_tow478718B.sim';
fid = fopen(filename, 'rb');
fseek(fid, 0, 'bof');
signal = fread(fid,'int8');
signal_CA  = signal(1:n_CA_samples);
sprintf('The range for 4-bit sampling is: [%d,%d]',-7,7)
n_bytes = n_CA_samples*8/1024;
t = 0:1/Fs:t_CA - 1/Fs; t= t';

v_satellites = [1,31,3,32,17,23];
figure;
hist(signal_CA);
i_Count = 0;
sv_Count = 0;

v_dopp = zeros(length(v_satellites),1);
v_code = v_dopp;
v_max = v_dopp;
Correlation_MAP = zeros(n_CA_samples, n_freq_bins + 1, length(v_satellites)); 
for sv = v_satellites %change to 32
   sv_Count  = sv_Count + 1;
   i_Count = 0;
   corr_PRN = zeros(n_CA_samples,n_freq_bins);
   sampled_CA = ShiftedSampledCA(sv,1/Fs,0)';
   for f_D = doppler_range(1):freq_bin:doppler_range(length(doppler_range))
        i_Count = i_Count+1;
        carrier_sin = sin(2*pi*(F_IF + f_D)*t);
        carrier_cos = cos(2*pi*(F_IF + f_D)*t);
        I_comp = signal_CA.*carrier_sin;
        Q_comp = signal_CA.*carrier_cos;
        
        signal_complex = complex(I_comp,Q_comp);
        Z = fcxcorr( signal_complex, sampled_CA);
        corr_amp = sqrt(real(Z).^2 + imag(Z).^2);
        corr_PRN(:,i_Count) = corr_amp;        
   end
   Correlation_MAP(:,:,sv_Count) = corr_PRN; 
   [max_corr, pos] = max(corr_PRN(:));
   [code_phase_pos, dopp_offset_pos] = ind2sub(size(corr_PRN),pos);
   v_dopp(sv_Count) = dopp_offset_pos;
   v_code(sv_Count) = code_phase_pos;
   v_max(sv_Count) = max_corr;
   
end

    
    
