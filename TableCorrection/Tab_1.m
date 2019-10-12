%% Tab 1
fontsz = 8;
cd(dir_Main);

hfig1 = figure('WindowStyle','normal');
htabgroup = uitabgroup(hfig1);

% Introduce Tab #1
htab1 = uitab(htabgroup, 'Title', 'Fuel Table');
hax1 = axes('Parent', htab1);

%Plot Old Fuel Table
subplot(2,4,1)
surf(Fuelx(1:length(Fuelx)), Fuely(2:length(Fuely)), OldFuelTable3(2:length(Fuely),2:length(Fuelx)+1))
set(gca, 'OuterPosition', [0.01, 0.6, 0.24, 0.4]) %[width_strt height_strt width height]
title('Old Fuel Table')
grid on
xlabel('RPM')
ylabel('MAP')
zlabel('IJPU')

%Plot New Fuel Table
subplot(2,4,2)
surf(Fuelx(1:length(Fuelx)), Fuely(2:length(Fuely)), NewFuelTable(2:length(Fuely),2:length(Fuelx)+1))
set(gca, 'OuterPosition', [0.25, 0.6, 0.24, 0.4]) %[width_strt height_strt width height]
title('New Fuel Table')
grid on
xlabel('RPM')
ylabel('MAP')
zlabel('IJPU')

%Plot Diff Table
TableDiff = NewFuelTable - OldFuelTable3;
subplot(2,4,3)
surf(Fuelx(1:length(Fuelx)), Fuely(2:length(Fuely)), TableDiff(2:length(Fuely),2:length(Fuelx)+1))
set(gca, 'OuterPosition', [0.49, 0.6, 0.24, 0.4]) %[width_strt height_strt width height]
title('New Minus Old')
grid on
xlabel('RPM')
ylabel('MAP')
zlabel('IJPU')

%Plot Sample Table
subplot(2,4,4)
surf(Fuelx(1:length(Fuelx)), Fuely(2:length(Fuely)), SampleCountTable(2:length(Fuely),2:length(Fuelx)+1))
set(gca, 'OuterPosition', [0.73, 0.6, 0.25, 0.4]) %[width_strt height_strt width height]
title('Sample Count')
grid on
xlabel('RPM')
ylabel('MAP')
zlabel('Samples')


%Plot Data Log
subplot(2,4,[5 6 7 8]) % This creates blank plot behind real plot
% Currently not using ylabels
ylabels{1}='RPM';
ylabels{2}='RPM';
ylabels{3}='Throttle Position';
ylabels{4}='Throttle Position';
time_constant_throttle = LoggedData3(rows_LoggedData4,1);
% Use below for original plot using plotyyy function
% plotyyy(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_Filtered_RPM),PassThroughData(:,Variable_Time),PassThroughData(:,Variable_Filtered_RPM),LoggedData3(:,Variable_Time),LoggedData3(:,Variable_TP),PassThroughData(:,Variable_Time),PassThroughData(:,Variable_TP),ylabels,time_constant_throttle);

plot_primary = 2;
plot_secondary = 2;
[axh, hLine1, hLine2] = plotyy(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_Filtered_RPM), LoggedData3(:,Variable_Time),LoggedData3(:,Variable_TP));
hLine1.LineWidth = plot_primary;
hLine2.LineWidth = plot_primary;
color_prim_rpm = [0 0 0.8]; % Dark Blue
color_prim_tp = [0.5 0.2 0.6]; % Purple
color_second_rpm = [0.5 1 0]; % Lime Green
color_second_tp = [1 1 0]; % Yellow
color_yline_rpm = [1 0 0]; % Red
color_yline_tp = [1 0.85 .78]; % Tan
set(hLine1, 'color', color_prim_rpm);
set(hLine2, 'color', color_prim_tp);
for i = 2000:2000:14000
    yline(i,':','LineWidth',1,'Color',color_yline_tp);
    
end
% fighandles = findall( allchild(0), 'type', 'figure');
% fig = fighandles(1);   %or as appropriate
% allaxes = findall(fig, 'type', 'axes');
set(axh(1),'YLim',[-15000 15000], 'YColor', color_prim_rpm)
set(axh(1),'YTick',[000:2000:14000])
yt=get(axh(1),'YTick');
set(axh(1),'YTickLabel',sprintf('%1.0f\n',yt))
set(axh(1),'ycolor', color_prim_rpm) % OR below
% axh(1).YAxis(1).Color = color_prim_rpm;
set(axh(2),'YLim',[0 200])
set(axh(2),'YTick',[0:20:100])
yt=get(axh(2),'YTick');
set(axh(2),'YTickLabel',sprintf('%1.0f\n',yt))
set(axh(2),'ycolor',color_prim_tp)
titlename = strcat('Logged Data -', {' '}, logfilename);
title(titlename, 'Interpreter', 'none')
clear titlename
xlabel('Time (s)')
ylabel(axh(1),'RPM', 'Units', 'Normalized', 'Position', [-0.035, 0.73, 0]); % Normalized x,y,z location
% ylabel(axh(2),'Throttle Position','rotation', 270,'HorizontalAlignment','left','VerticalAlignment','bottom')
ylabel(axh(2),'Throttle Position', 'rotation', 270, 'Units', 'Normalized', 'Position', [1.0375, 0.2475, 0]); % Normalized x,y,z location
hold(axh(1), 'on');
hLine3 = plot(PassThroughData(:,Variable_Time),PassThroughData(:,Variable_Filtered_RPM));
hLine3.LineWidth = plot_secondary;
set(hLine3, 'color', color_second_rpm)
hold(axh(2), 'on');
hLine4 = plot(axh(2),PassThroughData(:,Variable_Time),PassThroughData(:,Variable_Filtered_TP));
hLine4.LineWidth = plot_secondary;
set(hLine4, 'color', color_second_tp);
%y-grid throttle position
for i = 20:20:100
    yline(axh(2),i, ':', 'LineWidth', 1, 'Color', [0 0.5 0]);
end
%x-grid entire graph
plot_xgrid_interval = 50;
plot_xgrid_numberspacings = max(LoggedData3(:,1))/plot_xgrid_interval;
plot_xgrid_numberspacings = ceil(plot_xgrid_numberspacings); % Round to largest integer
for i = 1:1:plot_xgrid_numberspacings
    xlines = xline(50*i,'--', 'LineWidth', 0.5, 'Color', 'w');
end

% Set Background and Position
set(gca,'Color','k')
set(gca, 'OuterPosition', [-0.09, -0.025, 1.1375, 0.6]) %[width_strt height_strt width height]
