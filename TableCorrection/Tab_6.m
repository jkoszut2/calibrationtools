%% Tab #6
htab6 = uitab(htabgroup, 'Title', 'Statistics');
hax6 = axes('Parent', htab6);

%Plot Default Filter Counts
subplot(2,2,1)
% Create loop to make below be dynamic
count_default = [935; 538; 1658; 1972; 19; 11; 4517; 18; 2469; 11666; 2284; 18; 1359];
bar(count_default');
title('Default Filters')
% count_names = {'count_AE'; 'count_DE'; 'count_et'; 'count_gfp'; 'count_lambda';...
%     'count_offset'; 'count_offset_AEDE'; 'count_tp'; 'count_rpm'; 'count_rpmdot';...
%     'count_start'; 'count_tp'; 'count_tpdot'};
% set(gca,'TickLabelInterpreter','none')
count_names = {'count\_AE'; 'count\_DE'; 'count\_et'; 'count\_gfp'; 'count\_lambda';...
    'count\_offset'; 'count\_offset\_AEDE'; 'count\_tp'; 'count\_rpm'; 'count\_rpmdot';...
    'count\_start'; 'count\_tp'; 'count\_tpdot'}; % Or use above 2
set(gca,'xticklabel',count_names);
xtickangle(90)
grid on
txt = 'WARNING: Example Data Being Used!';
plotText = text(2,7000,txt);
plotText.FontSize = 14;

% Plot User Filter Counts
subplot(2,2,2)
bar(count_all');
title('Basic Filters')
set(gca,'xticklabel',count_names);
xtickangle(90)
grid on
