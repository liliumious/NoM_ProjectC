subjectNumber = 'CC110033'; % temp, will automate over patients
datapath = 'C:\Users\Lily\Desktop\CamCan\';
currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC\';
outputpath = strcat('subjects\sub',subjectNumber,'\');

%% Make Headmodel
PC_makeHeadmodel_Function(subjectNumber, datapath, currentDirectory);

%% Get Sensor Data
[ft, tlock] = getSourceData_Function(subjectNumber, datapath, currentDirectory);
save([outputpath, 'sensordata'],'ft','tlock')

%% Make Source Model
source = PC_makeSourceModel_Function(subjectNumber, datapath, currentDirectory);

%% Interpolate onto Headmodel
tasknum = 2; % AudVid 600
source_int = source_interpolate(subjectNumber,currentDirectory,tasknum)

%% Visualise Source-level Results
source_int_plot(subjectNumber,currentDirectory,source_int)
