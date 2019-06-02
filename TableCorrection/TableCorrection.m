%%
%Define Limits
answer = questdlg('Use Default Settings?','Settings', 'Yes', 'No','Yes');
switch answer
    case 'Yes'
        %Limits
        Lim_RPM = [2000 16000];
        Lim_TP = [0 100];
        Lim_Lambda = [0 5];
        Lim_EngineTemp = [0 120];
        Lim_FuelPressure_Gauge = [40 45];
        Lim_TP_Dot = [50];
        Lim_Transient_Offset = [0.25];
        Lim_RPM_Dot = [350];
        %Calculation Parameters
        Bound_IJPU = 4;
        Lim_IJPU = 10;
        Bound_Divider = 5;
        Bound_Gain = 8;
        %Moving Average Filter Constants
        time_constant_throttle = 0.15;
        time_constant_rpm = 0.5;
    case 'No'
        %Limits
        prompt2 = {'Min RPM:', 'Max RPM:', 'Min Throttle Position', 'Max Throttle Position', 'Min Lambda', 'Max Lambda', 'Min Engine Temp', 'Max Engine Temp', 'Min Fuel Pressure', 'Max Fuel Pressure', 'Max TP/sec', 'Transient Offset', 'Max RPM/sec'};
        dlg_title2 = 'Input Filter Variables';
        num_lines2 = 1;
        defaultans2 = {'2000', '16000','0','100','0','5','0','120','40', '45', '50', '0.25','350'};
        ParameterInputs2 = inputdlg(prompt2,dlg_title2,num_lines2,defaultans2);
        Lim_RPM = [str2double(ParameterInputs2(1)) str2double(ParameterInputs2(2))];
        Lim_TP = [str2double(ParameterInputs2(3)) str2double(ParameterInputs2(4))];
        Lim_Lambda = [str2double(ParameterInputs2(5)) str2double(ParameterInputs2(6))];
        Lim_EngineTemp = [str2double(ParameterInputs2(7)) str2double(ParameterInputs2(8))];
        Lim_FuelPressure_Gauge = [str2double(ParameterInputs2(9)) str2double(ParameterInputs2(10))];
        Lim_TP_Dot = [str2double(ParameterInputs2(11))];
        Lim_Transient_Offset = [str2double(ParameterInputs2(12))];
        Lim_RPM_Dot = [str2double(ParameterInputs2(13))];
        %Calculation Parameters
        prompt = {'Bound_IJPU:', 'Lim_IJPU', 'Bound Divider:', 'Gain:'};
        dlg_title = 'Input Calculation Parameters';
        num_lines = 1;
        defaultans = {'4','10','5','8'};
        ParameterInputs = inputdlg(prompt,dlg_title,num_lines,defaultans);
        Bound_IJPU = str2double(ParameterInputs(1)); %Maximum allowable delta to use for single sample
        Bound_Divider = str2double(ParameterInputs(3)); %Divides empty region between cells
        Bound_Gain = str2double(ParameterInputs(4)); %Percent of difference that gets applied
        Lim_IJPU = str2double(ParameterInputs(2)); %Max allowable fuel table change from all samples
        %Filter Contstants
        prompt = {'TP Time Constant (sec):', 'RPM Time Constant (sec):'};
        dlg_title = 'Input Filter Time Constants';
        num_lines = 1;
        defaultans = {'0.15','0.5'};
        ParameterInputs3 = inputdlg(prompt,dlg_title,num_lines,defaultans);
        time_constant_throttle = str2double(ParameterInputs3(1)); %TP TC
        time_constant_rpm = str2double(ParameterInputs3(2)); %RPM TC
end


tic
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
%Import Fuel Table and Convert to Cell Array
tablefilename = Fuel;
cd(dir_Fuel);
OldFuelTable = readtable(tablefilename);
OldFuelTable2 = table2cell(OldFuelTable); %Converts fuel table from table to cell array

%Import Log File and Convert to Cell Array
logfilename = Log;
cd(dir_Log);
LoggedData = readtable(logfilename);
LoggedData2 = LoggedData.Variables; %Converts logged data from table to cell array

%Back to tables directory
cd(dir_Main);

fprintf('>> Sorting Logged Data...\n')

