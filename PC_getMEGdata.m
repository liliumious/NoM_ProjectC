function found = PC_getMEGdata(subjectNumber, datapath, currentDirectory)
    %datapath = 'C:\Users\Justin\Desktop\MEGCanCam';
    %cd('C:\Users\Justin\Dropbox\University_Work\NetworkOfTheMind\NoM_ProjectC')
    cd(currentDirectory);
    megpath = strcat(datapath, '\MEG Resting\sub-', subjectNumber, '\meg\rest_raw.fif');
    %Checking if the files exists
    if (~(exist(megpath, 'file')))
        found = -1; %Indicate file was not found
        return;
    end

    found = ft_read_data(megpath);

    
   
end