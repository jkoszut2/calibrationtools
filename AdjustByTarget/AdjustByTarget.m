clc;
clear all;

%Select Working Directory
stop = 1;
answer = questdlg('Use Default Directory?', 'Directory Selection', 'Yes', 'No', 'Stop','Yes');
switch answer
    case 'Yes'
        stop = 0;
        dir_Target = 'C:\Users\Demo\Desktop\EngineMATLAB\MoTeC\FuelMapAutoAdjust\Targets';
    case 'No'
        stop = 0;
        dir_Target = uigetdir(path,'Select Lambda Target Directory');
    case 'Stop'
        stop = 1;
    cd(dir_Target);
end

%Get Fuel Table
cd(dir_Target);
Table_IJPU = uigetfile('*.csv','Select MoTeC Fuel Table to Modify');
tablefilename = Table_IJPU;
Table_IJPU = readtable(tablefilename);
Table_IJPU = table2cell(Table_IJPU); %Table to cell array

%Get Target Tables
cd(dir_Target);
%Original Target Table
Table_Target_Original = uigetfile('*.csv','Select Fuel Table Original Lambda Target');
target1filename = Table_Target_Original;
Table_Target_Original = readtable(target1filename);
Table_Target_Original = table2cell(Table_Target_Original); %Table to cell array
%New Target Table
Table_Target_New = uigetfile('*.csv','Select Fuel Table New Lambda Target');
target2filename = Table_Target_New;
Table_Target_New = readtable(target2filename);
Table_Target_New = table2cell(Table_Target_New); %Table to cell array

%IJPU Table Size
tableijpudatasize = size(Table_IJPU);
cols_Table_IJPU = tableijpudatasize(1,2);
rows_Table_IJPU = tableijpudatasize(1,1);
%Target Table Size
tabletargetdatasize = size(Table_Target_Original);
cols_Table_Target = tabletargetdatasize(1,2);
rows_Table_Target = tabletargetdatasize(1,1);

%Cell to Double
Table_IJPU_double = [];
Table_Target_Original_double = [];
Table_Target_New_double = [];
for i = 1:cols_Table_Target-1
    for j = 1:rows_Table_Target
        Table_Target_Original_double(j,i) = cell2mat(Table_Target_Original(j,i));
        Table_Target_New_double(j,i) = cell2mat(Table_Target_New(j,i));
    end
end
for i = 1:cols_Table_IJPU-1
    for j = 1:rows_Table_IJPU-2
        Table_IJPU_double(j,i) = cell2mat(Table_IJPU(j,i));
    end
end

%New IJPU Table Size
tableijpudatasizenew = size(Table_IJPU_double);
cols_Table_IJPU_new = tableijpudatasizenew(1,2);
rows_Table_IJPU_new = tableijpudatasizenew(1,1);
%New Target Table Size
tabletargetdatasizenew = size(Table_Target_Original_double);
cols_Table_Target_new = tabletargetdatasizenew(1,2);
rows_Table_Target_new = tabletargetdatasizenew(1,1);

