%% Funciton
function tlock = getSourceData_Function(subject, datapath, currentDirectory)
    cd(currentDirectory);
    megpath = strcat(datapath, '\MEG Task\sub-', subjectNumber, '\meg\task_raw.fif');
    outputpath = strcat('subjects\sub',subjectNumber,'\');
    
    %Checking if the file exists
    if (~(exist(megpath, 'file')))
        found = -1; %Indicate file was not found
        return;
    end



end