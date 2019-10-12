%% Set Working Directories
clc;
clear all;
format shortG

%Set Working Directory
stop = 1;

dir_Main = pwd;

try
    cd(dir_Main);
    fprintf('>> Main directory exists!\n');
catch ME
    fprintf('>> Path does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

dir_Fuel = '..\Logs';

try
    cd(dir_Fuel);
    dir_Fuel = pwd;
    fprintf('>> Fuel table directory exists!\n');
catch ME
    fprintf('>> Fuel table directory does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

cd(dir_Main);
dir_Log = '..\Logs\106motecdata';

try
    cd(dir_Log);
    dir_Log = pwd;
    fprintf('>> Logs directory exists!\n');
catch ME
    fprintf('>> Logs directory does not exist!\n');
    input('>> USER: Press enter to exit...');
    error('>> Script terminated.');
end

cd(dir_Main);

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

if stop == 1
    error('Script Terminated')
end

cd(dir_Main);
%Check if Files in Correct Format
%sdf

fprintf('>> Files Imported...\n')
