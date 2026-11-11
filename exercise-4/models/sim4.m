clc;
clear;
close all;

%% Parameters

% IM MACHINE PARAMETERS (SI)
P_n = 2.3e3;      % W
V_n = 230;        % V
I_n = 5;          % A
f   = 50;         % Hz

p   = 2;          % pole pairs
n_s = 1500;       % rpm
n_n = 1410;       % rpm

R_s = 6.5746;     % Ohm
R_R = 2.106;      % Ohm

L_M   = 0.3354;   % H
L_sig = 0.0416;   % H

J = 0.01;
b = 0;

np = p;
K = 1;

% BASE VALUES

P_base = P_n;
f_base = f;

V_base = sqrt(2) * K * V_n;
I_base = sqrt(2) * K * I_n;

w_base = 2*pi*f_base;

psi_base = V_base / w_base;

Z_base = V_base / I_base;
T_base = P_base / w_base * p;

omega_s = 2*pi*n_s/60;

% PER UNIT

R_s_pu = R_s / Z_base;
R_R_pu = R_R / Z_base;

L_base = Z_base / w_base;

L_M_pu   = L_M / L_base;
L_sig_pu = L_sig / L_base;

J_pu = J * w_base^2 / P_base;

% NOMINAL FLUX

L_sig_n = w_base * L_sig / Z_base;
L_M_n   = w_base * L_M / Z_base;

psi_nominal_pu = sqrt((1 - L_sig_pu^2) / (1 + 2*L_sig_pu/L_M_pu));
psi_nominal = psi_nominal_pu * psi_base;

k = (1 / (1 + 2 * L_sig / L_M)) * ...
    sqrt((1 - L_sig_n^2) * ((1 + L_sig / L_M)^2 - (1 / L_M_n^2)));

Te_base = 3*np*V_base*I_base/2/K^2/w_base;
Te_nominal = Te_base * k;

% CONTROLLERS

trc = 1e-3;
ac = log(9)/trc;

ap = ac / 200;
al = ap * 10;

kpp = 2*ap/psi_nominal;
kip = ap^2/psi_nominal;

wg = 2*pi*f;

R_a = ac*L_sig -(R_s+R_R);
kp = ac*L_sig;
ki = ac*(R_s+R_R+R_a);

as = ac/10;

b_a = 2*K^2*(as*J-b)/(3*np^2*psi_nominal);
kps = 2*K^2*as*J/(3*np^2*psi_nominal);
kis = 2*K^2*as^2*J/(3*np^2*psi_nominal);

%% ex1

close all;

Id_ref = psi_nominal_pu*psi_base/L_M;

RR_factor = [1 0.5 2];
LM_factor = [1 1.5 0.75];

N = length(RR_factor);

results = struct();

for k_case = 1:N

    % estimated parameters
    R_R_est = R_R * RR_factor(k_case);
    L_M_est = L_M * LM_factor(k_case);

    assignin('base','R_R_est',R_R_est);
    assignin('base','L_M_est',L_M_est);

    % run simulation
    out = sim('ex1');

    % store results
    results(k_case).out = out;
    results(k_case).time = out.w_r.Time;
    results(k_case).wr      = out.w_r.Data / w_base;
    results(k_case).wr_ref  = out.w_ref.Data / w_base;
    results(k_case).psi     = out.psidq.Data /psi_base;
    results(k_case).i_dq    = out.Idq.Data / I_base;

end

% 1) SPEED
fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    plot(t, results(k_case).wr, 'LineWidth', 2);
end
plot(results(1).time, ...
     results(1).wr_ref, ...
     'k--', ...
     'LineWidth', 2);
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M', ...
       '\omega_{ref}');
xlim([0 1]);

format_and_export(fig, 'ex1.speed.png');


% 2a) FLUX ψd

fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    psi = results(k_case).psi;
    plot(t, psi(:,1), 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('\psi_d (pu)');
title('\psi_d Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M', ...
       'Location', 'southeast');
xlim([0 1]);
ylim([0 1]);

format_and_export(fig, 'ex1.psid.png');


% 2b) FLUX ψq
fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    psi = results(k_case).psi;
    plot(t, psi(:,2), 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('\psi_q (pu)');
title('\psi_q Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = L_M', ...
       'R_R = 0.5R_R , L_M = 2L_M', ...
       'R_R = 2R_R , L_M = 0.5L_M');
xlim([0 1]);
ylim([-0.5 0.5]);

format_and_export(fig, 'ex1.psiq.png');


% 3) iq
fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    i_dq = results(k_case).i_dq;
    iq = i_dq(:,2);
    plot(t, iq, 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('i_q (pu)');
title('i_q Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M');
xlim([0 1]);

format_and_export(fig, 'ex1.iq.png');

%% ex2

close all;

lambda = 1.5;
w_delta = 0.15 * w_base;

Id_ref = psi_nominal_pu*psi_base/L_M;

RR_factor = [1 0.5 2];
LM_factor = [1 1.5 0.75];

N = length(RR_factor);

results = struct();

for k_case = 1:N

    % estimated parameters
    R_R_est = R_R * RR_factor(k_case);
    L_M_est = L_M * LM_factor(k_case);

    assignin('base','R_R_est',R_R_est);
    assignin('base','L_M_est',L_M_est);

    % run simulation
    out = sim('ex2');

    % store results
    results(k_case).out = out;
    results(k_case).time = out.w_r.Time;
    results(k_case).wr      = out.w_r.Data / w_base;
    results(k_case).wr_ref  = out.w_ref.Data / w_base;
    results(k_case).psi     = out.psidq.Data /psi_base;
    results(k_case).i_dq    = out.Idq.Data / I_base;

end

% 1) SPEED
fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    plot(t, results(k_case).wr, 'LineWidth', 2);
end
plot(results(1).time, ...
     results(1).wr_ref, ...
     'k--', ...
     'LineWidth', 2);
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = 2L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M', ...
       '\omega_{ref}');
xlim([0 1]);

format_and_export(fig, 'ex2.speed.png');


% 2a) FLUX ψd

fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    psi = results(k_case).psi;
    plot(t, psi(:,1), 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('\psi_d (pu)');
title('\psi_d Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = 2L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M', ...
       'Location', 'southeast');
xlim([0 1]);
ylim([0 1]);

format_and_export(fig, 'ex2.psid.png');


% 2b) FLUX ψq
fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    psi = results(k_case).psi;
    plot(t, psi(:,2), 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('\psi_q (pu)');
title('\psi_q Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = 2L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M');
xlim([0 1]);
ylim([-0.5 0.5]);

format_and_export(fig, 'ex2.psiq.png');


% 3) iq
fig = figure('Color','w');
hold on;
grid on;
for k_case = 1:N
    t = results(k_case).time;
    i_dq = results(k_case).i_dq;
    iq = i_dq(:,2);

    % interpolate to a denser grid
    t_dense = linspace(t(1), t(end), 5000);
    iq_dense = interp1(t, iq, t_dense, 'pchip');

    plot(t_dense, iq_dense, 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('i_q (pu)');
title('i_q Response for Different Parameter Estimates');
legend('R_R = R_R , L_M = 2L_M', ...
       'R_R = 0.5R_R , L_M = 1.5L_M', ...
       'R_R = 2R_R , L_M = 0.75L_M');
xlim([0 1]);

format_and_export(fig, 'ex2.iq.png');

%% ex3

close all;

Id_ref = psi_nominal_pu*psi_base/L_M;

lambda = 1.5;
w_delta = 0.1 * w_base;

L_M_est = L_M;
R_R_est = R_R;

I_min = 0.1 * I_base;

out = sim('ex3');

t = out.w_r.Time;

w_ref = out.w_ref.Data / w_base;
w     = out.w_r.Data / w_base;

Te = out.Te.Data / Te_nominal;

i_dq = out.Idq.Data / I_base;
psi   = out.psidq.Data / psi_base;

Id = i_dq(:,1);
Iq = i_dq(:,2);

Psid = psi(:,1);
Psiq = psi(:,2);

% 1) SPEED

