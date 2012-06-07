function extractcond(basename,condlist)

loadpaths

load conds.mat

EEG = pop_loadset('filename', sprintf('%s.set', basename), 'filepath', filepath);

%EEG = pop_select(EEG,'channel',1:EEG.nbchan-1);

for c = 1:length(condlist)
    selectevents = conds.(condlist{c});
    
    typematches = false(1,length(EEG.epoch));
    for ep = 1:length(EEG.epoch)
        
        epochtype = EEG.epoch(ep).eventtype;
        if iscell(epochtype)
            epochtype = epochtype{cell2mat(EEG.epoch(ep).eventlatency) == 0};
        end
        
        for e = 1:length(selectevents)
            if strncmp(epochtype,selectevents{e},length(selectevents{e}))
                typematches(ep) = true;
                break;
            end
        end
    end
    
    selectepochs = find(typematches);
    fprintf('Condition %s: found %d matching epochs.\n',condlist{c},length(selectepochs));
    erpdata = mean(EEG.data(:,:,selectepochs),3);
    
    conddata = pop_select(EEG,'trial',1);
    conddata.data = erpdata;
    conddata.setname = [conddata.setname '_' condlist{c}];
    pop_saveset(conddata,'filepath',filepath,'filename',[conddata.setname '.set']);
    
    %save([filepath conddata.setname '.mat'],'erpdata');
end
