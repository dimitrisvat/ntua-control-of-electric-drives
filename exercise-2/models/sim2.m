clc;
clear;
close all;

%% ex1

% IM MACHINE PARAMETERS (SI)

% lets say it's Y connceted

P_n = 5e3;          % W
V_n = 400;          % V (line-line assumed)
I_n = P_n / (sqrt(3) * V_n);
%I_n = 7.22;         % A
f   = 50;           % Hz

p   = 2;            % pole pairs
n_s = 1500;         % rpm
n_n = 1450;         % rpm
w_n = n_s*2*pi/60; 
s   = (n_s-n_n)/n_s;% slip

R_s = 1;            % Ohm
R_R = 0.45;         % Ohm

L_M     = 0.20;     % H
L_sig = 0.025;    % H

T_n = 32.92;        % Nm

J = 0.05;           % kg*m^2
b = 0.001;          % Nms

np = p;
K = 1/sqrt(2); % RMS value scaling
% K=1;

%% BASE VALUES


P_base = P_n;
f_base = f;
V_base = sqrt(2) * K * (V_n/sqrt(3));
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
T_n_pu = T_n / T_base;

J_pu = J * w_base^2 / P_base;
b_pu = b / (P_base / w_base);

% Mechanical speeds (optional p.u.)
n_s_pu = n_s / (120*f/p);
n_n_pu = n_n / n_s;

s_pu = s;


% nominal psi and Te
L_sig_n = w_base * L_sig/Z_base;
L_M_n = w_base * L_M/ Z_base;

psi_nominal_pu = sqrt((1 - L_sig_n^2) / (1 + 2*L_sig/L_M));
psi_nominal_pu = sqrt((1 - L_sig_pu^2) / (1 + 2*L_sig_pu/L_M_pu));

k = (1 / (1 + 2 * L_sig / L_M)) * sqrt((1 - L_sig_n^2) * ((1 + L_sig / L_M)^2 - (1 / L_M_n^2)));

Te_base = 3*np*V_base*I_base/2/K^2/w_base;
Te_nominal = Te_base * k;

%% ex3 - Torque & Current vs rotor speed

% Supply voltage (phase RMS)
V_s = V_n / sqrt(3);

% Electrical frequency
w1 = 2*pi*f;

% Rotor angular speed
w_vec = linspace(0, w1, 1000);
w_r_pu = w_vec / w1;

% Slip
s = (w1 - w_vec) ./ w1;

X_sig = w1 * L_sig;
s_p = R_R / X_sig;

% Current
is_mag = s .* V_s ./ (s_p .* X_sig .* sqrt((s./s_p).^2 + 1));
is_mag_pu = is_mag / I_base;

% Torque
Te = (3*np/(2*K^2)) * (s/(w1*R_R)) .* (V_s^2 ./ (((s .* X_sig / R_R).^2) + 1));
Te_pu = Te / T_base;

