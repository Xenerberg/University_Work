%This script checks the speed of fcxcorr against the definition.
%Since fcxcorr is based on the FFTW implementation of the Fast Fourier
%Transform, it should be fastest when N, the number of points in the signal
%is a power of 2, and slowest when N is prime.
%Note that there may be considerable variation from run to run.  If you
%want accurate benchmarking numbers, this script should be run a number
%of times to obtain an accurate average.

N_max=1024;%maximum number of points (increase if you have the time)

t_f=zeros(1,N_max);%initialize calculation time vectors
t_s=zeros(1,N_max);

for i=1:N_max;
    if mod(i,10)==0
        fprintf('%d/%d\n',i,N_max);
    end
    N_p=i;
    u1=randn(N_p,1);
    u2=randn(N_p,1);

    %calculate periodic xcorr using fcxcorr
    tic;
    xc_f=fcxcorr(u1,u2);
    t_f(i)=toc;
    
    %calculate periodic xcorr from definition
    tic;
    xc_s=zeros(N_p,1);
    for k=1:N_p
        xc_s(k)=sum(u1.*circshift(u2,k-1));
    end
    t_s(i)=toc;
end

N_primes=primes(N_max);%find primes
N_power2=2.^(1:(log2(N_max)));%find powers of two

figure(1)
h1=semilogy([t_s;t_f]','.');
hold on
h2=semilogy(N_primes,t_f(N_primes),'k.');
h3=semilogy(N_power2,t_f(N_power2),'r.');
hold off
ylabel('t (s)')
xlabel('N')
title('Time to calculate xcorr of two signals of length N')
legend([h1;h2;h3],'Definition','fcxcorr','fcxcorr (primes)','fcxcorr (2^n)','location','northwest')

figure(2)
h1=semilogy([t_s./t_f],'.');
hold on
h2=semilogy(N_primes,t_s(N_primes)./t_f(N_primes),'k.');
h3=semilogy(N_power2,t_s(N_power2)./t_f(N_power2),'r.');
hold off
ylabel('Ratio of speeds (t_s/t_f)')
xlabel('N')
title('Ratio of times to calculate xcorr of two signals of length N')
legend([h1;h2;h3],'All','Primes','2^n','location','southeast')
