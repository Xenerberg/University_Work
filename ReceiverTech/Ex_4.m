% Navigation Labs
% Lab_4
% by Alexandr sokolov
% 12.12.2015
% Deadline 06.01.2016

close all
clear all
clc

%% FFT-IFFT acquisition method : Parallel code phase search

Fs = 16.3676*10^6;     % [Hz]
Ts = 1/Fs;             % [sec]
t_k = [0:Ts:0.001-Ts]; % seconds
f_IF = 4.1304 * 10^6;  % [Hz]

n_samples = fix(Fs*0.001); 
fid_1 = fopen('Week1874_tow478718B.sim', 'rb');
fseek(fid_1, 0, 'bof');
incoming_1_ms_IF_all = fread(fid_1, 'int8')';
len_max = length(incoming_1_ms_IF_all)/n_samples;
Results_NCI = zeros(32,16367,81);

for iter = 1:20    % number of noncoherent integrations
    incoming_1_ms_IF = incoming_1_ms_IF_all((iter*n_samples-n_samples+1):(iter*n_samples));
    length(incoming_1_ms_IF);

    % histogram
    % 
    % figure(1)
    % hold on
    % hist(incoming_1_ms_IF,16)
    % Perform Parallel code phase search

    x = incoming_1_ms_IF';
    Doppler_freq = -10000:250:10000;
    DopBinsNumber = (Doppler_freq(end)-Doppler_freq(1))/(Doppler_freq(2)-Doppler_freq(1))+1;
    Results = zeros(32,n_samples,DopBinsNumber);
    tic
    for PRN = 1:32

        CA_code_sampled = SampledCA(PRN, Ts);
        conjH = conj(fft(CA_code_sampled))/n_samples;

        ResultPRN = zeros(n_samples,DopBinsNumber);
        i = 0;
        for f_d = Doppler_freq
            i = i + 1;       
            Carrier_sin = sin(2*pi*(f_IF + f_d)*t_k)';
            Carrier_cos = cos(2*pi*(f_IF + f_d)*t_k)';
            Inphase    = x.*Carrier_sin;
            Quadrature = x.*Carrier_cos;

            X = fft(complex(Inphase,Quadrature));        
            Z = X.*conjH;
            z = ifft(Z);  

            CCF = real(z).^2 + imag(z).^2;
            ResultPRN(:,i) = CCF;
        end
        Results(PRN,:,:) = ResultPRN;
    end
    proc_time = toc;
    disp(['iteration = ',num2str(iter),' : proc. time = ', num2str(proc_time)])
    
    Results_NCI = Results_NCI + Results;
end

%%
Results = Results_NCI/(iter);


%% peak detection
PeakParams = zeros(32,4);
code_phase = [0:1:n_samples];
Doppler_freq = [-10000:250:10000];

for PRN = 1:32
    SearchSpace = squeeze(Results(PRN,:,:));
    [max_value, location] = max(SearchSpace(:));
    [Row,Col] = ind2sub(size(SearchSpace),location);
    PeakParams(PRN,:) = [PRN, max_value, Doppler_freq(Col), code_phase(Row)];   
end


%% Plot search space 
% i =0;
for PRN = 11 %[1 3 6 9 11 17 19 23 31 32]
%     if (PeakParams(PRN,2) >=0.002)
%         i = i+1;
        figRes = figure(2);       
%         subplot(2,3,i)
        SearchSpace = squeeze(Results(PRN,:,:));
        mesh((SearchSpace));
        title(['Parallel Code Phase Search, PRN: ',num2str(PRN), ', MAX: ',num2str(PeakParams(PRN,2))])
        xlim([1 size(SearchSpace,2)])
        xlabel([' Doppler,[Hz], peak at: ', num2str(PeakParams(PRN,3)),' [Hz]'])
        ylim([1 size(SearchSpace,1)])
        ylabel(['Code Phase, peak at: ', num2str(PeakParams(PRN,4)),' [smpl.]'])
%         zlim([0 0.01])
        zlabel('Correlation')
        ax = gca; set(ax,'XTick',[1:10:81]); set(ax,'XTickLabel',{num2str([-10000:2500:10000]')})
        view([-50,50])
        pause(0.2)
%         print(figRes,'-dpng', ['../pics/SearchResult_PRN',num2str(PRN),'.png']);
%     end
end

%% plot peaks prameters
figure(4);
hold on
bar(PeakParams(:,2));
title('Correlation peaks, Parallel Code Phase Search results')
xlim([0 33])
xlabel('PRN')
ylabel('Correlation peak')
set(gca,'XTick',[1:32])
ylim([0 max(PeakParams(:,2))+0.022 ])
for i = 1:32
    if PeakParams(i,2) >= 0.004 % Crude threshold
       text(PeakParams(i,1)-0.5, PeakParams(i,2)+0.02, ['PRN ', num2str(PeakParams(i,1))]) 
       text(PeakParams(i,1)-0.5, PeakParams(i,2)+0.015,['Max = ', num2str(PeakParams(i,2))]) 
       text(PeakParams(i,1)-0.5, PeakParams(i,2)+0.01, ['Doppler = ', num2str(PeakParams(i,3)),' [Hz]']) 
       text(PeakParams(i,1)-0.5, PeakParams(i,2)+0.005,['Delay = ', num2str(PeakParams(i,4)),' [samples]']) 
    end
end
plot([0 33], [0.004 0.004],'r')

