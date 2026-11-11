clc;
clear;
close all;

%% Parameters

% IM MACHINE PARAMETERS (SI)

% lets say it's Y connceted

P_n = 2.3e3;          % W
V_n = 230;          % V 
%I_n = P_n / (sqrt(3) * V_n);
I_n = 3.6;         % A
f   = 50;           % Hz

p   = 2;            % pole pairs
n_s = 1500;         % rpm
n_n = 1410;         % rpm

R_s = 6.5746;            % Ohm
R_R = 2.106;         % Ohm

L_M     = 0.3354;     % H
L_sig = 0.0416;    % H

J = 0.01;           % kg*m^2
b = 0;

np = p;
% K = 1/sqrt(2); % RMS value scaling
K=1;

% BASE VALUES


P_base = P_n;
f_base = f;
V_base = sqrt(2) * K * (V_n);
I_base = sqrt(2) * K * (I_n); 

w_base = 2*pi*f_base;

psi_base = V_base / w_base;

Z_base = V_base / I_base;
T_base = P_base / w_base*p;

omega_s = 2*pi*n_s/60;

% PER UNIT CONVERSION

% Electrical
R_s_pu = R_s / Z_base;
R_R_pu = R_R / Z_base;

% Inductances (using Z_base and w_base)
L_base = Z_base / w_base;

L_M_pu     = L_M / L_base;
L_sig_pu = L_sig / L_base;

% Mechanical
J_pu = J * w_base^2 / P_base;

% nominal psi and Te
L_sig_n = w_base * L_sig/Z_base;
L_M_n = w_base * L_M/ Z_base;

psi_nominal_pu = sqrt((1 - L_sig_pu^2) / (1 + 2*L_sig_pu/L_M_pu));
psi_nominal = psi_nominal_pu * psi_base;

k = (1 / (1 + 2 * L_sig / L_M)) * sqrt((1 - L_sig_n^2) * ((1 + L_sig / L_M)^2 - (1 / L_M_n^2)));

Te_base = 3*np*V_base*I_base/2/K^2/w_base;
Te_nominal = Te_base * k;

% PLL parameters

trc = 1e-3;
ac = log(9)/trc;

ap = ac / 20;
al = ap * 10;

% E = V_n;
% kpp = 2*ap/E;
% kip = ap*ap/E;

kpp = 2*ap/psi_nominal;
kip= ap*ap/psi_nominal;

wg = 2*pi*f;

% Current controller

R_a = ac*L_sig -(R_s+R_R);
kp = ac*L_sig;
ki = ac*(R_s+R_R+R_a);

% Speed controller
as = ac/10;

b_a = 2*K^2*(as*J-b)/(3*np^2*psi_nominal);
kps = 2*K^2*as*J/(3*np^2*psi_nominal);
kis = 2*K^2*as^2*J/(3*np^2*psi_nominal);

%% ex1

close all;

out = sim('ex1');

time = out.w_r.Time;

psi_dq   = out.psidq.Data / psi_base; 
i_dq_pu  = out.Idq.Data / I_base;
w_m_pu   = out.w_r.Data / w_base;
Te_pu    = out.Te.Data  / Te_nominal;
TL_pu    = out.TL.Data  / Te_nominal;

% Διαχωρισμός
i_d_pu = i_dq_pu(:,1);
i_q_pu = i_dq_pu(:,2);

psi_d_pu = psi_dq(:,1);
psi_q_pu = psi_dq(:,2);

% Μέτρο ρεύματος
i_mag_pu = sqrt(i_d_pu.^2 + i_q_pu.^2);

