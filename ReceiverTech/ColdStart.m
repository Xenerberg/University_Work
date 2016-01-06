clear all; 
close all;
load('IncomingIF.mat');

Fs = 5.714e6;
Ts = 1/Fs;
incoming_1ms_IF = IncomingIF(1,:);
sv = [1;32];
code_bin = 2/5.585532746823070;
doppler_bin = 500;

for sv_counter = sv(1):sv(2)
   %Implementatation of Time-frequency search
   for code_delay = 0:code_bin:1023
      %create the code replica with sv_counter and code_delay values
      delayed_SampledCA = ShiftedSampledCA(sv_counter, Ts, code_delay);
      for frequency_counter = -10000:doppler_bin:10000
        carrier_sin = fn_CreateCarrier(Fs, frequency_counter, 1e-3, Ts, 0);
        carrier_cos = fn_CreateCarrier(Fs, frequency_counter, 1e-3, Ts, 1);
        I_comp = carrier_sin.*delayed_SampledCA;
        Q_comp = carrier_cos.*delayed_SampledCA;
        I_corr = fn_fctCorrelate(incoming_1ms_IF, I_comp);
        Q_corr = fn_fctCorrelate(incoming_1ms_IF, Q_comp);
        metric(ceil(code_delay/code_bin) + 1,(frequency_counter+10000)/doppler_bin + 1,sv_counter) = max(abs(I_corr.^2)) + max(abs(Q_corr.^2));
      end
   end
end