fig = figure('Color','w');
hold on;
grid on;
plot(t, w, 'LineWidth', 2);
plot(t, w_ref, '--', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Response with Field Weakening');
legend('\omega_r','\omega_{ref}','Location','northeast');
xlim([0 max(t)]);

% format_and_export(fig, 'ex3.speed.png');

% 2) TORQUE
fig = figure('Color','w');
hold on;
grid on;
plot(t, Te, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque');
xlim([0 max(t)]);

% format_and_export(fig, 'ex3.torque.png');

% 3) CURRENTS (Id, Iq)
fig = figure('Color','w');
hold on;
grid on;
plot(t, Id, 'LineWidth', 2);
plot(t, Iq, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Current (pu)');
title('Currents with Field Weakening');
legend('i_d','i_q','Location','best');
xlim([0 max(t)]);

% format_and_export(fig, 'ex3.currents.png');

% 4) FLUX (Psid, Psiq)
fig = figure('Color','w');
hold on;
grid on;
plot(t, Psid, 'LineWidth', 2);
plot(t, Psiq, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Flux (pu)');
title('Rotor Flux with Field Weakening');
legend('\psi_d','\psi_q','Location','best');
xlim([0 max(t)]);

% format_and_export(fig, 'ex3.flux.png');

%% ex4 simple

close all;

Id_ref = psi_nominal_pu*psi_base/L_M;

lambda = 1.5;
w_delta = 0.1 * w_base;

L_M_est = L_M;
R_R_est = 2 * R_R;

I_min = 0.1 * I_base;

assignin('base','R_R_est',R_R_est);
assignin('base','L_M_est',L_M_est);

out_mod = sim('ex3');

out_simple = sim('ex4');

t_mod = out_mod.w_r.Time;
t_simple = out_simple.w_r.Time;

w_mod = out_mod.w_r.Data / w_base;
w_simple = out_simple.w_r.Data / w_base;
w_ref = out_mod.w_ref.Data / w_base;

Te_mod = out_mod.Te.Data / Te_nominal;
Te_simple = out_simple.Te.Data / Te_nominal;

psi_mod = out_mod.psidq.Data / psi_base;
psi_simple = out_simple.psidq.Data / psi_base;

i_mod = out_mod.Idq.Data / I_base;
i_simple = out_simple.Idq.Data / I_base;

t_max = max([t_mod ; t_simple]);

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod,w_mod,'LineWidth',2);
plot(t_simple,w_simple,'LineWidth',2);
plot(t_mod,w_ref,'k--','LineWidth',2);

xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Response in Field Weakening');

legend('Modified Current Model',...
       'Simple Current Model',...
       '\omega_{ref}');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_speed.png');

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod,Te_mod,'LineWidth',2);
plot(t_simple,Te_simple,'LineWidth',2);

xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque');

legend('Modified Current Model',...
       'Simple Current Model');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_torque.png');

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod,psi_mod(:,1),'LineWidth',2);
plot(t_simple,psi_simple(:,1),'LineWidth',2);

xlabel('Time (s)');
ylabel('\psi_d (pu)');
title('\psi_d in Field Weakening');

legend('Modified Current Model',...
       'Simple Current Model');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_psid.png');

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod,psi_mod(:,2),'LineWidth',2);
plot(t_simple,psi_simple(:,2),'LineWidth',2);

xlabel('Time (s)');
ylabel('\psi_q (pu)');
title('\psi_q in Field Weakening');

legend('Modified Current Model',...
       'Simple Current Model');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_psiq.png');

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod,i_mod(:,1),'LineWidth',2);
plot(t_simple,i_simple(:,1),'LineWidth',2);

xlabel('Time (s)');
ylabel('i_d (pu)');
title('d-axis Current');

legend('Modified Current Model',...
       'Simple Current Model');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_id.png');

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod,i_mod(:,2),'LineWidth',2);
plot(t_simple,i_simple(:,2),'LineWidth',2);

xlabel('Time (s)');
ylabel('i_q (pu)');
title('q-axis Current');

legend('Modified Current Model',...
       'Simple Current Model');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_iq.png');

%% ex4 comparison

close all;

Id_ref = psi_nominal_pu*psi_base/L_M;

lambda = 1.5;
w_delta = 0.1 * w_base;

L_M_est = L_M;
R_R_est = 2 * R_R;

I_min = 0.1 * I_base;

R_R_est = R_R;

assignin('base','R_R_est',R_R_est);
assignin('base','L_M_est',L_M_est);

out_mod_correct = sim('ex3');
out_simple_correct = sim('ex4');

% Wrong rotor resistance estimation

R_R_est = 2 * R_R;

assignin('base','R_R_est',R_R_est);
assignin('base','L_M_est',L_M_est);

out_mod_wrong = sim('ex3');
out_simple_wrong = sim('ex4');

% Extract data

t_mod_c = out_mod_correct.w_r.Time;
t_mod_w = out_mod_wrong.w_r.Time;

t_simple_c = out_simple_correct.w_r.Time;
t_simple_w = out_simple_wrong.w_r.Time;

w_mod_c = out_mod_correct.w_r.Data / w_base;
w_mod_w = out_mod_wrong.w_r.Data / w_base;

w_simple_c = out_simple_correct.w_r.Data / w_base;
w_simple_w = out_simple_wrong.w_r.Data / w_base;

w_ref = out_mod_correct.w_ref.Data / w_base;

Te_mod_c = out_mod_correct.Te.Data / Te_nominal;
Te_mod_w = out_mod_wrong.Te.Data / Te_nominal;

