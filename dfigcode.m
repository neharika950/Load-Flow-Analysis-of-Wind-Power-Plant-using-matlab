
close all
clear all
clc


%% DFIG Parameters --> Rotor reffered to the stator 

f = 50;                          % stator frequency (Hz)
Ps = 2e6;                        % 2MW rated stator power (W)
n = 1500;                        % rated rotational speed (rev/min) 
Vs = 690;                        % rated stator voltage (V)
Is = 1760;                       % rated stator current (A)
Tem = 12732;                     % rated torque (Nm)

p = 2;                           % pole pair
u = 1/3;                         % stator/rotor turns ratio
Vr = 2070;                       % rated rotor voltage (non-reached) (V)
smax = 1/3;                      % maximum torque
Vr_stator = (Vr*smax)*u;         % rated rotor voltage referred to stator
Rs = 2.6e-3;                     % stator resistance (ohm)
Lsi = 0.087e-3;                  % leakage inductance (stator & rotor) (H)
Lm = 2.5e-3;                     % magnetizing inductance
Rr = 2.9e-3;                     % rotor resistance referred to stator(ohm)
Ls = Lm + Lsi;                   % stator inductance (H)
Lr = Lm + Lsi;                   % rotor inductance (H)
Vbus = 1150;        % DC de bus voltage referred to stator (V)
sigma = 1 - Lm^2/(Ls*Lr);
Fs = Vs*sqrt(2/3)/(2*pi*f);      % stator flux (approx.) (Wb)

J = 127/2;                       % inertia
D = 1e-3;                        % damping
 
fsw = 4e3;                       % switching frequency (Hz)
Ts = 1/fsw/50;                   % sampling time(seconds)

%% PI REGULATORS

tau_i = (sigma*Lr)/Rr;
tau_n = 0.05;
wni = 100*(1/tau_i);
wnn = 1/tau_n;

kp_id = (2*wni*sigma*Lr)-Rr;
kp_iq = kp_id;
ki_id = (wni^2)*Lr*sigma;
ki_iq = ki_id;
kp_n = (2*wnn*J)/p;
ki_n = ((wnn^2)*J)/p;

%% Three blade wind turbine model

N = 100;                       % gearbox ratio
Radio = 42;                    % radio
ro = 1.225;                    % air density

%% Cp and Ct curves

beta = 0;                      % pitch angle
ind2 = 1;                      

  for lambda=0.1:0.01:11.8

      lambdai(ind2) = (1./((1./(lambda-0.02.*beta)+(0.003./(beta^3+1)))));
      Cp(ind2) = 0.73.*(151./lambdai(ind2)-0.58.*beta-0.002.*beta^2.14-13.2).*(exp(-18.4./lambdai(ind2)));
      Ct(ind2) = Cp(ind2)/lambda;
      ind2=ind2+1;
  end
  tab_lambda=(0.1:0.01:11.8);

%% Kopt for MPPT
Cp_max = 0.44;
lambda_opt = 7.2;
Kopt = ((0.5*ro*pi*(Radio^5)*Cp_max)/(lambda_opt^3));

%% Power curve in function of wind speed(2.4MW wind turbine)

P = 1.0e+06 *[0,0,0,0,0,0,0,0.0472,0.1097,0.1815,0.2568,0.3418,...
    0.4437,0.5642,0.7046,0.8667,1.0518,1.2616,1.4976,1.7613,2.0534,...
    2.3513,2.4024,2.4024,2.4024,2.4024,2.4024,2.4024];
V = [0.0000,0.5556,1.1111,1.6667,2.2222,2.7778,3.3333,3.8889,4.4444,...
    5.0000,5.5556,6.1111,6.6667,7.2222,7.7778,8.3333,8.8889,9.4444,...
    10.0000,10.5556,11.1111,11.6667,12.2222,12.7778,13.3333,13.8889,...
    14.4444,15.0000];

figure
subplot(1,2,1)
plot(tab_lambda,Ct,'linewidth',1.5)
xlabel('lambda','FontSize',14)
ylabel('Ct','FontSize',14)
subplot(1,2,2)
plot(V,P,'linewidth',1.5)
grid
xlabel('Windspeed (m/s)','fontsize',14)
ylabel('Power (W)','FontSize',14)

%% Grid side converter
Cbus = 80e-3;         % DC bus capacitance
Rg = 20e-6;           % Grid side filter's resistance
Lg = 400e-6;          % Grid side filter's inductance

Kpg = 1/(1.5*Vs*sqrt(2/3));
Kqg = -Kpg;

% PI regulators
tau_ig = Lg/Rg;
wnig = 60*2*pi;

Kp_idg = (2*wnig*Lg)-Rg;
Kp_iqg = Kp_idg;
Ki_idg = (wnig^2)*Lg;
Ki_iqg = Ki_idg;

Kp_v = -1000;
Ki_v = -300000;




