%% Tab #3
htab3 = uitab(htabgroup, 'Title', 'Lambda');
hax3 = axes('Parent', htab3);

plot_borderwidth = 2;

% %Data Table
% %Get position of subplot and use coordinates to place table
% %Does not work
% hf = figure;
% ha = subplot(2,4,1);
% pos = get(ha,'Position');
% un = get(ha,'Units');
% delete(ha)
% dat =  {'        Throttle Position', mean(LoggedData3(2:end-1, Variable_TP)), min(LoggedData3(2:end-1, Variable_TP)), max(LoggedData3(2:end-1, Variable_TP));...
%         '        RPM', mean(LoggedData3(2:end-1, Variable_RPM)), min(LoggedData3(2:end-1, Variable_RPM)), max(LoggedData3(2:end-1, Variable_RPM));...   
%         '        MAP', mean(LoggedData3(2:end-1, Variable_MAP)), min(LoggedData3(2:end-1, Variable_MAP)), max(LoggedData3(2:end-1, Variable_MAP));...
%         '        Lamdba',  mean(LoggedData3(2:end-1, Variable_TP)), min(LoggedData3(2:end-1, Variable_TP)), max(LoggedData3(2:end-1, Variable_TP));...
%         '        Engine Temp', mean(LoggedData3(2:end-1, Variable_ET)), min(LoggedData3(2:end-1, Variable_ET)), max(LoggedData3(2:end-1, Variable_ET));...
%         '        Oil Temp', mean(LoggedData3(2:end-1, Variable_OT)),min(LoggedData3(2:end-1, Variable_OT)),max(LoggedData3(2:end-1, Variable_OT));};
% columnname =   {'Channel', 'Average', 'Min', 'Max'};
% columnformat = {'char', 'char', 'char', 'char'}; 
% t = uitable('Units','normalized','Position',...
%             pos, 'Data', dat,... 
%             'ColumnName', columnname,...
%             'ColumnFormat', columnformat,...
%             'RowName',[]);
% set(t,'ColumnWidth',{150, 100, 50, 50})


%Plot Lambda Histogram
subplot(2,4,1)
edges_lambda = [0.5 0.5:0.05:1.5 1.5]; % 5.211 is max value LSU 4.9 provides
graph_hist_lambda = histogram(LoggedData3(:,Variable_Lambda),edges_lambda);
% hist_lambda.Normalization = 'countdensity';
% yt = get(gca,'YTick');
% set(gca,'YTickLabel',sprintf('%1.0f\n',yt));
% curtick = get(gca, 'YTick');
% set(gca, 'YTickLabel', cellstr(num2str(curtick(:))));
ax = gca;
ax.YRuler.Exponent = 0;
grid on
% title('Lambda Count Density')
xlabel('Lambda')
ylabel('Count')
ax.XRuler.Axle.LineWidth = plot_borderwidth;
ax.YRuler.Axle.LineWidth = plot_borderwidth;

%Plot Lambda vs Lambda Target
subplot(2,4,[5 8])
graph_plot_lambda = plot(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_Lambda),...
    LoggedData3(:,Variable_Time),LoggedData3(:,Variable_LambdaAim));
graph_plot_lambda(1).LineWidth = 0.25;
graph_plot_lambda(2).LineWidth = 0.5;
set(gca,'YLim',[0.6 2])
grid on
% title('Lambda Count Density')
xlabel('Time (s)')
ylabel('Lambda')
ax.XRuler.Axle.LineWidth = plot_borderwidth;
ax.YRuler.Axle.LineWidth = plot_borderwidth;
% c = get(graph_plot_lambda,'Color'); % Get graph colors
set(gca, 'Color', 'k')
legend('\color[rgb]{0 0.447 0.741} Lambda Aim','\color{red} Lambda Desired', 'Location', 'SouthEast')

%Plot Over Run Fuel Cuts
subplot(2,4,[2 4])
[axh, hLine1, hLine2] = plotyy(OverRunSamples(:,Variable_Time),LoggedData3(:,Variable_RPM),OverRunSamples(:,Variable_Time),LoggedData3(:,Variable_Lambda));
set(axh(1), 'ycolor', 'k')
set(axh(2),'ycolor', 'k')
graph_drivprof_LineWidth = 2;
set(hLine1, 'LineWidth', graph_drivprof_LineWidth);
set(hLine2, 'LineWidth', graph_drivprof_LineWidth);
set(hLine1,'color', 'b');
set(hLine2,'color', 'c');
title('Over-Run Fuel Cuts')
xlabel('Time (s)')
ylabel('RPM')
ylabel(axh(2),'Lambda', 'rotation', 270, 'HorizontalAlignment','center','VerticalAlignment','bottom');
hold(axh(1), 'on');
% hLine3 = plot(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_OT));
% hLine3.LineWidth = graph_temps_LineWidth;
% set(hLine3, 'color', 'r')
grid on
legend('RPM', 'MAP', 'Location', 'SouthEast')
%Set Border Width
ax = gca;
ax.XRuler.Axle.LineWidth = plot_borderwidth;
ax.YRuler.Axle.LineWidth = plot_borderwidth;