fig = figure('Color','w');
plot(time, w_m_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed response');
xlim([0 1.3]);
format_and_export(fig, 'ex1.speed.png');

fig = figure('Color','w');
plot(time, Te_pu, 'LineWidth', 2); hold on;
plot(time, TL_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('T / T_{e,N} (pu)');
title('Electromagnetic and Load Torque');
legend('T_e','T_L');
xlim([0 1.3]);
format_and_export(fig, 'ex1.torque.png');

% dq currents

fig = figure('Color','w');
plot(time, i_d_pu, 'LineWidth', 2); hold on;
plot(time, i_q_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Current (pu)');
title('Currents');
legend('i_d','i_q');
xlim([0 1.3]);
format_and_export(fig, 'ex1.idq.png');

% dq flux

fig = figure('Color','w');
plot(time, psi_d_pu, 'LineWidth', 2); hold on;
plot(time, psi_q_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('\psi_r (pu)');
title('Rotor Flux');
legend('\psi_d','\psi_q');
xlim([0 1.3]);
format_and_export(fig, 'ex1.psidq.png');

%% ex2

close all;

out = sim('ex2');

Id_ref = psi_nominal_pu*psi_base/L_M;
Iq_ref = Te_nominal / ((3/2*K^2) * np * psi_nominal_pu*psi_base);

time = out.w_r.Time;

% per unit references
Id_ref_pu = Id_ref / I_base;
Iq_ref_pu = Iq_ref / I_base;

i_dq_pu = out.Idq.Data / I_base;
V_dq_pu = out.Vdq.Data / V_base;
TL_pu   = out.TL.Data / Te_nominal;

% Διαχωρισμός
i_d_pu = i_dq_pu(:,1);
i_q_pu = i_dq_pu(:,2);

v_d_pu = V_dq_pu(:,1);
v_q_pu = V_dq_pu(:,2);

% dq voltages + load torque

fig = figure('Color','w');
plot(time, v_d_pu, 'LineWidth', 2); hold on;
plot(time, v_q_pu, 'LineWidth', 2);
plot(time, TL_pu, 'LineWidth', 2);
ylabel('Voltage (pu) and T_L / T_{e,N} (pu)');
grid on;
xlabel('Time (s)');
title('Voltages and Load Torque');
legend('v_d','v_q','T_L');
xlim([0 0.6]);

format_and_export(fig, 'ex2.vdq.png');

% dq currents with references + load torque

fig = figure('Color','w');
plot(time, i_d_pu, 'LineWidth', 2); hold on;
plot(time, i_q_pu, 'LineWidth', 2);
plot(time, TL_pu, 'LineWidth', 2);
yline(Id_ref_pu, '--', 'LineWidth', 1.5);
yline(Iq_ref_pu, '--', 'LineWidth', 1.5);
ylabel('Current (pu) and T_L / T_{e,N} (pu)');
grid on;
xlabel('Time (s)');
title('Currents with References');
legend('i_d','i_q','T_L', 'i_{d,ref}','i_{q,ref}');
xlim([0 0.6]);
ylim([min(Id_ref_pu, Iq_ref_pu)*0.75 max(Id_ref_pu, Iq_ref_pu)*1.1]);

format_and_export(fig, 'ex2.idq_ref.png');

% i_d rise time

id_10 = 0.1 * Id_ref_pu;
id_90 = 0.9 * Id_ref_pu;

fig = figure('Color','w');
plot(time, i_d_pu, 'LineWidth', 2); hold on;
yline(id_10, '--r', 'LineWidth', 1.5);
yline(id_90, '--r', 'LineWidth', 1.5);
legend('i_d (pu)', '10%', '90%', 'Location','northeast','FontSize',10);
grid on;
xlabel('Time (s)');
ylabel('i_d (pu)');
title('i_d Rise Time');
xlim([0 0.003]);
ylim([0 Id_ref_pu*1.1]);

format_and_export(fig, 'ex2.id_rise.png');

% i_q rise time

iq_10 = 0.1 * Iq_ref_pu;
iq_90 = 0.9 * Iq_ref_pu;

fig = figure('Color','w');
plot(time, i_q_pu, 'LineWidth', 2); hold on;
yline(iq_10, '--r', 'LineWidth', 1.5);
yline(iq_90, '--r', 'LineWidth', 1.5);

legend('i_q (pu)', '10%', '90%', 'Location','northeast','FontSize',10);
grid on;
xlabel('Time (s)');
ylabel('i_q (pu)');
title('i_q Rise Time');
xlim([0 0.003]);
ylim([0 Iq_ref_pu*1.1]);

format_and_export(fig, 'ex2.iq_rise.png');

%% ex3

close all;

out = sim('ex3');

Id_ref = psi_nominal_pu*psi_base/L_M;
Iq_ref = Te_nominal / ((3/2*K^2) * np * psi_nominal_pu*psi_base);

time = out.w_r.Time;

Id_ref_pu = Id_ref / I_base;
Iq_ref_pu = Iq_ref / I_base;

% signals
i_dq_pu = out.Idq.Data / I_base;
V_dq_pu = out.Vdq.Data / V_base;
TL_pu   = out.TL.Data / Te_nominal;

% separation
i_d_pu = i_dq_pu(:,1);
i_q_pu = i_dq_pu(:,2);

v_d_pu = V_dq_pu(:,1);
v_q_pu = V_dq_pu(:,2);

% total voltage magnitude
v_tot_pu = sqrt(v_d_pu.^2 + v_q_pu.^2);

% dq currents + references + load torque

fig = figure('Color','w');
plot(time, i_d_pu, 'LineWidth', 2); hold on;
plot(time, i_q_pu, 'LineWidth', 2);
yline(Id_ref_pu, '--', 'LineWidth', 1.5);
yline(Iq_ref_pu, '--', 'LineWidth', 1.5);
plot(time, TL_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Current (pu) and T_L / T_{e,N} (pu)');
title('Currents with References and Load Torque');
legend('i_d','i_q','i_{d,ref}','i_{q,ref}','T_L');
xlim([0 1]);

format_and_export(fig, 'ex3.idq_ref.png');

% dq voltages + total voltage + load torque

fig = figure('Color','w');
plot(time, v_d_pu, 'LineWidth', 2); hold on;
plot(time, v_q_pu, 'LineWidth', 2);
plot(time, TL_pu, 'LineWidth', 2);
plot(time, v_tot_pu,'--', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Voltage (pu) and T_L / T_{e,N} (pu)');
title('Voltages and Voltage Saturation');
legend('v_d','v_q','T_L','|v_{tot}|');
xlim([0 1]);
ylim([-0.25 1.25]);

format_and_export(fig, 'ex3.vdq_sat.png');

%% ex4

close all;

out = sim('ex4');

Id_ref = psi_nominal_pu*psi_base/L_M;
Iq_ref = Te_nominal / ((3/2*K^2) * np * psi_nominal_pu*psi_base);

time = out.w_r.Time;

% Fluxes
psi_dq      = out.psidq.Data / psi_base;
psi_dq_est  = out.psidq_est.Data / psi_base;

psi_d_pu      = psi_dq(:,1);
psi_q_pu      = psi_dq(:,2);

psi_d_est_pu  = psi_dq_est(:,1);
psi_q_est_pu  = psi_dq_est(:,2);

% Load torque
TL_pu = out.TL.Data / Te_nominal;

% Current references
Id_ref_pu = Id_ref / I_base;
Iq_ref_pu = Iq_ref / I_base;

% Currents
i_dq_pu = out.Idq.Data / I_base;

i_d_pu = i_dq_pu(:,1);
i_q_pu = i_dq_pu(:,2);

% dq rotor flux comparison

fig = figure('Color','w');
plot(time, psi_d_pu, '--', 'LineWidth', 2); hold on;
plot(time, psi_d_est_pu, 'LineWidth', 2);
plot(time, TL_pu, 'LineWidth', 2);
plot(time, psi_q_pu, '--', 'LineWidth', 2);
plot(time, psi_q_est_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('\psi_r (pu) and T_L / T_{e,N} (pu)');
title('Measured and Estimated Rotor Flux');
legend('\psi_d','\psi_{d,est}', ...
       'T_L','\psi_q','\psi_{q,est}');
xlim([0 1]);
format_and_export(fig, 'ex4.psidq_est.png');

% dq currents with references
fig = figure('Color','w');
plot(time, i_d_pu, 'LineWidth', 2); hold on;
plot(time, i_q_pu, 'LineWidth', 2);
plot(time, TL_pu, 'LineWidth', 2);
yline(Id_ref_pu, '--', 'LineWidth', 1.5);
yline(Iq_ref_pu, '--', 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('Current (pu) and T_L / T_{e,N} (pu)');
title('Currents with References');
legend('i_d','i_q','T_L', ...
       'i_{d,ref}','i_{q,ref}');
xlim([0 1]);

format_and_export(fig, 'ex4.idq_ref.png');

%% ex5
close all;

out = sim('ex5');

time = out.w_r.Time;

% Create a uniform time vector to bridge gaps/NaNs at discontinuities
t_fixed = linspace(time(1), time(end), length(time));

% Speeds
w_r_pu     = out.w_r.Data / w_base;
w_ref_pu   = out.w_ref.Data / w_base;
% Torque (INTERPOLATED)
Te_pu = interp1(time, out.Te.Data / Te_nominal, t_fixed);
% Current references
Id_ref = psi_nominal_pu*psi_base/L_M;
Iq_ref = Te_nominal / ((3/2*K^2) * np * psi_nominal_pu*psi_base);
Id_ref_pu = Id_ref / I_base;
% dq currents (INTERPOLATED)
i_dq_raw = out.Idq.Data / I_base;
i_d_pu = interp1(time, i_dq_raw(:,1), t_fixed);
i_q_pu = interp1(time, i_dq_raw(:,2), t_fixed);
% iq reference from speed controller (INTERPOLATED)
iq_ref_raw = out.Idq_ref.Data / I_base;
iq_ref_pu = interp1(time, iq_ref_raw(:,2), t_fixed);

% Speed response
fig = figure('Color','w');
plot(time, w_r_pu, 'LineWidth',2); hold on;
plot(time, w_ref_pu, '--', 'LineWidth',2);
grid on;
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Response');
legend('\omega_r','\omega_{ref}');
xlim([0 1]);

format_and_export(fig,'ex5.speed.png');

% Torque response
fig = figure('Color','w');
plot(t_fixed, Te_pu, 'LineWidth',2); % Using fixed time
grid on;
xlabel('Time (s)');
ylabel('Torque (pu)');
title('Electromagnetic Torque');
legend('T_e');
xlim([0 1]);

format_and_export(fig,'ex5.torque.png');

% dq currents and references
fig = figure('Color','w');
plot(t_fixed, i_d_pu, 'LineWidth',2); hold on;
plot(t_fixed, i_q_pu, 'LineWidth',2);
plot(t_fixed, Id_ref_pu*ones(size(t_fixed)), '--','LineWidth',1.5);
plot(t_fixed, iq_ref_pu, '--','LineWidth',1.5);
grid on;
xlabel('Time (s)');
ylabel('Current (pu)');
title('Current and Reference');
legend('i_d','i_q','i_{d,ref}','i_{q,ref}');
xlim([0 1]);

format_and_export(fig,'ex5.idq.png');

% Speed rise time with saturation
w10 = 0.1 * max(w_ref_pu);
w90 = 0.9 * max(w_ref_pu);
fig = figure('Color','w');
plot(time, w_r_pu, 'LineWidth',2); hold on;
yline(w10,'--r','LineWidth',1.5);
yline(w90,'--r','LineWidth',1.5);
grid on;
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Rise Time with Saturation');
legend('\omega_r','10%','90%','Location','northeast');
xlim([0 0.4]);

format_and_export(fig,'ex5.speed_rise_sat.png');
%% ex5 no sat
% Speed rise time without saturation
% Use logs from simulation without saturation

close all;

Id_ref = psi_nominal_pu*psi_base/L_M;

out = sim('ex5_2');

time = out.w_r.Time;

w_r_nosat_pu   = out.w_r.Data / w_base;
w_ref_nosat_pu = out.w_ref.Data / w_base;
w10_nosat = 0.1 * max(w_ref_nosat_pu);
w90_nosat = 0.9 * max(w_ref_nosat_pu);
fig = figure('Color','w');
plot(time, w_r_nosat_pu, 'LineWidth',2); hold on;
yline(w10_nosat,'--r','LineWidth',1.5);
yline(w90_nosat,'--r','LineWidth',1.5);
grid on;
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Rise Time without Saturation');
legend('\omega_r','10%','90%','Location','northeast');
xlim([0 0.04]);
ylim([0 2]);

format_and_export(fig,'ex5.speed_rise_nosat.png');