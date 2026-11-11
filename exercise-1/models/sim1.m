%% Script for the 1st simulation for Control System of Electric Motors

close all;
clear; 
clc;

% DC motor parameters
Vn = 120;           % V
In = 20;            % A
Nn = 3000;          % rpm
wn = Nn*2*pi/60;    %rad/s
Tn = 7;             % Nm
R = 0.5;            % Ohm
L = 2.5e-3;         % H
psi = 0.35;         % Vs
J = 0.001;          % kgm^2
b = 0;

% Current controller parameters

trc = 1e-3;         % s
ac = log(9)/trc;    % Hz
kp = ac*L;
ki = ac^2*L;
Ra = ac*L-R;

% Speed controller parameters

trs = trc * 10;         % s
as = log(9)/trs;    % Hz
kps = as*J/psi;
kis = as^2*J/psi;
ba = (as*J-b)/psi;

%% Original dummy script
time = out.simout.Time;
data = out.simout.Data;

fig = figure('Color', 'w'); 
fig.Position = [100, 100, 700, 600]; % Slightly wider than tall for that specific look

% 2. Plotting
p = plot(time, data, 'LineWidth', 2); % Thicker lines like your image
grid on;

% 3. Advanced Formatting to match the image
ax = gca;
ax.FontSize = 12;            % Standard readable font size
ax.FontName = 'Helvetica';   % Professional font
ax.Box = 'on';               % Adds the top and right border lines
ax.LineWidth = 1;            % Thicker axes lines

% Labels and Title
xlabel('Time (s)') % Matches your uploaded style
ylabel('Magnitude (pu)')
title('Current and Speed Normalized', 'FontSize', 14, 'FontWeight', 'bold')

% Legend
lgd = legend('i (pu)', 'w_r (pu)', 'Location', 'northeast');
lgd.FontSize = 10;

% This forces the axes to stop exactly where the data ends
axis tight; 
% Add a small vertical buffer so the line isn't touching the top border
ylim([min(data(:))*1.1, max(data(:))*1.1]);

% For the current rise time
yline(0.1, '--r','LineWidth',1.5);
yline(0.9, '--r','LineWidth',1.5);
xlim([0 2e-3])
lgd = legend('i (pu)', '10%', '90%');
title('Current Normalized', 'FontSize', 14, 'FontWeight', 'bold')


% axtoolbar(ax, {}); % Remove the toolbar
if ~exist('Figures', 'dir'), mkdir('Figures'); end

exportgraphics(fig, fullfile(pwd, 'Figures', 'ex5.current_and_speed.png'), 'Resolution', 300);


%% ex1

time = out.ex1.Time;
data = out.ex1.Data;
data1 = data;

i = data(:,1);
wr = data(:,2);
Tload = data(:,3);

if ~exist('Figures','dir'), mkdir('Figures'); end

% ---- Figure 1 : Current and Load Torque ----
fig1 = figure('Color','w'); 
fig1.Position = [100,100,700,600];

