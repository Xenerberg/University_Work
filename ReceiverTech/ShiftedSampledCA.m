
function shifted_sampled_code = ShiftedSampledCA(PRN, Ts, code_delay)
    PRN_Satellite;    
    [sampled_code,~,samplesPerChip] = SampledCA(PRN,Ts);
    code_delayTime = floor(code_delay*samplesPerChip);
    shifted_sampled_code = circshift(sampled_code, [0, code_delayTime]);
end