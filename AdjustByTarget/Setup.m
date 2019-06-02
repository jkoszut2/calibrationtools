%% Set Working Directories
clc;
clear all;
format shortG

%Set Working Directory
stop = 1;

current_drive = pwd;
current_drive = current_drive(1:3);
prompt = ['>> USER: Enter path to main directory: ' current_drive '\'];
dir_Main = input(prompt,'s');
dir_Main = fullfile(current_drive,dir_Main);

try
    cd(dir_Main);
    fprintf('>> Path exists!\n');
catch ME
    fprintf('>> Path does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

prompt = ['>> USER: Enter path to fuel table directory: ' current_drive '\'];
dir_Fuel = input(prompt,'s');
dir_Fuel = fullfile(current_drive,dir_Fuel);

try
    cd(dir_Fuel);
    fprintf('>> Path exists!\n');
catch ME
    fprintf('>> Path does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

prompt = ['>> USER: Enter path to fuel table directory: ' current_drive '\'];
dir_Target = input(prompt,'s');
dir_Target = fullfile(current_drive,dir_Target);

try
    cd(dir_Target);
    fprintf('>> Path exists!\n');
catch ME
    fprintf('>> Path does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

%%
%Import Tables

%Get Fuel Table
cd(dir_Fuel);
Table_IJPU = uigetfile('*.csv','Select MoTeC Fuel Table to Modify');
tablefilename = Table_IJPU;
Table_IJPU = readtable(tablefilename);
Table_IJPU = table2cell(Table_IJPU); %Table to cell array

%Get Target Tables
cd(dir_Target);
%Original Target Table
Table_Target_Original = uigetfile('*.csv','Select Original Lambda Target');
target1filename = Table_Target_Original;
Table_Target_Original = readtable(target1filename);
Table_Target_Original = table2cell(Table_Target_Original); %Table to cell array
%New Target Table
Table_Target_New = uigetfile('*.csv','Select New Lambda Target');
target2filename = Table_Target_New;
Table_Target_New = readtable(target2filename);
Table_Target_New = table2cell(Table_Target_New); %Table to cell array
stop = 0;
cd(dir_Main);

%Check if Files in Correct Format
%sdf

fprintf('>> Files Imported...\n')

if stop == 1
    error('Script Terminated')
end