plot(time,[i Tload],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Current and Load Torque', 'FontSize',14,'FontWeight','bold')

legend('i (pu)','T_{Load} (pu)','Location','northeast','FontSize',10)

axis tight
ylim([min([i;Tload])*1.1 , max([i;Tload])*1.1])

exportgraphics(fig1, fullfile(pwd,'Figures','ex1.current.png'),'Resolution',300)


% ---- Figure 2 : Speed and Load Torque ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time,[wr Tload],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Speed and Load Torque', 'FontSize',14,'FontWeight','bold')

legend('w_r (pu)','T_{Load} (pu)','Location','northeast','FontSize',10)

axis tight
ylim([min([wr;Tload])*1.1 , max([wr;Tload])*1.1])

exportgraphics(fig2, fullfile(pwd,'Figures','ex1.speed.png'),'Resolution',300)

%% ex2

time = out.ex2.Time;
data = out.ex2.Data;
data2 = data;

error = data(:,1);
int = data(:,2);

if ~exist('Figures','dir'), mkdir('Figures'); end

% ---- Figure 1 : Current and Speed ----
fig1 = figure('Color','w'); 
fig1.Position = [100,100,700,600];

plot(time,[error int],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Current and Speed', 'FontSize',14,'FontWeight','bold')

legend('i (pu)','w_{r} (pu)','Location','northeast','FontSize',10)

axis tight
ylim([min(data(:))*1.1, max(data(:))*1.1]);

exportgraphics(fig1, fullfile(pwd,'Figures','ex2.current_and_speed.png'),'Resolution',300)


% ---- Figure 2 : Current rise time ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time, error,'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Current rise time', 'FontSize',14,'FontWeight','bold')

axis tight
ylim([min(error(:))*1.1, max(error(:))*1.1]);

% For the current rise time
yline(0.1, '--r','LineWidth',1.5);
yline(0.9, '--r','LineWidth',1.5);
xlim([0 2e-3])
lgd = legend('i (pu)', '10%', '90%');
title('Current Normalized', 'FontSize', 14, 'FontWeight', 'bold')


exportgraphics(fig2, fullfile(pwd,'Figures','ex2.current_risetime.png'),'Resolution',300)



%% ex3

time = out.ex3.Time;
data = out.ex3.Data;
data5 = data;

i = data(:,1);
wr = data(:,2);
Tload = data(:,3);
wref = data(:,4);
i_ref = data(:,5);

if ~exist('Figures','dir'), mkdir('Figures'); end

% ---- Figure 1 : Current ----
fig1 = figure('Color','w'); 
fig1.Position = [100,100,700,600];

plot(time,[i Tload wref i_ref],'LineWidth',2)
grid on
 
ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Current Step response', 'FontSize',14,'FontWeight','bold')
title('Current Step response with 300% I_{n,sat}', 'FontSize',14,'FontWeight','bold')


legend('i (pu)','T_{Load} (pu)', 'w_{ref} (pu)', 'i_{ref} (pu)','Location','southeast','FontSize',10)

axis tight
ylim([min(i)*1.1 , max(i)*1.1])
xlim([0 0.2]);


exportgraphics(fig1, fullfile(pwd,'Figures','ex3.current_300sat.png'),'Resolution',300)


% ---- Figure 2 : Speed  ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time,[wr Tload wref],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Speed Step response', 'FontSize',14,'FontWeight','bold')
title('Speed Step response with 300% I_{n,sat}', 'FontSize',14,'FontWeight','bold')


legend('w_r (pu)','T_{Load} (pu)', 'w_{ref} (pu)','Location','southeast','FontSize',10)

axis tight
ylim([min(wr)*1.1 , max(wr)*1.1])
xlim([0 0.2]);

exportgraphics(fig2, fullfile(pwd,'Figures','ex3.speed_300sat.png'),'Resolution',300)

% ---- Figure 2 : Speed rise time ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time, wr,'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Speed rise time', 'FontSize',14,'FontWeight','bold')

axis tight
ylim([min(wr(:))*1.1, max(wr(:))*1.1]);
xlim([0 0.025]);

% For the current rise time
yline(0.1, '--r','LineWidth',1.5);
yline(0.9, '--r','LineWidth',1.5);
legend('w_r (pu)', '10%', '90%','Location','southeast','FontSize',10)
title('Speed Normalized', 'FontSize', 14, 'FontWeight', 'bold')

exportgraphics(fig2, fullfile(pwd,'Figures','ex3.speed_risetime_sat.png'),'Resolution',300)





%% ex4

% ba = 0;
bn = Tn/wn;
kis = bn*as/psi;
disp('Rerun the sim with the changed ba');

time = out.ex4.Time;
data = out.ex4.Data;
data5 = data;

i = data(:,1);
wr = data(:,2);
Tload = data(:,3);
wref = data(:,4);
i_ref = data(:,5);

if ~exist('Figures','dir'), mkdir('Figures'); end

% ---- Figure 1 : Current ----
fig1 = figure('Color','w'); 
fig1.Position = [100,100,700,600];

plot(time,[i Tload wref i_ref],'LineWidth',2)
grid on
 
ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Current Step response', 'FontSize',14,'FontWeight','bold')
% title('Current Step response with 300% I_{n,sat}', 'FontSize',14,'FontWeight','bold')

legend('i (pu)','T_{Load} (pu)', 'w_{ref} (pu)', 'i_{ref} (pu)','Location','southeast','FontSize',10)

axis tight
ylim([min(i)*1.1 , max(i)*1.1])
xlim([0 0.2]);


% exportgraphics(fig1, fullfile(pwd,'Figures','ex4.currentb.png'),'Resolution',300)


% ---- Figure 2 : Speed  ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time,[wr Tload wref],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Speed Step response', 'FontSize',14,'FontWeight','bold')
% title('Speed Step response with 300% I_{n,sat}', 'FontSize',14,'FontWeight','bold')

