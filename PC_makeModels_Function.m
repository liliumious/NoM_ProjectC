
%Running makeHeadmodel & makeSourceModel for all subjects
%TODO: Deal with extracting files
clc;
datapath = 'C:\Users\Justin\Desktop\MEGCanCam';
currentDirectory = 'C:\Users\Justin\Dropbox\University_Work\NetworkOfTheMind\NoM_ProjectC';

file = fopen(strcat(currentDirectory,'\subjectNames.txt'));
currentLine = fgets(file);

%Will return -1 when reaches end of file
while ischar(currentLine)
    %Bypass the makeHeadModel prompts?
    PC_makeHeadmodel_Function(currentLine, datapath, currentDirectory);
    PC_makeSourceModel_Function(currentLine, datapath, currentDirectory);

    currentLine = fgets(file);
end

fclose(file);