%Find Header Names of Logged Channels and Store Respective Column Numbers
Names = LoggedData.Properties.VariableNames; %Header names of logged data
%Create Loop To Check If Correct Parameters Logged
LoggedDataSize = size(LoggedData2);
cols_LoggedData = LoggedDataSize(1,2);

%Convert Logged Data to double array
LoggedData3 = [];
for i = 1:cols_LoggedData
    LoggedData3(:,i) = str2double(LoggedData2(:,i)); %Convert cell to double
end

%Find Column Number from Logged Data
Variable_Time = find(strcmpi(LoggedData.Properties.VariableNames,'Time'));
Variable_RPM = find(strcmpi(LoggedData.Properties.VariableNames,'EngineRPM'));
Variable_MAP = find(strcmpi(LoggedData.Properties.VariableNames,'ManifoldPres'));
Variable_TP = find(strcmpi(LoggedData.Properties.VariableNames,'ThrottlePos'));
Variable_FBPW = find(strcmpi(LoggedData.Properties.VariableNames,'FuelBasePW'));
Variable_FEPW = find(strcmpi(LoggedData.Properties.VariableNames,'FuelEffectivePW'));
Variable_Lambda = find(strcmpi(LoggedData.Properties.VariableNames,'Lambda1'));
Variable_LambdaAim = find(strcmpi(LoggedData.Properties.VariableNames,'Lambda1Aim'));
Variable_ET = find(strcmpi(LoggedData.Properties.VariableNames,'EngineTemp'));
Variable_FP_abs = find(strcmpi(LoggedData.Properties.VariableNames,'FuelPressureSense'));
Variable_AE = find(strcmpi(LoggedData.Properties.VariableNames,'FuelAccel'));
Variable_DE = find(strcmpi(LoggedData.Properties.VariableNames,'FuelDecel'));
Variable_StartComp = find(strcmpi(LoggedData.Properties.VariableNames, 'FuelStartingComp'));
Variable_La1ST = find(strcmpi(LoggedData.Properties.VariableNames,'La1ShortTrim'));
Variable_La1LT = find(strcmpi(LoggedData.Properties.VariableNames,'La1LongTrim'));

SPS = 1/(LoggedData3(5,Variable_Time)-LoggedData3(4,Variable_Time)); %Sampling frequency
Transient_Offset = Lim_Transient_Offset * SPS; %Sample offset to remove transients

%Calculate IJPU
rows_LoggedData = LoggedDataSize(1,1);
IJPU = zeros(rows_LoggedData,1);
Variable_IJPU = cols_LoggedData+1;
for i = 2:rows_LoggedData
    Pulse = LoggedData3(i,Variable_FEPW);
    IJPU = (Pulse*100/7)*(LoggedData3(i,Variable_Lambda)/LoggedData3(i,Variable_LambdaAim)); %Adjust to target
    LoggedData3(i,Variable_IJPU) = IJPU;
end


fprintf('>> Filtering Throttle and RPM...\n')

%Filter Throttle and RPM
if time_constant_throttle*SPS > 0.5
    windowSize_throttle = round(time_constant_throttle*SPS,0);
else
    windowSize_throttle = 1;
    fprintf('>> Throttle time constant is too small. Value was set to %0.5f seconds.\n', windowSize_throttle/SPS)
end
if time_constant_rpm*SPS > 0.5
    windowSize_rpm = round(time_constant_rpm*SPS,0);
else
    windowSize_rpm = 1;
    fprintf('>> RPM time constant is too small. Value was set to %0.5f seconds.\n', windowSize_rpm/SPS)
