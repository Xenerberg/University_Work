%This example checks fcxcorr against the definition
N_p=1024;%number of points
u1=randn(N_p,1);%vectors to be compared
SNR=0.5;%signal to noise ratio
u2=u1+1/SNR*randn(N_p,1);%use u1 plus additive Gaussian noise

%calculate xcorr
tic;
xc_f=fcxcorr(u1,u2);
t_f=toc;


%calculate periodic xcorr from definition
tic;
xc_s=zeros(N_p,1);
for k=1:N_p
    xc_s(k)=sum(u1.*circshift(u2,k-1));
end
t_s=toc;

fprintf('%d points\n',N_p);
fprintf('Calculated from definition in %e s\n',t_s);
fprintf('Calculated using fcxcorr in %e s (%f times faster)\n',t_f,t_s/t_f);

figure(1)
plot(0:(N_p-1),xc_f,'x',0:(N_p-1),xc_s,'o')
ylabel('Cross Correlation');
xlabel('Lag (samples)');
legend('fcxcorr','definition')