function [Code] = CA(PRN)
    PRN_Satellite;
    sv = SV{PRN};%Get the "taps" for the PRN-code
    f_PRN = f0/10; %Chip frequency
    %Initialize the LFSR
    G1 = ones(1,10);
    G2 = ones(1,10);
    
    Code = zeros(1,1023);
    for i = 1:1023
       [G1, g1] = fn_Shift(G1, [3,10], [10]);
       [G2, g2] = fn_Shift(G2, v_feedbackpos, sv);
       result = mod(sum([g1,g2]),2);
       Code(i) = result;       
    end
    %Convert into BPSK equivalent code
    Code(Code == 0) = -1;
%     figure;
%     stairs((1:1023)/f_PRN, Code,'Color','r');
%     xlabel('time');
%     ylabel('amplitude');
%     ylim([-2,2]);
%     title(strcat('PRN code for GPS Satellite: ', num2str(PRN)));
%     
%     auto_result =fcxcorr(Code,Code)/(norm(Code)*norm(Code));
%     lags = (1:length(auto_result))/f_PRN;
%     figure;
%     stem(auto_result,'color','r');
%     xlabel('time');
%     ylabel('ACF magnitude');
%     title('Autocorrelation of PRN code');
end

function [v_newState, output] = fn_Shift(v_oldState, v_feedback, v_output)
    output = v_oldState(v_output);
    if length(output) > 1
        output = mod(sum(output),2);
    else
        output = output(1);
    end
    v_newState = zeros(1,10);
    %Modulo-2 (XOR) operation
    fb = mod(sum(v_oldState(v_feedback)),2);
    v_traverse = fliplr(2:length(v_oldState));
    for i_Count = v_traverse
        v_newState(i_Count) = v_oldState(i_Count - 1);
    end
    v_newState(1) = fb;      
    
end

