PRN_Satellite;
Ts = 1/(5.714e6);
f_PRN = f0/10;
close all;

[Sampled_Code_PRN_1, Code_PRN_1] = SampledCA(1, Ts);
%[Sampled_Code_PRN_2, Code_PRN_2] = SampledCA(2, Ts);
Sampled_Code_PRN_2 = ShiftedSampledCA(1,Ts,200);
cross_corrCA = fcxcorr(Code_PRN_1, Code_PRN_2)/(norm(Code_PRN_1)*norm(Code_PRN_2));
mod_1 = fn_CreateCarrier(1/Ts, 0, 0.001, Ts, 0).*Sampled_Code_PRN_1;
mod_2 = fn_CreateCarrier(1/Ts, 0, 0.001, Ts, 0).*Sampled_Code_PRN_2;

lags_CA = (1:length(cross_corrCA))/f_PRN;
cross_corrSampledCA = fcxcorr(mod_1, mod_2)/(norm(mod_1)*norm(mod_2));
%cross_corrSampledCA = fcxcorr(Sampled_Code_PRN_1, Sampled_Code_PRN_2)/(norm(Sampled_Code_PRN_1)*norm(Sampled_Code_PRN_1));
lags_SampledCA = (1:length(cross_corrSampledCA))/f_PRN;

h_figure_1 = figure('Name', 'Crosscorrelation functions');
h_subplot_1 = subplot(2,1,1);
h_subplot_2 = subplot(2,1,2);
h_plot_1 = stem(h_subplot_1, lags_CA,cross_corrCA);
h_plot_2 = plot(h_subplot_2, lags_SampledCA, cross_corrSampledCA);

title(h_subplot_1, 'Crosscorrelation of CA in PRN#1 and PRN#2');
title(h_subplot_2, 'Crosscorrelation of SampledCA in PRN#1 and PRN#2');
xlabel(h_subplot_1, 'time');
ylabel(h_subplot_1, 'cross-correlation');
xlabel(h_subplot_2, 'time');
ylabel(h_subplot_2, 'cross-correlation');