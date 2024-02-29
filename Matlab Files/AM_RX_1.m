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
carrier=zeros(1,N,'double');
modulation=zeros(1,N,'double');
AM_time=zeros(1,N,'double');
% carrier data
carrier_freq=600;
carrier_w=2.0*pi*carrier_freq;
carrier_phase=0.0;
Ec=2.4;
% RX carrier
RXcarrier=zeros(1,N,'double');
RXcarrier_freq=600.0;
RXcarrier_w=2.0*pi*RXcarrier_freq;
RXcarrier_phase=0;
EcRX=2.0;

E0=1.0; % DC offset
% 1st modulation data
modulation_freq=45;
modulation_w=2.0*pi*modulation_freq;
modulation_phase=0;
Em=0.333;
% 2nd modulation data
modulation_freq2=15;
modulation_w2=2.0*pi*modulation_freq2;
modulation_phase2=0;
Em2=1.0;
% 3rd modulation data
modulation_freq3=75;
modulation_w3=2.0*pi*modulation_freq3;
modulation_phase3=0;
Em3=0.2;
Conv_Loss=1.0;
% form the signals as a function of time
for i = 1:N
    carrier(i)=Ec*cos(carrier_w*time(i)+carrier_phase);
    RXcarrier(i)=EcRX*cos(RXcarrier_w*time(i)+RXcarrier_phase);
    modulation(i)=E0+Em*cos(modulation_w*time(i)+modulation_phase)+Em2*cos(modulation_w2*time(i)+modulation_phase2)+Em3*cos(modulation_w3*time(i)+modulation_phase3);
    AM_time(i)=modulation(i)*carrier(i)/Conv_Loss;
    RX_time(i)=AM_time(i)*RXcarrier(i)/Conv_Loss;
end;
% FFT to find frequency response
AM_freq=fft(AM_time,N);
AM_mag_freq=zeros(1,N,'double');
for i = 1:N
    AM_mag_freq(i)=abs(AM_freq(i))/(1.0*N);
end;
%
% Receiver Carrier and received signals
RX_freq=fft(RX_time,N);
RX_mag_freq=zeros(1,N,'double');
RX_filtered_freq=zeros(1,N,'double');
RX_mag_filtered_freq=zeros(1,N,'double');
RX_rect_time=zeros(1,N,'double');
RX_rect_freq=zeros(1,N,'double');
RX_rect_filtered_freq=zeros(1,N,'double');
RX_rect_filtered_time=zeros(1,N,'double');
% Low pass filter settings
corner_freq=200.0;
norder=4;
for i = 1:N
    RX_mag_freq(i)=abs(RX_freq(i))/(1.0*N);
    RX_filtered_freq(i)=RX_freq(i)*LPF_Butterworth(freq(i),corner_freq,norder)/(1.0*N);
    RX_mag_filtered_freq(i)=abs(RX_filtered_freq(i));
end;
BB_RX_time=ifft(RX_filtered_freq,N)*(1.0*N);  % o_S(t)
% Rectifier detection
for i = 1:N
    RX_rect_time(i)=abs(AM_time(i));
end;
RX_rect_freq=fft(RX_rect_time,N)/(1.0*N);
for i = 1:N
    RX_rect_filtered_freq(i)=RX_rect_freq(i)*LPF_Butterworth(freq(i),corner_freq,norder);
end;
RX_rect_filtered_time=ifft(RX_rect_filtered_freq,N)*(1.0*N);  % o_R(t)
%
% plot the signals
figure(1);
hold on;
grid on;
title 'Carrier and Modulation Waveforms'
xlabel('Time (sec)')
ylabel('Voltage')
plot(time,carrier)
plot(time,modulation)
legend('Carrier','Modulation')
hold off;
figure(2);
hold on;
grid on;
title 'AM and Rectified Waveforms'
xlabel('Time (sec)')
ylabel('Voltage')
% plot AM signal and the modulation
plot(time,AM_time)
plot(time,modulation)
plot(time,RX_rect_time)
legend('AM signal','Modulation','Rect')
hold off;
%
figure(3);
hold on;
grid on;
title 'AM Spectrum'
xlabel('Freq (Hz)')
xlim([-700, -500]) 
ylabel('|Voltage|')
%ylim([0, 100]) 
stem(freq,AM_mag_freq)
legend('AM')
hold off;
%
figure(5);
hold on;
grid on;
title 'Received Signal Waveform'
xlabel('Time (sec)')
ylabel('Voltage')
% plot AM signal and the modulation
plot(time,RX_time)
plot(time,modulation)
legend('RX signal','Modulation')
hold off;
%
figure(6);
hold on;
grid on;
title 'Received Signal Spectrum'
xlabel('Freq (Hz)')
xlim([-100, 1500]) 
ylabel('|Voltage|')
%ylim([0, 100]) 
plot(freq,RX_rect_freq)
plot(freq,RX_rect_filtered_freq)
legend('RX','RX filtered','Rect','Rect filtered')
legend('Rect','Rect filtered')
hold off;
%
figure(7);
hold on;
grid on;
title 'Output Waveforms'
xlabel('Time (sec)')
ylabel('Voltage')
% plot AM signal and the modulation
plot(time,BB_RX_time)
plot(time,modulation)
plot(time,RX_rect_filtered_time)
legend('o_S(t)','Modulation(t)','o_R(t)')
hold off;


