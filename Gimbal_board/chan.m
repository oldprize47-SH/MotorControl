clear; close all; clc;

% =========================== DATA Load ==========================
addpath(".\gimbal_Gyro_modeling\");
FileLength = 12;
Fs = 0.1;
FreqStart = 0.1;
DATA = cell(FileLength,1);

for k = 1:FileLength
    FileName = sprintf("chan_modeling_%.4fHz_data.out", (k-1)*Fs + FreqStart);
    DATA{k} = load(FileName);
end

DEAD = 2.51;
N_VOL = length(DATA{1});

% fitting Function
Vcmd1 = [0.0, 2.47];
W1 = [-1300, -45];
Vc_W1 = fit(Vcmd1', W1', 'poly1');

Vcmd2 = [2.53, 5.0];
W2 = [45, 1300];
Vc_W2 = fit(Vcmd2', W2', 'poly1');

% ================== acquishing estimate coefficient ======================
% initialize 
Vout0 = 0.0;
InValidN = 400;
eMag = zeros(FileLength+1,1); % +1
ePhs = zeros(FileLength+1,1); % +1
eBias = zeros(FileLength,1);
eVout = zeros(N_VOL- InValidN,FileLength);
Vin = zeros(N_VOL - InValidN,FileLength);
freq = zeros(FileLength+1,1);   % +1
x0 = [300, 0, Vout0];
Gm = zeros(FileLength+1, 1);  % +1
mag_in = zeros(FileLength, 1);

% Main loop
for i = 1: FileLength
    time = DATA{i}(InValidN:N_VOL-1,1);
    V_in = DATA{i}(InValidN:N_VOL-1,2);
    W    = DATA{i}(InValidN:N_VOL-1,3);
    
    freq(i+1) = (i-1)*Fs + FreqStart;
    SysResp = @(x, t) x(1) * cos(2*pi*freq(i+1)*t + x(2)) + x(3);
    
    x = lsqcurvefit(SysResp, x0, time, W);
    
    eMag(i+1) = x(1);
    ePhs(i+1) = x(2);
    eBias(i) = x(3);
    eVout(:, i) = eMag(i+1)*cos(2*pi*freq(i+1)*time+ePhs(i+1))+eBias(i);

    % mag_in(i) = (max(V_in)-min(V_in))/2;
    Gm(i+1) = eMag(i+1)/0.5;
end

% Estimated 0[Hz] answer
eMag(1) = eMag(2) - (eMag(3)-eMag(2))*0.5;
Gm(1) = Gm(2) - (Gm(3)-Gm(2))/2;

Ndata = FileLength;
figure; plot(time, Vin(:,Ndata), time, eVout(:, Ndata));

tdFreqSys = Gm.*exp(1i*ePhs);
[num, den] = invfreqs(tdFreqSys, freq*2*pi, 1, 2);
[num1, den1] = invfreqs(tdFreqSys, freq*2*pi, 0, 1);

Gp2 = tf(num, den)
Gp1 = tf(num1, den1)

bode(Gp2, Gp1);
pzmap(Gp2, Gp1);
grid on; 
legend ("1 Zero & 2 Poles", "1 Pole", Location = 'best');

[Mag, Phs, Wout] = bode(Gp2);
[Mag1, Phs1, Wout1] = bode(Gp1);

N = length(Mag);
Mag_plot = squeeze(Mag(1, 1, :));
Phs_plot = squeeze(Phs(1, 1, :));
Mag1 = squeeze(Mag1(1,1,:));
Phs1 = squeeze(Phs1(1,1,:));

figure(); hold on;
title("Bode Plot");
subplot(2,1,1); hold on; grid on; box on;
plot(log10(freq*2*pi), db(Gm));
plot(log10(Wout), db(Mag_plot));
plot(log10(Wout1), db(Mag1));
legend("True Value", "1 Zero & 2 Poles", "1 Pole",  Location='best');
xlabel('log_{10}Frequency [rad/s]'); ylabel("Magnitude [dB]"); %xlim([0 1]);

subplot(2, 1, 2); hold on; grid on; box on;
plot(log10(freq*2*pi), ePhs*180/pi);
plot(log10(Wout), Phs_plot);
plot(log10(Wout1), Phs1);
legend("True Value", "1 Zero & 2 Poles", "1 Pole", Location='best');
xlabel('log_{10}Frequency [rad/s]'); ylabel("Phase [deg]"); %xlim([0 1]);

% =============================== Simulation Parameter ===============================
Tstart = 0.0;
Tend = 20.0;
Fs = 200;
Ts = 1/Fs;
addpath("..\simulink\");

% DATA initiation
dataNum = 4;
time_sim = Tstart:Ts:Tend;
% freq(dataNum)
func = @(t) 0.5*cos(freq(dataNum)*2*pi*t);
cosData = nan(length(time_sim),1);

cosData = func(time_sim);

DataIn = [time_sim', cosData'];

[NUM_P, DEN_P] = tfdata(Gp1, 'v');
out = sim('Plant.slx');

[NUM_P, DEN_P] = tfdata(Gp2, 'v');
out2 = sim('Plant.slx');

figure; plot(DATA{dataNum-1}(:,1), DATA{dataNum-1}(:,3), '.b', out.tout, out.Wout,'r', out2.tout, out2.Wout, 'g', LineWidth = 1.5);
grid on; legend("True", "Gp1", "Gp2");