% Plot Current
fig = figure('Color', 'w'); 
plot(w_r_pu, is_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Rotor speed (pu)');
ylabel('|i_s| (pu)');
title('Stator Current vs Rotor Speed');

% format_and_export(fig, 'ex3.current.png');

% Plot Torque
fig = figure('Color', 'w'); 
plot(w_r_pu, Te_pu, 'LineWidth', 2);
grid on;
xlabel('Rotor speed (pu)');
ylabel('Torque (pu)');
title('Electromagnetic Torque vs Rotor Speed');

%format_and_export(fig, 'ex3.torque.png');

%% ex4
time = out.psi_mag.Time;

psi_mag_pu = out.psi_mag.Data / psi_base;
i_mag_pu   = out.i_mag.Data   / I_base;
w_m_pu     = out.w_m.Data     / w_base * np;
Te_pu      = out.Te.Data      / T_base;

fig = figure('Color','w');
plot(time, w_m_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('\omega_m (pu)');
title('Rotor Speed');
xlim([0 1.3]);

format_and_export(fig, 'ex4.speed.png');

fig = figure('Color','w');
plot(time, Te_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque');
xlim([0 1.3]);

format_and_export(fig, 'ex4.torque.png');

fig = figure('Color','w');
plot(time, psi_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|ψ_r| (pu)');
title('Rotor Flux Magnitude');
xlim([0 1.3]);

format_and_export(fig, 'ex4.psi.png');

fig = figure('Color','w');
plot(time, i_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|i_s| (pu)');
title('Stator Current Magnitude');
xlim([0 1.3]);

format_and_export(fig, 'ex4.current.png');


% clark

time = out.vabc.Time;

vabc_data = out.vabc.Data;
va = vabc_data(:,1) / V_base;
vb = vabc_data(:,2) / V_base;
vc = vabc_data(:,3) / V_base;

vab0_data = out.vab0.Data;
v_alpha = vab0_data(:,1) / V_base;
v_beta = vab0_data(:,2) / V_base;


% Plot abc (before)
fig = figure('Color','w');
plot(time, va, 'LineWidth', 1.5); hold on;
plot(time, vb, 'LineWidth', 1.5);
plot(time, vc, 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('Voltage (pu)');
title('Three-Phase Voltages (abc)');
legend('v_a','v_b','v_c');
xlim([0 0.05]);

format_and_export(fig, 'ex4.clark_abc.png');

% Plot alpha-beta (after)
fig = figure('Color','w');
plot(time, v_alpha, 'LineWidth', 2); hold on;
plot(time, v_beta, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Voltage (pu)');
title('Clarke Transform (αβ frame)');
legend('v_\alpha','v_\beta');
xlim([0 0.05]);

format_and_export(fig, 'ex4.clark_alphabeta.png');

%% ex5

% Simulation parameters
dt = 1e-5;         
t_end = 0.8;      
t = 0:dt:t_end;

% Initialization
T_L = 0;         
w_r = 0; 
w_m = 0;
w_r_vec = zeros(size(t));
Te_vec = zeros(size(t));
is_vec = zeros(size(t));

for k = 1:length(t)

    % Interpolation
    Te_interp = interp1(w_vec, Te, w_r, 'linear');
    is_interp = interp1(w_vec, is_mag, w_r, 'linear');

    % Mechanical dynamics
    dw = (Te_interp - T_L - b*w_m) / J;    
    w_m = w_m + dw * dt;

    w_r = w_m * np;

    % Store values
    w_r_vec(k) = w_r;
    Te_vec(k) = Te_interp;
    is_vec(k) = is_interp;
end

% --- Plots ---
fig = figure('Color', 'w'); 
plot(t, w_r_vec / w1, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Startup Speed Response');
ylim([0 1.1]);

format_and_export(fig, 'ex5.speed.png');

fig = figure('Color', 'w'); 
plot(t, Te_vec / T_base, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Torque (pu)');
title('Electromagnetic Torque');

format_and_export(fig, 'ex5.torque.png');

fig = figure('Color', 'w'); 
plot(t, is_vec / I_base, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|i_s| (pu)');
title('Stator Current');

format_and_export(fig, 'ex5.current.png');

%% ex6
time = out.psi_mag.Time;

psi_mag_pu = out.psi_mag.Data / psi_base;
i_mag_pu   = out.i_mag.Data   / I_base;
w_m_pu     = out.w_m.Data     / w_base * np;
Te_pu      = out.Te.Data      / T_base;

fig = figure('Color','w');
plot(time, w_m_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('\omega_m (pu)');
title('Rotor Speed');
xlim([0 1.3]);

format_and_export(fig, 'ex6b.speed.png');

fig = figure('Color','w');
plot(time, Te_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque');
xlim([0 1.3]);

format_and_export(fig, 'ex6b.torque.png');

fig = figure('Color','w');
plot(time, psi_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|ψ_r| (pu)');
title('Rotor Flux Magnitude');
xlim([0 1.3]);

format_and_export(fig, 'ex6b.psi.png');

fig = figure('Color','w');
plot(time, i_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|i_s| (pu)');
title('Stator Current Magnitude');
xlim([0 1.3]);

format_and_export(fig, 'ex6b.current.png');

%% ex6 remastered

% =========================
% RUN SIMULINK MODELS
% =========================
out1 = sim('ex6_1');   % TL ~ ω
out2 = sim('ex6_2');   % TL ~ ω^2


% =========================
% EXTRACT DATA (MODEL 1)
% =========================
time1 = out1.psi_mag.Time;

psi_mag_pu_1 = out1.psi_mag.Data / psi_base;
i_mag_pu_1   = out1.i_mag.Data   / I_base;
w_m_pu_1     = out1.w_m.Data     / w_base * np;
Te_pu_1      = out1.Te.Data      / T_base;


% =========================
% EXTRACT DATA (MODEL 2)
% =========================
time2 = out2.psi_mag.Time;

psi_mag_pu_2 = out2.psi_mag.Data / psi_base;
i_mag_pu_2   = out2.i_mag.Data   / I_base;
w_m_pu_2     = out2.w_m.Data     / w_base * np;
Te_pu_2      = out2.Te.Data      / T_base;


% =========================
% PLOTS: SPEED
% =========================
fig = figure('Color','w');

plot(time1, w_m_pu_1, 'LineWidth', 2); hold on;
plot(time2, w_m_pu_2, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('\omega_m (pu)');
title('Rotor Speed Comparison');
legend('T_L \propto \omega', 'T_L \propto \omega^2', 'Location', 'southeast');
xlim([0 3.5]);

format_and_export(fig, 'ex6.speed.png');


% =========================
% PLOTS: TORQUE
% =========================
fig = figure('Color','w');

plot(time1, Te_pu_1, 'LineWidth', 2); hold on;
plot(time2, Te_pu_2, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque Comparison');
legend('T_L \propto \omega', 'T_L \propto \omega^2');
xlim([0 3.5]);

format_and_export(fig, 'ex6.torque.png');


% =========================
% PLOTS: FLUX
% =========================
fig = figure('Color','w');

plot(time1, psi_mag_pu_1, 'LineWidth', 2); hold on;
plot(time2, psi_mag_pu_2, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('|ψ_r| (pu)');
title('Rotor Flux Magnitude Comparison');
legend('T_L \propto \omega', 'T_L \propto \omega^2', 'Location', 'southeast');
xlim([0 3.5]);

format_and_export(fig, 'ex6.psi.png');


% =========================
% PLOTS: CURRENT
% =========================
fig = figure('Color','w');

plot(time1, i_mag_pu_1, 'LineWidth', 2); hold on;
plot(time2, i_mag_pu_2, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('|i_s| (pu)');
title('Stator Current Comparison');
legend('T_L \propto \omega', 'T_L \propto \omega^2');
xlim([0 3.5]);

format_and_export(fig, 'ex6.current.png');

%% ex7

% ref
time = out.w_ref.Time;

w_ref = out.w_ref.Data / w_base;

vab0_data = out.vab0.Data;
v_alpha = vab0_data(:,1) / V_base;
v_beta = vab0_data(:,2) / V_base;


% Plot w ref
fig = figure('Color','w');
plot(time, w_ref, 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('\omega_{ref} (pu)');
title('Reference speed');
xlim([0 3]);
ylim([0 1.1]);

format_and_export(fig, 'ex7.speed_ref.png');

% Plot voltage ref
fig = figure('Color','w');
plot(time, v_alpha, 'LineWidth', 2); hold on;
plot(time, v_beta, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Voltage (pu)');
title('Voltage reference');
legend('v_\alpha','v_\beta');
xlim([0 3]);
ylim([-1.1 1.1]);

format_and_export(fig, 'ex7.voltage.png');


time = out.psi_mag.Time;

psi_mag_pu = out.psi_mag.Data / psi_base;
i_mag_pu   = out.i_mag.Data   / I_base;
w_m_pu     = out.w_m.Data     / w_base * np;
Te_pu      = out.Te.Data      / T_base;

% Plot both speeds
fig = figure('Color','w');

plot(time, w_m_pu, 'LineWidth', 1.5); hold on;
plot(time, w_ref, '--', 'LineWidth', 1.5); 

grid on;
xlabel('Time (s)');
ylabel('\omega_m (pu)');
title('Rotor Speed');
legend('\omega_m', '\omega_{ref}');
xlim([0 3]);


format_and_export(fig, 'ex7.speed.png');

fig = figure('Color','w');
plot(time, Te_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque');
xlim([0 3]);

format_and_export(fig, 'ex7.torque.png');

fig = figure('Color','w');
plot(time, psi_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|ψ_r| (pu)');
title('Rotor Flux Magnitude');
xlim([0 3]);

format_and_export(fig, 'ex7.psi.png');

fig = figure('Color','w');
plot(time, i_mag_pu, 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('|i_s| (pu)');
title('Stator Current Magnitude');
xlim([0 3]);

format_and_export(fig, 'ex7.current.png');
