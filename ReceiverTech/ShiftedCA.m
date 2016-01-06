function shifted_sampled_code = ShiftedCA(PRN, code_delay)
    Code = CA(PRN);
    shifted_sampled_code = circshift(Code, [0, code_delay]);
end