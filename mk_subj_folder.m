function mk_subj_folder(initials)
    if exist(['Data','/',initials])
        display('not overwriting');
        return
    else
        mkdir(['Data','/',initials]);
    end
    copyfile('params.m',['Data','/',initials,'/','params','_',initials,'.m'])
    run(['Data','/',initials,'/','params','_',initials,'.m']);
end