end
b_throttle = (1/windowSize_throttle)*ones(1,uint16(windowSize_throttle));
b_rpm = (1/windowSize_rpm)*ones(1,uint16(windowSize_rpm));
a = 1;
Variable_Filtered_TP = cols_LoggedData+2;
Variable_Filtered_RPM = cols_LoggedData+3;
LoggedData3(:,Variable_Filtered_TP) = filter(b_throttle,a,LoggedData3(:,Variable_TP));
LoggedData3(:,Variable_Filtered_RPM) = filter(b_rpm,a,LoggedData3(:,Variable_RPM));
%Calulate TP Dot NO filter
Variable_TP_Dot = cols_LoggedData+4;
LoggedData3(2:rows_LoggedData,Variable_TP_Dot) = (LoggedData3(2:rows_LoggedData,Variable_TP)-LoggedData3(1:rows_LoggedData-1,Variable_TP))/(1/SPS);
%Calculate TP Dot with Filter
Variable_Filtered_TP_Dot = cols_LoggedData+5;
LoggedData3(2:rows_LoggedData,Variable_Filtered_TP_Dot) = (LoggedData3(2:rows_LoggedData,Variable_Filtered_TP)-LoggedData3(1:rows_LoggedData-1,Variable_Filtered_TP))/(1/SPS);    
%Calulate RPM Dot NO filter
Variable_RPM_Dot = cols_LoggedData+6;
LoggedData3(2:rows_LoggedData,Variable_RPM_Dot) = (LoggedData3(2:rows_LoggedData,Variable_RPM)-LoggedData3(1:rows_LoggedData-1,Variable_RPM))/(1/SPS);
%Not the ideal spot for this; should be before TP and RPM filtering
%Calculate Gauge Fuel Pressure
GFP = zeros(rows_LoggedData,1);
Variable_GFP = cols_LoggedData+8;
for i = 2:rows_LoggedData
    GaugeFuelPressure = LoggedData3(i,Variable_FP_abs)-(14.68*LoggedData3(i,Variable_MAP));
    LoggedData3(i,Variable_GFP) = GaugeFuelPressure;
end

%Calculate RPM Dot with Filter
Variable_Filtered_RPM_Dot = cols_LoggedData+7;
LoggedData3(2:rows_LoggedData,Variable_Filtered_RPM_Dot) = (LoggedData3(2:rows_LoggedData,Variable_Filtered_RPM)-LoggedData3(1:rows_LoggedData-1,Variable_Filtered_RPM))/(1/SPS);
Size_LoggedData3 = size(LoggedData3);
cols_LoggedData3 = Size_LoggedData3(1,2);
rows_LoggedData3 = Size_LoggedData3(1,1);


fprintf('>> Applying Limits to Samples...\n');

%Find Samples Within Defined Limits
LoggedData4 = [];
for k = 1:rows_LoggedData
    if length(find(LoggedData3(k,Variable_RPM) >= Lim_RPM(1) & LoggedData3(k,Variable_RPM) <= Lim_RPM(2) ...
    & LoggedData3(k,Variable_Lambda) >= Lim_Lambda(1) & LoggedData3(k,Variable_Lambda) <= Lim_Lambda(2) ...
    & LoggedData3(k,Variable_ET) >= Lim_EngineTemp(1) & LoggedData3(k,Variable_ET) <= Lim_EngineTemp(2) ...
    & LoggedData3(k,Variable_GFP) >= Lim_FuelPressure_Gauge(1) & LoggedData3(k,Variable_GFP) <= Lim_FuelPressure_Gauge(2) ...
    & LoggedData3(k,Variable_TP) >= Lim_TP(1) & LoggedData3(k,Variable_TP) <= Lim_TP(2) ...
    & LoggedData3(k,Variable_AE) == 0 & LoggedData3(k,Variable_DE) == 0 ...
    & LoggedData3(k,Variable_StartComp) == 0 ...
    & abs(LoggedData3(k,Variable_Filtered_RPM_Dot)) < Lim_RPM_Dot ...
    & abs(LoggedData3(k,Variable_Filtered_TP_Dot)) < Lim_TP_Dot)) == 1
%             Filter based on proximity to Transient Conditions
        if k > Transient_Offset && k < rows_LoggedData3 - Transient_Offset
            if isempty(find(LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_AE) > 0 | LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_DE) < 0, 1))
                if isempty(find(abs(LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_TP_Dot)) > Lim_TP_Dot, 1))
                    LoggedData4(k,:) = LoggedData3(k,:);
                end
            end
        end
    else
        LoggedData4(k,1:cols_LoggedData3) = nan;
    end
end    
size2 = size(LoggedData4);
rows_LoggedData4 = size2(1);


%Find Fuel Table RPM and MAP entries and Store in Cell
tabledatasize = size(OldFuelTable2);
cols_FuelTable = tabledatasize(1,2);
rows_FuelTable = tabledatasize(1,1);

%Convert Fuel Table to double array
OldFuelTable3 = [];
for i = 1:cols_FuelTable-1
    OldFuelTable3(:,i) = cell2mat(OldFuelTable2(:,i)); %Convert cell to double
