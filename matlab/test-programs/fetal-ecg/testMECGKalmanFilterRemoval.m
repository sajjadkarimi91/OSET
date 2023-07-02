% Test program for maternal ECG cancellation using EKF and EKS
%
% Dependencies: The baseline wander and ECG filtering toolboxes of the Open Source ECG Toolbox
%
% Sample code for testing naive maternal template subtraction technique
%
% Reza Sameni (C)
% Email: rsameni@shirazu.ac.ir
% Web: www.sameni.info
%
% Crated 2006
% Modified June 2018


clc;
clear;
close all;
load('SampleFECGDaISy');
data = cell2mat(data);
mref = data(8, :);
data = data(1, :); 
fs = cell2mat(fs);
% % % load('SampleECG2.mat'); data = data(1:15000,2)';

t = (0:length(data)-1)/fs;

f = 1.0;                                          % approximate R-peak frequency
bsline = LPFilter(data,.7/fs);                  % baseline wander removal (may be replaced by other approaches)
%bsline = BaseLineKF(data,.5/fs);                % baseline wander removal (may be replaced by other approaches)

s = data - bsline;

%//////////////////////////////////////////////////////////////////////////
% Making the data noisy
SNR = 15;
SignalPower = mean(s.^2);
NoisePower = SignalPower / 10^(SNR/10);
% x = s + sqrt(NoisePower)*randn(size(s));
% % % x =  s + [NoiseGenerator(5,SignalPower,SNR,length(s),fs,[0 1 1],0)]';
x = s + NoiseGenerator(1,SignalPower,SNR,length(s),fs,1,0)';
%//////////////////////////////////////////////////////////////////////////
% bslinex = LPFilter(x,.7/fs);                  % baseline wander removal (may be replaced by other approaches)
% x = x - bslinex;
%//////////////////////////////////////////////////////////////////////////

peaks = PeakDetection(mref, f/fs);                  % peak detection
I = find(peaks);

figure;
plot(t,x);
hold on;
plot(t(I),x(I).*peaks(I),'ro');
plot(t,s,'r');
grid


[phase, phasepos] = PhaseCalculation(peaks);     % phase calculation

teta = 0;                                       % desired phase shift
pphase = PhaseShifting(phase,teta);             % phase shifting

bins = 250;                                     % number of phase bins
[ECGmean,ECGsd,meanphase] = MeanECGExtraction(x,pphase,bins,1); % mean ECG extraction


ECGBeatFitter(ECGmean,ECGsd,meanphase,'OptimumParams');           % ECG beat fitter GUI

%//////////////////////////////////////////////////////////////////////////
N = length(OptimumParams)/3;% number of Gaussian kernels
JJ = find(peaks);
fm = fs./diff(JJ);          % heart-rate
w = mean(2*pi*fm);          % average heart-rate in rads.
wsd = std(2*pi*fm,1);       % heart-rate standard deviation in rads.

y = [phase ; x];

X0 = [-pi 0]';
P0 = [(2*pi)^2 0 ;0 (10*max(abs(x))).^2];
Q = diag( [ (.1*OptimumParams(1:N)).^2 (.05*ones(1,N)).^2 (.05*ones(1,N)).^2 (wsd)^2 , (.05*mean(ECGsd(1:round(length(ECGsd)/10))))^2] );
%Q = diag( [ (.5*OptimumParams(1:N)).^2 (.2*ones(1,N)).^2 (.2*ones(1,N)).^2 (wsd)^2 , (.2*mean(ECGsd(1:round(end/10))))^2] );
R = [(w/fs).^2/12 0 ;0 (mean(ECGsd(1:round(length(ECGsd)/10)))).^2];
Wmean = [OptimumParams w 0]';
Vmean = [0 0]';
Inits = [OptimumParams w fs];

InovWlen = ceil(.5*fs);     % innovations monitoring window length
tau = [];                   % Kalman filter forgetting time. tau=[] for no forgetting factor
gamma = 1;                  % observation covariance adaptation-rate. 0<gamma<1 and gamma=1 for no adaptation
RadaptWlen = ceil(fs/2);    % window length for observation covariance adaptation

[Xekf, Phat, Xeks, PSmoothed, ak] = EKSmoother(y,X0,P0,Q,R,Wmean,Vmean,Inits,InovWlen,tau,gamma,RadaptWlen,1);

