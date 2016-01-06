function [correlation] = fn_fctCorrelate(signal_1, signal_2)
    correlation = sum(signal_1.*signal_2)/(norm(signal_1)*norm(signal_2));
end