end

fprintf('>> Adjusting Fuel Map...\n')

%Create New Fuel Table and Table to Track Sample Count
cd(dir_Fuel);
copyfile(tablefilename, strcat(char('NEW_'), tablefilename))
NewFuelTable = OldFuelTable3;
Data_Table = OldFuelTable2;
Data_Table(:,:,2) = {0};
Fuelx = OldFuelTable3(1,2:cols_FuelTable-1);
Fuely = OldFuelTable3(1:rows_FuelTable-2,1)';
SampleCountTable = zeros(rows_FuelTable, cols_FuelTable);
SampleCountTable(1,2:41) = Fuelx;
SampleCountTable(1:23,1) = Fuely;
PassThroughData = zeros(rows_LoggedData4,cols_LoggedData3);
PassThroughData(1:rows_LoggedData4,1:(cols_LoggedData3)) = nan;
DataPointLocation = zeros(rows_LoggedData4,2);


for i = 1:length(Fuelx)
    if i > 1
        bound_RPM_lower = abs(Fuelx(i)-Fuelx(i-1))/Bound_Divider;
    else
        bound_RPM_lower = 0;
    end
    if i < length(Fuelx)
        bound_RPM_upper = abs(Fuelx(i+1)-Fuelx(i))/Bound_Divider;
    else
        bound_RPM_upper = 500/Bound_Divider;
    end
    for j = 2:length(Fuely)
        DataCheck = [];
        for k = 1:rows_LoggedData4
            bound_MAP_lower = abs(Fuely(j)-Fuely(j-1))/Bound_Divider;
            if j < length(Fuely)
                bound_MAP_upper = abs(Fuely(j+1)-Fuely(j))/Bound_Divider;
            else
                bound_MAP_upper = .1/Bound_Divider;
            end
            %Set general, symmetric RPM and MAP bounds
            if bound_RPM_lower > bound_RPM_upper
                bound_RPM = bound_RPM_upper;
            else
                bound_RPM = bound_RPM_lower;
            end
            if bound_MAP_lower > bound_MAP_upper
                bound_MAP = bound_MAP_upper;
            else
                bound_MAP = bound_MAP_lower;
            end
            %Use sample to adjust fuel table
            if length(find(LoggedData4(k,Variable_RPM) >= Fuelx(i)-bound_RPM & LoggedData4(k,Variable_RPM) <= Fuelx(i)+bound_RPM ...
                    & LoggedData4(k,Variable_MAP) >= Fuely(j)-bound_MAP & LoggedData4(k,Variable_MAP) <= Fuely(j)+bound_MAP)) == 1
                %Find Location of RPM Point
                if LoggedData4(k,Variable_RPM) < Fuelx(i)
                    DataPointLocation(k,1) = 0;
                elseif LoggedData4(k,Variable_RPM) > Fuelx(i)
                    DataPointLocation(k,1) = 1;
                else
                    DataPointLocation(k,1) = 2;
                end
                %Find Location of Pressure Point
                if LoggedData4(k,Variable_MAP) < Fuely(j)
                    DataPointLocation(k,2) = 0;
                elseif LoggedData4(k,Variable_MAP) > Fuely(j)
                    DataPointLocation(k,2) = 1;
                else
                    DataPointLocation(k,2) = 2;
                end
                %Ensure Values Are Not Being Double Counted
                if isnan(PassThroughData(k,:))
                    PassThroughData(k,:) = [LoggedData4(k,:)];
                    SampleCountTable(j,i+1) = SampleCountTable(j,i+1) + 1;
                end
                NewIJPU = LoggedData4(k,cols_LoggedData+1);
                sdf = [k NewIJPU NewFuelTable(j,i+1)];
                DataCheck_A = NewIJPU;
                DataCheck_B = NewFuelTable(j,i+1);
                DataCheck_C = k;
                DataCheck_D = LoggedData4(k,Variable_Lambda);
                DataCheck_E = LoggedData4(k,Variable_LambdaAim);
                DataCheck_F = LoggedData4(k,Variable_IJPU);
                DataCheck_G = LoggedData4(k,Variable_FBPW);
                DataCheck_H = LoggedData4(k,Variable_FEPW);
                DataCheck_I = LoggedData4(k,Variable_RPM);
                DataCheck_J = LoggedData4(k,Variable_MAP);
                DataCheck_K = LoggedData4(k,Variable_Time);
                if abs(NewIJPU - NewFuelTable(j,i+1)) <= Bound_IJPU
                    NewIJPU = NewIJPU;
                elseif NewIJPU - NewFuelTable(j,i+1) > Bound_IJPU
                    NewIJPU = NewFuelTable(j,i+1) + Bound_IJPU;
                else
                    NewIJPU = NewFuelTable(j,i+1) - Bound_IJPU;
                end
                if LoggedData4(k,Variable_MAP) >= Fuely(j)-0.002 && LoggedData4(k,Variable_MAP) <= Fuely(j)+0.002
                    Proximity_Factor = 1;
                else
                    Proximity_Factor = 1;
                end
                NewFuelTable(j,i+1) = NewFuelTable(j,i+1) + (NewIJPU - NewFuelTable(j,i+1))*Bound_Gain/100*Proximity_Factor;
                DataCheck = [DataCheck; DataCheck_A DataCheck_B NewFuelTable(j,i+1) DataCheck_C DataCheck_D ...
                    DataCheck_E DataCheck_F DataCheck_G DataCheck_H DataCheck_I DataCheck_J DataCheck_K];
            end
        end
        Data_Table{j,i+1,2} = DataCheck;
    end

