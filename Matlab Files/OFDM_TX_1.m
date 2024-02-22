% MatLab script to simulate AM with single frequency modulation 
mm=12;
N=2^mm;          % number of points in FFT/IFFT calculations
df = 2.5;        % frequency spacing of samples for FFT/IFFT
dt=1.0/(df*N);   % time spacing of samples for FFT/IFFT
fprintf('m=%d, N=%d, dt=%12g, df=%12g\n',mm,N,dt,df)
time=zeros(1,N,'double');   % array to hold time samples
freq=zeros(1,N,'double');   % array to hold frequency samples
for i = 1:N
    time(i)=dt*(i-1);   % populate the time samples at spacing dt
end;
for i =1:floor(N/2)
    freq(i)=df*(i-1);   % populate bottom half of freq samples at spacing df
end;
for i =2:floor(N/2)
    ii=N-i;
    freq(ii)=-df*(i+1); % populate top half of freq samples at spacing df
end;
no=2    %array index offset for negative frequency portion
TXsignal_time=complex(zeros(1,N,'double'));
BBsignal_spectrum=complex(zeros(1,N,'double'));
BBsignal_time=complex(zeros(1,N,'double'));
ICarrier_time=zeros(1,N,'double');
QCarrier_time=zeros(1,N,'double');
Carrier_omega=2.0*pi*300*df;
Ec=1.0;
for i = 1:N
    ICarrier_time(i)=Ec*cos(Carrier_omega*time(i));   % populate the time samples at spacing dt
    QCarrier_time(i)=Ec*sin(Carrier_omega*time(i));   % populate the time samples at spacing dt
end;

BBsignal_spectrum(1)=complex(0.0,1.0);
BBsignal_spectrum(11)=complex(0.0,1.0);
BBsignal_spectrum(21)=complex(0.0,0.0);
BBsignal_spectrum(31)=complex(1.0,1.0);
BBsignal_spectrum(N+no-11)=complex(0.0,1.0);
BBsignal_spectrum(N+no-21)=complex(0.0,0.0);
BBsignal_spectrum(N+no-31)=complex(1.0,1.0);

%BBsignal_spectrum(1)=complex(-7.0,3.0);
% BBsignal_spectrum(11)=complex(3.0,1.0);
% BBsignal_spectrum(21)=complex(1.0,3.0);
% BBsignal_spectrum(31)=complex(1.0,3.0);
% BBsignal_spectrum(41)=complex(7.0,3.0);
% BBsignal_spectrum(N+no-11)=complex(3.0,1.0);
% BBsignal_spectrum(N+no-21)=complex(1.0,3.0);
% BBsignal_spectrum(N+no-31)=complex(1.0,3.0);
% BBsignal_spectrum(N+no-41)=complex(7.0,3.0);


% mod_ampl=1.0
% mod_phase=0.0*(2.0*pi);
% rrr=mod_ampl*cos(mod_phase);
% iii=mod_ampl*sin(mod_phase);
% BBsignal_spectrum(31)=complex(rrr,iii);
% BBsignal_spectrum(N+no-31)=complex(rrr,-iii);
% BBsignal_spectrum(1)=complex(4.0,0.0);

f0=freq(11);
T0=1.0/f0;
BBsignal_time=ifft(BBsignal_spectrum)*N;
for i = 1:N
    BBsignal_re(i)=real(BBsignal_time(i));
    BBsignal_im(i)=imag(BBsignal_time(i));
 end;
for i = 1:N
    ITXsignal(i)=ICarrier_time(i)*BBsignal_re(i);  
    QTXsignal(i)=QCarrier_time(i)*BBsignal_im(i); 
    TXsignal_tot(i)=ITXsignal(i)+QTXsignal(i);   
    TXsignal_tot_re(i)=real(TXsignal_tot(i));
    TXsignal_tot_im(i)=imag(TXsignal_tot(i));
end;

TXsignal_spectrum=fft(TXsignal_tot)/N;

figure(1);
hold on;
grid on;
title 'Baseband Spectrum'
xlabel('Freq (Hz)')
xlim([-75*df, 75*df]) 
ylabel('|Voltage|')
%ylim([0, 100]) 
stem(freq,abs(BBsignal_spectrum))
hold off;
%
figure(2);
hold on;
grid on;
title 'Baseband Waveforms'
xlabel('Time (sec)')
xlim([0, T0]);
ylabel('Voltage')
% plot AM signal and the modulation
plot(time,BBsignal_re)
plot(time, BBsignal_im)
legend('BB_I(t)','BB_Q(t)','Location','best' )
hold off;

figure(3);
hold on;
grid on;
title 'Transmit Waveforms'
xlabel('Time (sec)')
xlim([0, 3*T0]);
ylabel('Voltage')
% plot AM signal and the modulation
plot(time,TXsignal_tot_re)
%plot(time, TXsignal_tot_im)
legend('OFDM signal(t)','Location','best' )
hold off;
%
figure(4);
hold on;
grid on;
title 'TX Spectrum'
xlabel('Freq (Hz)')
xlim([600,900]) 
ylabel('|Voltage|')
%ylim([0, 100]) 
stem(freq,abs(TXsignal_spectrum))
hold off;
