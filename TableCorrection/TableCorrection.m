%%
%Define Limits
answer = questdlg('Choose Filter Settings','Settings', 'Default', 'Basic', 'Custom', 'Default');
switch answer
    case 'Default'
        %Limits
        Lim_RPM = [2000 16000];
        Lim_TP = [0 100];
        Lim_Lambda = [0 5.211];
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
    case 'Custom'
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
        case 'Basic'
        %Limits
        Lim_RPM = [000 16000]; % [2000 16000]
        Lim_TP = [0 100];
        Lim_Lambda = [0 5.211];
        Lim_EngineTemp = [0 130]; % [0 120]
        Lim_FuelPressure_Gauge = [35 50]; % [40 45]
        Lim_TP_Dot = [200]; % 50
        Lim_Transient_Offset = [0.05]; % [0.25]
        Lim_RPM_Dot = [2000]; % 350
        %Calculation Parameters
        Bound_IJPU = 4;
        Lim_IJPU = 10;
        Bound_Divider = 5;
        Bound_Gain = 8;
        %Moving Average Filter Constants
        time_constant_throttle = 0.15;
        time_constant_rpm = 1.5; % 0.5
    case ''
        fprintf('>> Terminated Script\n')
        return
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
Variable_FT = find(strcmpi(LoggedData.Properties.VariableNames,'FuelTemp'));
Variable_OT = find(strcmpi(LoggedData.Properties.VariableNames,'EngOilTemp'));
Variable_FP_abs = find(strcmpi(LoggedData.Properties.VariableNames,'FuelPressureSense'));
Variable_AE = find(strcmpi(LoggedData.Properties.VariableNames,'FuelAccel'));
Variable_DE = find(strcmpi(LoggedData.Properties.VariableNames,'FuelDecel'));
Variable_StartComp = find(strcmpi(LoggedData.Properties.VariableNames, 'FuelStartingComp'));
Variable_La1ST = find(strcmpi(LoggedData.Properties.VariableNames,'La1ShortTrim'));
Variable_La1LT = find(strcmpi(LoggedData.Properties.VariableNames,'La1LongTrim'));
Variable_WSSFL = find(strcmpi(LoggedData.Properties.VariableNames,'GroundSpeedLeft'));

SPS = 1/(LoggedData3(5,Variable_Time)-LoggedData3(4,Variable_Time)); %Sampling frequency
Transient_Offset = round(Lim_Transient_Offset * SPS); %Sample offset to remove transients

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


fprintf('>> Filtering Samples...\n');

%Find Samples Within Defined Limits
count_rpm = 0;
count_lambda = 0;
count_et = 0;
count_gfp = 0;
count_tp = 0;
count_AE = 0;
count_DE = 0;
count_start = 0;
count_rpmdot = 0;
count_tpdot = 0;
count_offset = 0;
count_offset_AEDE = 0;
count_offset_TP = 0;

LoggedData4 = [];
for k = 1:rows_LoggedData
    checksum = 0;
    if length(find(LoggedData3(k,Variable_RPM) >= Lim_RPM(1) & LoggedData3(k,Variable_RPM) <= Lim_RPM(2))) == 1
    else
        count_rpm = count_rpm + 1;
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_Lambda) >= Lim_Lambda(1) & LoggedData3(k,Variable_Lambda) <= Lim_Lambda(2))) == 1   
    else
        count_lambda = count_lambda + 1;
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_ET) >= Lim_EngineTemp(1) & LoggedData3(k,Variable_ET) <= Lim_EngineTemp(2))) == 1
    else
        count_et = count_et + 1;  
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_GFP) >= Lim_FuelPressure_Gauge(1) & LoggedData3(k,Variable_GFP) <= Lim_FuelPressure_Gauge(2))) == 1
    else
        count_gfp = count_gfp + 1;
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_TP) >= Lim_TP(1) & LoggedData3(k,Variable_TP) <= Lim_TP(2))) == 1
    else
        count_tp = count_tp + 1;
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_AE) == 0)) == 1
    else
        count_AE = count_AE + 1;
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_DE) == 0)) == 1
    else
        count_DE = count_DE + 1;
        checksum = checksum + 1;
    end
    if length(find(LoggedData3(k,Variable_StartComp) == 0)) == 1
    else
        count_start = count_start + 1;
        checksum = checksum + 1;
    end
    if length(find(abs(LoggedData3(k,Variable_Filtered_RPM_Dot)) < Lim_RPM_Dot)) == 1
    else
        count_rpmdot = count_rpmdot + 1;
        checksum = checksum + 1;
    end
    if length(find(abs(LoggedData3(k,Variable_Filtered_TP_Dot)) < Lim_TP_Dot)) == 1
    else
        count_tpdot = count_tpdot + 1;  
        checksum = checksum + 1;
    end