Te_simple_c = out_simple_correct.Te.Data / Te_nominal;
Te_simple_w = out_simple_wrong.Te.Data / Te_nominal;

psi_mod_c = out_mod_correct.psidq.Data / psi_base;
psi_mod_w = out_mod_wrong.psidq.Data / psi_base;

psi_simple_c = out_simple_correct.psidq.Data / psi_base;
psi_simple_w = out_simple_wrong.psidq.Data / psi_base;

i_mod_c = out_mod_correct.Idq.Data / I_base;
i_mod_w = out_mod_wrong.Idq.Data / I_base;

i_simple_c = out_simple_correct.Idq.Data / I_base;
i_simple_w = out_simple_wrong.Idq.Data / I_base;

t_max = max([t_mod_c ; t_mod_w ; t_simple_c ; t_simple_w]);

% Speed

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod_c,w_mod_c,'LineWidth',2);
plot(t_mod_w,w_mod_w,'LineWidth',2);

plot(t_simple_c,w_simple_c,'LineWidth',2);
plot(t_simple_w,w_simple_w,'LineWidth',2);

plot(t_mod_c,w_ref,'k--','LineWidth',2);

xlabel('Time (s)');
ylabel('\omega_r (pu)');
title('Speed Response in Field Weakening');

legend('Modified - Correct R_R',...
       'Modified - Wrong R_R',...
       'Simple - Correct R_R',...
       'Simple - Wrong R_R',...
       '\omega_{ref}', 'Location', 'southeast');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_speed.png');

% Torque

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod_c,Te_mod_c,'LineWidth',2);
plot(t_mod_w,Te_mod_w,'LineWidth',2);

plot(t_simple_c,Te_simple_c,'LineWidth',2);
plot(t_simple_w,Te_simple_w,'LineWidth',2);

xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque');

legend('Modified - Correct R_R',...
       'Modified - Wrong R_R',...
       'Simple - Correct R_R',...
       'Simple - Wrong R_R');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_torque.png');

% psi_d

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod_c,psi_mod_c(:,1),'LineWidth',2);
plot(t_mod_w,psi_mod_w(:,1),'LineWidth',2);

plot(t_simple_c,psi_simple_c(:,1),'LineWidth',2);
plot(t_simple_w,psi_simple_w(:,1),'LineWidth',2);

xlabel('Time (s)');
ylabel('\psi_d (pu)');
title('\psi_d in Field Weakening');

legend('Modified - Correct R_R',...
       'Modified - Wrong R_R',...
       'Simple - Correct R_R',...
       'Simple - Wrong R_R');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_psid.png');

% psi_q

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod_c,psi_mod_c(:,2),'LineWidth',2);
plot(t_mod_w,psi_mod_w(:,2),'LineWidth',2);

plot(t_simple_c,psi_simple_c(:,2),'LineWidth',2);
plot(t_simple_w,psi_simple_w(:,2),'LineWidth',2);

xlabel('Time (s)');
ylabel('\psi_q (pu)');
title('\psi_q in Field Weakening');

legend('Modified - Correct R_R',...
       'Modified - Wrong R_R',...
       'Simple - Correct R_R',...
       'Simple - Wrong R_R');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_psiq.png');

% i_d

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod_c,i_mod_c(:,1),'LineWidth',2);
plot(t_mod_w,i_mod_w(:,1),'LineWidth',2);

plot(t_simple_c,i_simple_c(:,1),'LineWidth',2);
plot(t_simple_w,i_simple_w(:,1),'LineWidth',2);

xlabel('Time (s)');
ylabel('i_d (pu)');
title('d-axis Current');

legend('Modified - Correct R_R',...
       'Modified - Wrong R_R',...
       'Simple - Correct R_R',...
       'Simple - Wrong R_R');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_id.png');

% i_q

fig = figure('Color','w');
hold on;
grid on;

plot(t_mod_c,i_mod_c(:,2),'LineWidth',2);
plot(t_mod_w,i_mod_w(:,2),'LineWidth',2);

plot(t_simple_c,i_simple_c(:,2),'LineWidth',2);
plot(t_simple_w,i_simple_w(:,2),'LineWidth',2);

xlabel('Time (s)');
ylabel('i_q (pu)');
title('q-axis Current');

legend('Modified - Correct R_R',...
       'Modified - Wrong R_R',...
       'Simple - Correct R_R',...
       'Simple - Wrong R_R');

xlim([0 t_max]);

format_and_export(fig,'ex4_compare_iq.png');