legend('w_r (pu)','T_{Load} (pu)', 'w_{ref} (pu)','Location','southeast','FontSize',10)

axis tight
ylim([min(wr)*1.1 , max(wr)*1.1])
xlim([0 0.2]);

% exportgraphics(fig2, fullfile(pwd,'Figures','ex4.speedb.png'),'Resolution',300)

% ---- Figure 2 : Speed rise time ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time, wr,'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Speed rise time', 'FontSize',14,'FontWeight','bold')

axis tight
ylim([min(wr(:))*1.1, max(wr(:))*1.1]);

% For the current rise time
yline(0.1, '--r','LineWidth',1.5);
yline(0.9, '--r','LineWidth',1.5);
xlim([0 0.07])
legend('i (pu)', '10%', '90%','Location','southeast','FontSize',10)
title('Speed Normalized', 'FontSize', 14, 'FontWeight', 'bold')

% exportgraphics(fig2, fullfile(pwd,'Figures','ex4.speed_risetimeb.png'),'Resolution',300)

%% ex5_1 (1 for speed control aw and 2 for current aw)

% disp('First run with the aw and do the following lines');
% time = out.ex5_1.Time;
% data = out.ex5_1.Data;
% data5 = data; % Store the data for plotting

time = out.ex5_1.Time;
data = out.ex5_1.Data;
i = data(:,1);
wr = data(:,2);
error = data(:,3);
int = data(:,4);
wr_ref = data(:,5);

if ~exist('Figures','dir'), mkdir('Figures'); end

% ---- Figure 1 : Speed ----
fig1 = figure('Color','w'); 
fig1.Position = [100,100,700,600];

plot(time,[data5(:,2) wr, wr_ref],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Speed', 'FontSize',14,'FontWeight','bold')

legend('w_r with anti-windup (pu)','w_r without anti-windup (pu)', 'w_{ref} (pu)','Location','southeast','FontSize',10)

axis tight
ylim([min(wr)*1.1 , max(wr)*1.1])

exportgraphics(fig1, fullfile(pwd,'Figures','ex5.speed.png'),'Resolution',300)

% ---- Figure 2 : Integrator  ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time,[data5(:,4) int],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude')
title('Speed Integrator error', 'FontSize',14,'FontWeight','bold')

legend('Integrator error with anti-windup','Integrator error without anti-windup','Location','northeast','FontSize',10)

axis tight
ylim([min(int)*1.1 , max(int)*1.1])

exportgraphics(fig2, fullfile(pwd,'Figures','ex5.int_speed.png'),'Resolution',300)

%% ex5_2 (1 for speed control aw and 2 for current aw)
% 
% disp('First run with the aw and do the following lines');
% time = out.ex5_2.Time;
% data = out.ex5_2.Data;
% data5 = data; % Store the data for plotting

time = out.ex5_2.Time;
data = out.ex5_2.Data;
i = data(:,1);
wr = data(:,2);
error = data(:,3);
int = data(:,4);
i_ref = data(:,5);

if ~exist('Figures','dir'), mkdir('Figures'); end

% ---- Figure 1 : Current ----
fig1 = figure('Color','w'); 
fig1.Position = [100,100,700,600];

plot(time,[data5(:,1) i, i_ref],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude (pu)')
title('Current', 'FontSize',14,'FontWeight','bold')

legend('i with anti-windup (pu)','i without anti-windup (pu)', 'i_{ref} (pu)','Location','southeast','FontSize',10)

axis tight
ylim([min(i)*1.1 , max(i)*1.1])
xlim([0 0.15])

exportgraphics(fig1, fullfile(pwd,'Figures','ex5.current.png'),'Resolution',300)

% ---- Figure 2 : Integrator  ----
fig2 = figure('Color','w'); 
fig2.Position = [100,100,700,600];

plot(time,[data5(:,4) int],'LineWidth',2)
grid on

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Helvetica';
ax.Box = 'on';
ax.LineWidth = 1;

xlabel('Time (s)')
ylabel('Magnitude')
title('Current Integrator error', 'FontSize',14,'FontWeight','bold')

legend('Integrator error with anti-windup','Integrator error without anti-windup','Location','southeast','FontSize',10)

axis tight
ylim([min(int)*1.1 , max(int)*1.1])
xlim([0 0.15])

exportgraphics(fig2, fullfile(pwd,'Figures','ex5.int_current.png'),'Resolution',300)