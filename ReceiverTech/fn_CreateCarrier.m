function [carrier_vector] = fn_CreateCarrier(f_IF, f_d,length,Ts, flag)
    sample_vector = 0:Ts:(length/Ts - 1)*Ts;
    switch(flag)
        case 0
            carrier_vector = sin(2*pi*(f_IF + f_d)*sample_vector);
        case 1
            carrier_vector = cos(2*pi*(f_IF + f_d)*sample_vector);
    end
end