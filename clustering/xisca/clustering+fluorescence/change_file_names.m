function change_file_names(folder)
    files = dir(fullfile(folder, '*.jpg'));
    
    for i = 1:length(files)
        oldName = files(i).name;
        newName = strrep(oldName, '_1000_SK1_Mata_red_', '_NBred_');
        
        if ~strcmp(oldName, newName)
            movefile(fullfile(folder, oldName), fullfile(folder, newName));
        end
    end

    for i = 1:length(files)
        oldName = files(i).name;
        newName = strrep(oldName, '_1000_SK1_Mata+Matalpha_TL10.9_', '_brightfield_');
        
        if ~strcmp(oldName, newName)
            movefile(fullfile(folder, oldName), fullfile(folder, newName));
        end
    end

    for i = 1:length(files)
        oldName = files(i).name;
        newName = strrep(oldName, '_1000_SK1_Matalpha_blue_', '_FDAblue_');
        
        if ~strcmp(oldName, newName)
            movefile(fullfile(folder, oldName), fullfile(folder, newName));
        end
    end
end