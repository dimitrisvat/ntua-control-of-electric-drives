%% =========================
% RUN SIMULINK MODEL (ex4)
% =========================
out = sim('ex4');

time_sim = out.psi_mag.Time;

psi_mag_pu_sim = out.psi_mag.Data / psi_base;
i_mag_pu_sim   = out.i_mag.Data   / I_base;
w_m_pu_sim     = out.w_m.Data     / w_base * np;
Te_pu_sim      = out.Te.Data      / T_base;

% Clarke signals
time_clark = out.vabc.Time;

vabc_data = out.vabc.Data;
va_sim = vabc_data(:,1) / V_base;
vb_sim = vabc_data(:,2) / V_base;
vc_sim = vabc_data(:,3) / V_base;

vab0_data = out.vab0.Data;
v_alpha_sim = vab0_data(:,1) / V_base;
v_beta_sim  = vab0_data(:,2) / V_base;


%% =========================
% CUSTOM MODEL (ex5 loop)
% =========================
dt = 1e-5;         
t_end = 0.8;      
t = 0:dt:t_end;

T_L = 0;         
w_r = 0; 
w_m = 0;

w_r_vec = zeros(size(t));
Te_vec  = zeros(size(t));
is_vec  = zeros(size(t));

for k = 1:length(t)

    Te_interp = interp1(w_vec, Te, w_r, 'linear');
    is_interp = interp1(w_vec, is_mag, w_r, 'linear');

    dw = (Te_interp - T_L - b*w_m) / J;    
    w_m = w_m + dw * dt;

    w_r = w_m * np;

    w_r_vec(k) = w_r;
    Te_vec(k)   = Te_interp;
    is_vec(k)   = is_interp;
end


%% =========================
% EXTEND STEADY-STATE TO 1.3 s
% =========================
t_end_plot = 1.3;
t_ext = 0:dt:t_end_plot;

w_ss  = w_r_vec / w1;
Te_ss = Te_vec / T_base;
i_ss  = is_vec / I_base;

w_ss  = [w_ss  w_ss(end)  * ones(1, length(t_ext) - length(t))];
Te_ss = [Te_ss Te_ss(end) * ones(1, length(t_ext) - length(t))];
i_ss  = [i_ss  i_ss(end)  * ones(1, length(t_ext) - length(t))];


%% =========================
% PLOTS: SPEED
% =========================
fig = figure('Color','w');

plot(t_ext, w_ss, 'LineWidth', 2); hold on;
plot(time_sim, w_m_pu_sim, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('\omega (pu)');
title('Rotor Speed Comparison');
legend('Steady-state model', 'Dynamic model');
xlim([0 1.3]);

format_and_export(fig, 'compare.speed.png');


%% =========================
% PLOTS: TORQUE
% =========================
fig = figure('Color','w');

plot(t_ext, Te_ss, 'LineWidth', 2); hold on;
plot(time_sim, Te_pu_sim, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('T_e (pu)');
title('Electromagnetic Torque Comparison');
legend('Steady-state model', 'Dynamic model');
xlim([0 1.3]);

format_and_export(fig, 'compare.torque.png');


%% =========================
% PLOTS: CURRENT
% =========================
fig = figure('Color','w');

plot(t_ext, i_ss, 'LineWidth', 2); hold on;
plot(time_sim, i_mag_pu_sim, 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('|i_s| (pu)');
title('Stator Current Comparison');
legend('Steady-state model', 'Dynamic model');
xlim([0 1.3]);

format_and_export(fig, 'compare.current.png');