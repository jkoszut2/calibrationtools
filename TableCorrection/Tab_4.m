%% Tab #4
htab4 = uitab(htabgroup, 'Title', 'Temperature');
hax4 = axes('Parent', htab4);

%Plot RPM and MAP
subplot(2,4,[1 4])
[axh, hLine1, hLine2] = plotyy(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_RPM),LoggedData3(:,Variable_Time),LoggedData3(:,Variable_MAP));
set(axh(1), 'ycolor', 'k')
set(axh(2),'ycolor', 'k')
graph_rpmmap_LineWidth = 2;
set(hLine1, 'LineWidth', 1);
set(hLine2, 'LineWidth', 1);
set(hLine1,'color', 'r');
set(hLine2,'color', 'b');
xlabel('Time (s)')
ylabel(axh(1),'RPM','HorizontalAlignment','left','VerticalAlignment','bottom');
ylabel(axh(2),'Pressure (bar)', 'rotation', 270, 'HorizontalAlignment','left','VerticalAlignment','bottom');
set(axh(1),'YLim',[-15000 15000], 'YColor', 'k')
set(axh(1),'YTick',[000:2000:14000])
set(axh(2),'YLim',[0 2], 'YColor', 'k')
set(axh(2),'YTick',[0:0.2:1])
yt=get(axh(1),'YTick');
set(axh(1),'YTickLabel',sprintf('%1.0f\n',yt))
grid(axh(2), 'on')

% hold(axh(1), 'on');
% hLine3 = plot(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_OT));
% hLine3.LineWidth = graph_rpmmap_LineWidth;
% set(hLine3, 'color', 'r')
grid on
legend('RPM', 'MAP', 'Location', 'SouthEast')
%Set Border Width
ax = gca;
ax.XRuler.Axle.LineWidth = plot_borderwidth;
ax.YRuler.Axle.LineWidth = plot_borderwidth;

%Plot Temperatures
subplot(2,4,[5 6 7 8])
[axh, hLine1, hLine2] = plotyy(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_ET),LoggedData3(:,Variable_Time),LoggedData3(:,Variable_FT));
set(axh(1), 'ycolor', 'k')
set(axh(2),'ycolor', 'k')
graph_temps_LineWidth = 2;
set(hLine1, 'LineWidth', graph_temps_LineWidth);
set(hLine2, 'LineWidth', graph_temps_LineWidth);
set(hLine1,'color', 'b');
set(hLine2,'color', [0.39216 0.83137 0.07451]);
xlabel('Time (s)')
ylabel('Oil & Water Temperature (C)')
ylabel(axh(2),'Fuel Temperature (C)', 'rotation', 270, 'HorizontalAlignment','center','VerticalAlignment','bottom');
hold(axh(1), 'on');
hLine3 = plot(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_OT));
hLine3.LineWidth = graph_temps_LineWidth;
set(hLine3, 'color', 'r')
hLine4 = yline(Lim_EngineTemp(2), ':', 'LineWidth', 2, 'Color', [0.65 0.65 0.65]);
set(axh(1),'YLim',[0 ceil(max(max(LoggedData3(:,[Variable_ET Variable_OT])))/20)*20*1.1])
set(axh(2),'YLim',[0 max(max(LoggedData3(:,[Variable_FT])))*1.1])
set(axh(1),'YTick',[0:20:ceil(max(max(LoggedData3(:,[Variable_ET Variable_OT])))/20)*20])
set(axh(2),'YTick',[0:10:ceil(max(max(LoggedData3(:,[Variable_FT])))/10)*10])
set(axh(1),'Box','off')
hAx(2).XAxis.Visible = 'on';
% topline command not working - October 11, 2019
% topline = refline(axh(1),0,axh(1).YLim(2));
% topline.LineWidth = 2;
% topline.Color = 'k';
axh(1).YAxis.LineWidth = 2;
axh(2).YAxis.LineWidth = 2;
grid on
ax = gca;
ax.GridAlpha = 1;  % 0 = Transparent 1 = Opaque
ax.GridLineStyle = ':';
legend([hLine1 hLine3 hLine2 hLine4], 'Water', 'Oil', 'Fuel', 'Water Threshold', 'Location', 'SouthEast')
%Set Border Width
ax = gca;
ax.XRuler.Axle.LineWidth = plot_borderwidth;
ax.YRuler.Axle.LineWidth = plot_borderwidth;

