%% Tab #5
htab5 = uitab(htabgroup, 'Title', 'Fuel Efficiency');
hax5 = axes('Parent', htab5);

%Plot Default Filter Counts
cd(dir_Log);
A = readtable(logfilename);
Data = A.Variables;
Names = A.Properties.VariableNames;
rows = size(Data);
rows = rows(1,1);
cols = size(Data);
cols = cols(1,2);

FormattedData = [];
for i = 1:cols
    Name = Names{i}; %Store name of each column in array
    FormattedData(:,i) = str2double(Data(:,i)); %Convert table to array
end

Time = find(strcmpi(A.Properties.VariableNames,'Time')); %Finds column of time data
RPM = find(strcmpi(A.Properties.VariableNames,'EngineRPM')); %Finds column of rpm data
FEPW = find(strcmpi(A.Properties.VariableNames,'FuelEffectivePW')); %Finds column of fuel data
SPS = 1/(FormattedData(5,Time)-FormattedData(4,Time)); %Sampling frequency

MPG = [zeros(rows,1)];
if FEPW ~= 0
    FormattedData(:, cols+1) = FormattedData(:,RPM)/60/2/SPS.*FormattedData(:,FEPW)/1000/60*220/1000*4; %Fuel usage in liters per sample
    FormattedData = [FormattedData zeros(rows,1)]; %Sets up zeros column at end of array
    for a = 2:rows
        if FormattedData(a,Variable_Lambda) < 5.2 %Set variable for max lambda reading
            FormattedData(a,cols+2) = double(FormattedData(a-1,cols+2)) + double(FormattedData(a, cols+1));
        else % Do NOT add calculated fuel usage
            FormattedData(a,cols+2) = double(FormattedData(a-1,cols+2));
        end
        if FormattedData(a,Variable_RPM) > 1500 && FormattedData(a,Variable_WSSFL) > 1
            consumption = FormattedData(a,cols+1) * 60 * SPS; % liters/hour
            speed = (Variable_WSSFL/1.6); % miles/hour
            fuelecon = speed / consumption / 3.785; % miles/gallon
            MPG(a,1) = fuelecon;
        end
    end
%     set(gcf, 'position', [10 50 1400 0750]);
else
    disp('Error: Fuel pulse width not logged. Adjust data logging parameters to include FEPW.')
end
cd(dir_Main);
subplot(3,3,[1 3])
plot(FormattedData(:,Time), FormattedData(:,cols+2));
title('Time vs Fuel Used');
xlabel('Time')
ylabel('Fuel Used')
grid on
subplot(3,3,[4 6])
plot(FormattedData(:,Time), MPG(:,1));
title('Time vs Fuel Economy');
xlabel('Time')
ylabel('Fuel Economy (MPG)')
ylim([0 100])
grid on
subplot(3,3,[7 9])
plot(FormattedData(:,Time), FormattedData(:, RPM));
title('Time vs RPM');
xlabel('Time')
ylabel('RPM')
grid on