%                                                 Filter based on proximity to Transient Conditions
    if k > Transient_Offset && k < rows_LoggedData3 - Transient_Offset
    else
        count_offset = count_offset + 1;
        checksum = checksum + 1;
    end
    if k < (rows_LoggedData - Transient_Offset) && k > Transient_Offset && isempty(find(LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_AE)...
            > 0 | LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_DE) < 0, 1))
        % need <> Transient_Offset so k stays positive integer or logical value
    else
        count_offset_AEDE = count_offset_AEDE + 1;
        checksum = checksum + 1;
    end
    if k < (rows_LoggedData - Transient_Offset) && k > Transient_Offset && isempty(find(abs(LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_TP_Dot))...
            > Lim_TP_Dot, 1))  % need <> Transient_Offset so k stays positive integer or logical value
    else
        count_offset_TP = count_offset_TP + 1;
        checksum = checksum + 1;
    end
    % Add/NaN Data
    if checksum == 0
        LoggedData4(k,:) = LoggedData3(k,:);
    else
        LoggedData4(k,1:cols_LoggedData3) = nan;
    end
end    

%Use below for quicker computation but will not provide global filter counts
% for k = 1:rows_LoggedData
%     if length(find(LoggedData3(k,Variable_RPM) >= Lim_RPM(1) & LoggedData3(k,Variable_RPM) <= Lim_RPM(2))) == 1
%         if length(find(LoggedData3(k,Variable_Lambda) >= Lim_Lambda(1) & LoggedData3(k,Variable_Lambda) <= Lim_Lambda(2))) == 1   
%             if length(find(LoggedData3(k,Variable_ET) >= Lim_EngineTemp(1) & LoggedData3(k,Variable_ET) <= Lim_EngineTemp(2))) == 1
%                 if length(find(LoggedData3(k,Variable_GFP) >= Lim_FuelPressure_Gauge(1) & LoggedData3(k,Variable_GFP) <= Lim_FuelPressure_Gauge(2))) == 1
%                     if length(find(LoggedData3(k,Variable_TP) >= Lim_TP(1) & LoggedData3(k,Variable_TP) <= Lim_TP(2))) == 1
%                         if length(find(LoggedData3(k,Variable_AE) == 0)) == 1
%                             if length(find(LoggedData3(k,Variable_DE) == 0)) == 1
%                                 if length(find(LoggedData3(k,Variable_StartComp) == 0)) == 1
%                                     if length(find(abs(LoggedData3(k,Variable_Filtered_RPM_Dot)) < Lim_RPM_Dot)) == 1
%                                         if length(find(abs(LoggedData3(k,Variable_Filtered_TP_Dot)) < Lim_TP_Dot)) == 1
% %                                                 Filter based on proximity to Transient Conditions
%                                             if k > Transient_Offset && k < rows_LoggedData3 - Transient_Offset
%                                                 if isempty(find(LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_AE) > 0 | LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_DE) < 0, 1))
%                                                     if isempty(find(abs(LoggedData3(int16(k-Transient_Offset):int16(k+Transient_Offset),Variable_TP_Dot)) > Lim_TP_Dot, 1))
%                                                         LoggedData4(k,:) = LoggedData3(k,:);
%                                                     else
%                                                         LoggedData4(k,1:cols_LoggedData3) = nan;
%                                                         count_offset_TP = count_offset_TP + 1;
%                                                     end
%                                                 else
%                                                     LoggedData4(k,1:cols_LoggedData3) = nan;
%                                                     count_offset_AEDE = count_offset_AEDE + 1;
%                                                 end
%                                             else
%                                                 LoggedData4(k,1:cols_LoggedData3) = nan;
%                                                 count_offset = count_offset + 1;
%                                             end
%                                         else
%                                             LoggedData4(k,1:cols_LoggedData3) = nan;
%                                             count_tpdot = count_tpdot + 1;        
%                                         end
%                                     else
%                                         LoggedData4(k,1:cols_LoggedData3) = nan;
%                                         count_rpmdot = count_rpmdot + 1;
%                                     end
%                                 else
%                                     LoggedData4(k,1:cols_LoggedData3) = nan;
%                                     count_start = count_start + 1;
%                                 end
%                             else
%                                 LoggedData4(k,1:cols_LoggedData3) = nan;
%                                 count_DE = count_DE + 1;
%                             end
%                         else
%                             LoggedData4(k,1:cols_LoggedData3) = nan;
%                             count_AE = count_AE + 1;
%                         end
%                     else
%                         LoggedData4(k,1:cols_LoggedData3) = nan;
%                         count_tp = count_tp + 1;
%                     end
%                 else
%                     LoggedData4(k,1:cols_LoggedData3) = nan;
%                     count_gfp = count_gfp + 1;
%                 end
%             else
%                 LoggedData4(k,1:cols_LoggedData3) = nan;
%                 count_et = count_et + 1;                
%             end
%         else
%             LoggedData4(k,1:cols_LoggedData3) = nan;
%             count_lambda = count_lambda + 1;
%         end
%     else
%         LoggedData4(k,1:cols_LoggedData3) = nan;
%         count_rpm = count_rpm + 1;
%     end
% end 

