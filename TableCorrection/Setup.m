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
dir_Log = input(prompt,'s');
dir_Log = fullfile(current_drive,dir_Log);

try
    cd(dir_Log);
    fprintf('>> Path exists!\n');
catch ME
    fprintf('>> Path does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

%%
%Import Files
answer = questdlg('Select MoTeC fuel table and logged data. Must be in .csv format.', 'File Selection', 'Select Files', 'Stop', 'Select Files');
switch answer
    case 'Select Files'
        stop = 0;
        cd(dir_Fuel);
        Fuel = uigetfile('*.csv','Select MoTeC Fuel Table');
        cd(dir_Log);
        Log = uigetfile('*.csv','Select i2 Log File');
    case 'Stop'
        stop = 1;
end

cd(dir_Main);
%Check if Files in Correct Format
%sdf

fprintf('>> Files Imported...\n')

if stop == 1
    error('Script Terminated')
end