%//////////////////////////////////////////////////////////////////////////
% Likelihood ellipse
DF = zeros(size(PSmoothed));
DS = zeros(size(Phat));
for i = 100:length(PSmoothed)-100
    [V, DS(:,:,i)] = eig(squeeze(PSmoothed(:,:,i)));
    [V, DF(:,:,i)] = eig(squeeze(Phat(:,:,i)));
end

DF = sqrt(DF);  DF1 = squeeze(DF(1,1,100:end-100))'; DF2 = squeeze(DF(2,2,100:end-100))';
DS = sqrt(DS);  DS1 = squeeze(DS(1,1,100:end-100))'; DS2 = squeeze(DS(2,2,100:end-100))';

Xekf = Xekf(2,:);
Phat = squeeze(Phat(2,2,:))';
Xeks = Xeks(2,:);
PSmoothed = squeeze(PSmoothed(2,2,:))';

%//////////////////////////////////////////////////////////////////////////
% plot results

figure;
plot(DF1-mean(DF1),DF2-mean(DF2),'bo');
hold on;
plot(DS1-mean(DS1),DS2-mean(DS2),'ro');
grid;

figure
plot(t,x);
hold on;
plot(t,Xekf','g');
plot(t,Xeks','r');
plot(t,s,'m');
grid;
legend('Noisy','EKF Output','EKS Output','Original ECG');

figure
plot(t,x);
hold on;
plot(t,Xekf','g','linewidth',3);
plot(t,s,'r','linewidth',2);
grid;
plot(t,Xekf+sqrt(Phat),'c','linewidth',1);
plot(t,Xekf+3*sqrt(Phat),'m','linewidth',1);
legend('Noisy','EKF Output','Original ECG','\sigma envelope','3\sigma envelope');
plot(t,Xekf-sqrt(Phat),'c','linewidth',1);
plot(t,Xekf-3*sqrt(Phat),'m','linewidth',1);

figure
plot(t,x);
hold on;
plot(t,Xeks','g','linewidth',3);
plot(t,s,'r','linewidth',2);
grid;
plot(t,Xeks+sqrt(PSmoothed),'c','linewidth',1);
plot(t,Xeks+3*sqrt(PSmoothed),'m','linewidth',1);
legend('Noisy','EKS Output','Original ECG','\sigma envelope','3\sigma envelope');
plot(t,Xeks-sqrt(PSmoothed),'c','linewidth',1);
plot(t,Xeks-3*sqrt(PSmoothed),'m','linewidth',1);

figure
plot(t,x);
hold on;
plot(t,x - Xeks,'g','linewidth',1);
plot(t,x - Xekf,'r','linewidth',1);
grid;
legend('Noisy', 'EKS', 'EKF');
title('MECG Cancellation');
xlabel('time (s)');
ylabel('Amplitude');

%//////////////////////////////////////////////////////////////////////////
% performance evaluation

I1 = find(s > (Xekf+sqrt(Phat)));
I2 = find(s < (Xekf-sqrt(Phat)));
P1sigma_EKF = 100*(1-(length(I1)+length(I2))/length(s))

I1 = find(s > (Xekf+2*sqrt(Phat)));
I2 = find(s < (Xekf-2*sqrt(Phat)));
P2sigma_EKF = 100*(1-(length(I1)+length(I2))/length(s))

I1 = find(s > (Xekf+3*sqrt(Phat)));
I2 = find(s < (Xekf-3*sqrt(Phat)));
P3sigma_EKF = 100*(1-(length(I1)+length(I2))/length(s))

I1 = find(s > (Xeks+sqrt(PSmoothed)));
I2 = find(s < (Xeks-sqrt(PSmoothed)));
P1sigma_EKS = 100*(1-(length(I1)+length(I2))/length(s))

I1 = find(s > (Xeks+2*sqrt(PSmoothed)));
I2 = find(s < (Xeks-2*sqrt(PSmoothed)));
P2sigma_EKS = 100*(1-(length(I1)+length(I2))/length(s))

I1 = find(s > (Xeks+3*sqrt(PSmoothed)));
I2 = find(s < (Xeks-3*sqrt(PSmoothed)));
P3sigma_EKS = 100*(1-(length(I1)+length(I2))/length(s))

EKFsnr = 10*log10(mean(s.^2)/mean((s-Xekf).^2))
EKSsnr = 10*log10(mean(s.^2)/mean((s-Xeks).^2))