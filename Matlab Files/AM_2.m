% MatLab script to simulate AM with single frequency modulation
clear all
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
ic=carrier_freq/df
carrier_w=2.0*pi*carrier_freq;
carrier_phase=0.0;
Ec=1.9;
% modulation data
modulation_freq=45;
ima=modulation_freq/df
modulation_w=2.0*pi*modulation_freq;
modulation_phase=pi/2.0  %8.0*pi/16.0;
Em=0.333;
E0=1.00;
% 2nd modulation data
modulation_freq2=15;
imb=modulation_freq2/df
modulation_w2=2.0*pi*modulation_freq2;
modulation_phase2=pi/2.0  %8.0*pi/16.0;
Em2=1.0;
% 3rd modulation data
modulation_freq3=75;
imc=modulation_freq3/df
modulation_w3=2.0*pi*modulation_freq3;
modulation_phase3=pi/2.0  %8.0*pi/16.0;
Em3=0.2;
Conv_Loss=1.0;
% form the signals as a function of time
for i = 1:N
    carrier(i)=Ec*cos(carrier_w*time(i)+carrier_phase);
    modulation(i)=E0+Em*cos(modulation_w*time(i)+modulation_phase)+Em2*cos(modulation_w2*time(i)+modulation_phase2)+Em3*cos(modulation_w3*time(i)+modulation_phase3);
    AM_time(i)=modulation(i)*carrier(i)/Conv_Loss;
end;

% AM Power
R = 50; % Ohms
AM_Power = (AM_time.^2) / R; % Power in Watts V^2/R
% Peak Envelope Power
PEP = max(AM_Power)/2 % Divided by 2 to get the RMS value
% Peak to Average Power Ratio
PAPR = PEP/mean(AM_Power)

% FFT to find frequency response
AM_freq=fft(AM_time,N);
AM_mag_freq=zeros(1,N,'double');
for i = 1:N
    AM_mag_freq(i)=abs(AM_freq(i))/(1.0*N);
end;
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
%
figure(2);
hold on;
grid on;
title 'AM Waveform'
xlabel('Time (sec)')
ylabel('Voltage')
% plot AM signal and the modulation
plot(time,AM_time)
plot(time,modulation)
legend('AM signal','Modulation')
% Remove comment to add 'envelopes' of the signal
% plot(time,2.0*modulation)
% plot(time,-2.0*modulation)
% legend('AM signal','Modulation','Envelope','- Envelope')
hold off;
%
figure(3);
hold on;
grid on;
title 'AM Spectrum'
xlabel('Freq (Hz)')
xlim([500, 700]) 
ylabel('|Voltage|')
%ylim([0, 100]) 
stem(freq,AM_mag_freq)
legend('AM')
hold off;