end

%Go Over New Table and Check Limits
for i = 1:length(Fuelx)
    for j = 2:length(Fuely)
        if abs(NewFuelTable(j,i+1) - OldFuelTable3(j,i+1)) > 0
            if NewFuelTable(j,i+1) - OldFuelTable3(j,i+1) > 0
                if NewFuelTable(j,i+1) - OldFuelTable3(j,i+1) > Lim_IJPU
                    NewFuelTable(j,i+1) = OldFuelTable3(j,i+1) + Lim_IJPU;
                else
                    NewFuelTable(j,i+1) = NewFuelTable(j,i+1);
                end
            elseif NewFuelTable(j,i+1) - OldFuelTable3(j,i+1) < 0
                if NewFuelTable(j,i+1) - OldFuelTable3(j,i+1) < -Lim_IJPU
                    NewFuelTable(j,i+1) = OldFuelTable3(j,i+1) - Lim_IJPU;
                else
                    NewFuelTable(j,i+1) = NewFuelTable(j,i+1);
                end
            end
        end
    end
end

newfile = strcat(char('NEW_'), tablefilename);
sheetcols = {'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'; 'I'; 'J'; 'K'; 'L'; 'M'; 'N'; 'O'; 'P'; 'Q'; 'R'; 'S'; 'T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'; 'AA'; 'AB'; 'AC'; 'AD'; 'AE'; 'AF'; 'AG'; 'AH'; 'AI'; 'AJ'; 'AK'; 'AL'; 'AM'; 'AN'; 'AO';};
cellrange = strcat(strcat(sheetcols(1), num2str(3+2)),{':'},strcat(sheetcols(40), num2str(3+23)));
xlswrite(newfile, round(NewFuelTable(2:length(Fuely),2:length((Fuelx))+1),1), 1, char(cellrange));

fprintf('>> New Fuel Map Created Successfully\n')

TotalSamples = sum(sum(SampleCountTable(2:23,2:40)));
fprintf(char(strcat({'>> '}, num2str(TotalSamples),{' '},{'out of'},{' '}, num2str(rows_LoggedData-1), {' '}, {'total samples were used to correct the fuel table...\n'})));
%%
%Plot Settings
fontsz = 8;
cd(dir_Main);

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
subplot(2,4,[5 6 7 8])
ylabels{1}='RPM';
ylabels{2}='RPM';
ylabels{3}='Throttle Position';
ylabels{4}='Throttle Position';
time_constant_throttle = LoggedData3(rows_LoggedData4,1);
plotyyy(LoggedData3(:,Variable_Time),LoggedData3(:,Variable_Filtered_RPM),PassThroughData(:,Variable_Time),PassThroughData(:,Variable_Filtered_RPM),LoggedData3(:,Variable_Time),LoggedData3(:,Variable_TP),PassThroughData(:,Variable_Time),PassThroughData(:,Variable_TP),ylabels,time_constant_throttle);

set(gcf, 'position', [1 42 1600 750]);