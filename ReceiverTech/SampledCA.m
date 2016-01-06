function [sampled_code, Code, samplesPerChip] = SampledCA(PRN,Ts)
    PRN_Satellite;
    Code = CA(PRN);
    f_PRN = f0/10;
    sampled_code = resample(Code,  floor(1/Ts*0.001), 1023 );
    sampled_code(sampled_code < 0) = -1;
    sampled_code(sampled_code > 0) = 1;
    samplesPerChip = (1/Ts*0.001)/1023;
    %figure;
    %stairs((1:length(sampled_code))*1/Ts, sampled_code);
    %xlabel('time');
    %ylabel('amplitude');
    %title(strcat('Sampled PRN code for GPS:',num2str(PRN)));
    %ylim([-2,2]);
    
    %auto_result =fcxcorr(sampled_code, sampled_code)/(norm(sampled_code)*norm(sampled_code));
    %lags = (1:length(auto_result))/f_PRN;
    %figure;
    %stem(lags,auto_result,'color','r');
    %xlabel('time');
    %ylabel('ACF magnitude');
    %title('Autocorrelation of sampled-PRN code');
end