count_all = [count_AE; count_DE; count_et; count_gfp; count_lambda;...
    count_offset; count_offset_AEDE; count_tp; count_rpm; count_rpmdot;...
    count_start; count_tp; count_tpdot];

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

% Calculate New Channels For Plots

% Over-Run Fuel Cut
OverRunSamples = [];
for k = 1:rows_LoggedData
    if length(find(LoggedData3(k,Variable_RPM) >= 6000 & LoggedData3(k,Variable_RPM) <= Lim_RPM(2) ...
    & LoggedData3(k,Variable_Filtered_TP) < 30 ...
    & LoggedData3(k,Variable_Lambda) > 4)) == 1
                    OverRunSamples(k,:) = LoggedData3(k,:);
    else
        OverRunSamples(k,1:cols_LoggedData3) = nan;
    end
end
%%
OverRunSamplesRanges = [];
k = 1;
while k < rows_LoggedData - 50
    if length(find(isnan(OverRunSamples(k,Variable_RPM)))) == 0
        first = k;
        k = k+1;
        while length(find(isnan(OverRunSamples(k,Variable_RPM)))) == 0
            k = k+1;
        end
        second = k;
        add = [first second];
        OverRunSamplesRanges = [OverRunSamplesRanges; add];
    end
    k = k+1;
end
% plot(LoggedData3(1583:1595,Variable_Time),LoggedData3(1583:1595,Variable_Lambda))


%%
%Plot Settings
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
title('Logged Data')
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

% Introduce Tab #2
htab2 = uitab(htabgroup, 'Title', 'IJPU Convergence');
hax2 = axes('Parent', htab2);
% Plot Convergence Table
floor = 20;
count = 0;
for i = 2:length(Fuelx)
    for j = 1:length(Fuely)
        DataMatrix = Data_Table{j,i,2};
        Size_DataMatrix = size(DataMatrix);
        rows_DataMatrix = Size_DataMatrix(1);
        if rows_DataMatrix > floor
            count = count + 1;
        end
    end
end

n = sqrt(count);
n = n+0.5;
n = round(n,0);
subplotcounter = 1;
for i = 2:length(Fuelx)
    for j = 1:length(Fuely)
        DataMatrix = Data_Table{j,i,2};
        Size_DataMatrix = size(DataMatrix);
        rows_DataMatrix = Size_DataMatrix(1);
            if rows_DataMatrix > floor
                subplot(n,n,subplotcounter)
                plot(1:rows_DataMatrix,DataMatrix(:,1),1:rows_DataMatrix,DataMatrix(:,3));
                name_title = char(strcat(num2str(Fuelx(i-1)),{' '},{'rpm'},{' '},num2str(Fuely(j)),{' '},{'bar'}));
                title(name_title)
                subplotcounter = subplotcounter + 1;
                grid on
            end
    end
end

% Introduce Tab #3
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

% Introduce Tab #4
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
ylabel('Temperature (C)')
ylabel(axh(2),'Temperature (C)', 'rotation', 270, 'HorizontalAlignment','center','VerticalAlignment','bottom');
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
topline = refline(axh(1),0,axh(1).YLim(2));
topline.LineWidth = 2;
topline.Color = 'k';
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


% Introduce Tab #5
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

% Introduce Tab #6
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

% Plot User Filter Counts
subplot(2,2,2)
bar(count_all');
title('Basic Filters')
set(gca,'xticklabel',count_names);
xtickangle(90)
grid on



% Remove and replace with fill screen / autosize
% set(gcf, 'position', [1 42 1600 750]);