%Precise Lambda Target Tables
Targetx = Table_IJPU_double(1,10:cols_Table_IJPU_new);    
Targety = Table_IJPU(6:rows_Table_IJPU_new,1)';
%Original Target
gridd = Table_Target_Original_double(2:12,2:end);
colsinput = repelem(Table_Target_Original_double(1,2:cols_Table_Target_new), [rows_Table_Target_new-1], [1]);
rowsinput = repelem(Table_Target_Original_double(2:rows_Table_Target_new,1), [1], [cols_Table_Target_new-1]);
colsinput2 = repelem(Table_IJPU_double(1,10:cols_Table_IJPU_new), length(Table_IJPU_double(6:rows_Table_IJPU_new,1)), [1]);
rowsinput2 = repelem([Table_IJPU_double(6:rows_Table_IJPU_new,1)], [1], length(Table_IJPU_double(1,10:cols_Table_IJPU_new)));
Table_Target_Original_Precise = interp2(colsinput,rowsinput,gridd,colsinput2, rowsinput2);
Table_Target_Original_Precise_Final = zeros(rows_Table_IJPU_new, cols_Table_IJPU_new);
Table_Target_Original_Precise_Final(1,1:cols_Table_IJPU_new) = Table_IJPU_double(1,1:cols_Table_IJPU_new);
Table_Target_Original_Precise_Final(1:rows_Table_IJPU_new,1) = Table_IJPU_double(1:rows_Table_IJPU_new,1);
Table_Target_Original_Precise_Final(6:rows_Table_IJPU_new,10:cols_Table_IJPU_new) = Table_Target_Original_Precise;
%New Target
gridd = Table_Target_New_double(2:12,2:end);
colsinput = repelem(Table_Target_New_double(1,2:cols_Table_Target_new), [rows_Table_Target_new-1], [1]);
rowsinput = repelem(Table_Target_New_double(2:rows_Table_Target_new,1), [1], [cols_Table_Target_new-1]);
colsinput2 = repelem(Table_IJPU_double(1,10:cols_Table_IJPU_new), length(Table_IJPU_double(6:rows_Table_IJPU_new,1)), [1]);
rowsinput2 = repelem([Table_IJPU_double(6:rows_Table_IJPU_new,1)], [1], length(Table_IJPU_double(1,10:cols_Table_IJPU_new)));
Table_Target_New_Precise = interp2(colsinput,rowsinput,gridd,colsinput2, rowsinput2);
Table_Target_New_Precise_Final = zeros(rows_Table_IJPU_new, cols_Table_IJPU_new);
Table_Target_New_Precise_Final(1,1:cols_Table_IJPU_new) = Table_IJPU_double(1,1:cols_Table_IJPU_new);
Table_Target_New_Precise_Final(1:rows_Table_IJPU_new,1) = Table_IJPU_double(1:rows_Table_IJPU_new,1);
Table_Target_New_Precise_Final(6:rows_Table_IJPU_new,10:cols_Table_IJPU_new) = Table_Target_New_Precise;
        
Table_New = Table_IJPU_double;
for i = 10:cols_Table_IJPU_new
    for j = 6:rows_Table_IJPU_new
        Table_New(j,i) = Table_New(j,i) * Table_Target_Original_Precise_Final(j,i)/Table_Target_New_Precise_Final(j,i);
    end
end


copyfile(tablefilename, strcat(char('NEW_LT_'), tablefilename))
newfile = strcat(char('NEW_LT_'), tablefilename);
sheetcols = {'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'; 'I'; 'J'; 'K'; 'L'; 'M'; 'N'; 'O'; 'P'; 'Q'; 'R'; 'S'; 'T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'; 'AA'; 'AB'; 'AC'; 'AD'; 'AE'; 'AF'; 'AG'; 'AH'; 'AI'; 'AJ'; 'AK'; 'AL'; 'AM'; 'AN'; 'AO';};
cellrange = strcat(strcat(sheetcols(1), num2str(3+2)),{':'},strcat(sheetcols(40), num2str(3+23)));
xlswrite(newfile, round(Table_New(2:rows_Table_IJPU_new,2:cols_Table_IJPU_new),1), 1, char(cellrange));


%Plot Settings
fontsz = 8;

%Plot Old Fuel Table
subplot(1,3,1)
surf(Table_IJPU_double(1,2:cols_Table_IJPU_new), Table_IJPU_double(2:rows_Table_IJPU_new,1), Table_IJPU_double(2:rows_Table_IJPU_new,2:cols_Table_IJPU_new))
% set(gca, 'OuterPosition', [0, 0.58, 0.24, 0.4]) %[width_strt height_strt width height]
title('Old Fuel Table')

%Plot New Fuel Table
subplot(1,3,2)
surf(Table_IJPU_double(1,2:cols_Table_IJPU_new), Table_IJPU_double(2:rows_Table_IJPU_new,1), Table_New(2:rows_Table_IJPU_new,2:cols_Table_IJPU_new))
title('New Fuel Table')
grid on

%Plot Diff Table
TableDiff = Table_New - Table_IJPU_double;
subplot(1,3,3)
surf(Table_New(1,2:cols_Table_IJPU_new), Table_IJPU_double(2:rows_Table_IJPU_new,1), TableDiff(2:rows_Table_IJPU_new,2:cols_Table_IJPU_new))
title('New Minus Old')
grid on

set(gcf, 'position', [10 250 1520 375]);
