%% Tab #7
htab7 = uitab(htabgroup, 'Title', 'Filter Behavior');
hax7 = axes('Parent', htab7);

% Plot Filtered vs Unfiltered Data
subplot(2,2,1)
plot(LoggedData3(:,1),LoggedData3(:,Variable_TP),'LineWidth',2)
hold on
plot(LoggedData3(:,1),LoggedData3(:,Variable_Filtered_TP))
grid on
title('Throttle Position')
legend('Input Data','Filtered Data')
subplot(2,2,2)
plot(LoggedData3(:,1),LoggedData3(:,Variable_TP_Dot),'LineWidth',2)
hold on
plot(LoggedData3(:,1),LoggedData3(:,Variable_Filtered_TP_Dot))
grid on
title('Throttle Position Dot')
legend('Input Data','Filtered Data')
subplot(2,2,3)
plot(LoggedData3(:,1),LoggedData3(:,Variable_RPM),'LineWidth',2)
hold on
plot(LoggedData3(:,1),LoggedData3(:,Variable_Filtered_RPM))
grid on
title('RPM')
legend('Input Data','Filtered Data')
subplot(2,2,4)
plot(LoggedData3(:,1),LoggedData3(:,Variable_RPM_Dot),'LineWidth',2)
hold on
plot(LoggedData3(:,1),LoggedData3(:,Variable_Filtered_RPM_Dot))
grid on
title('RPM Dot')
legend('Input Data','Filtered Data')
