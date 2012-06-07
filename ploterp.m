function ploterp(subjlist,condlist,varargin)

loadpaths

load conds.mat

timeshift = 600; %milliseconds

if ~isempty(varargin) && ~isempty(varargin{1})
    ylim = varargin{1};
else
    ylim = [-15 15];
end

if ischar(subjlist)
    subjlist = {subjlist};
elseif isempty(subjlist)
    subjlist = {
       'subj02'
       'subj05'
        %'subj06' %non
        %'subj07' %non
        %'subj08' %non
       'subj09'
       'subj13'
        %'subj16' %non
        'subj17'
        'subj18'
        'subj20'
        'subj22'
        'subj23'
        'subj24'
        'subj26'
        'subj27'
        'subj28'
        'subj29'
        };
end

conddata = cell(length(subjlist),length(condlist));

for s = 1:length(subjlist)
    EEG = pop_loadset('filename', sprintf('%s.set', subjlist{s}), 'filepath', filepath);
    
    if s == 1
        gaerp = zeros(EEG.nbchan,EEG.pnts,length(condlist));
    end
    
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
        gaerp(:,:,c) = gaerp(:,:,c) + erpdata;
        
        conddata{s,c} = pop_select(EEG,'trial',1);
        conddata{s,c}.setname = [conddata{s,c}.setname '_' condlist{c}];
        conddata{s,c}.data = erpdata;
        pop_saveset(conddata{s,c},'filepath',filepath,'filename',[conddata{s,c}.setname '.set']);
    
    end
    
    
    diffdata = conddata{s,1};
    diffdata.data = conddata{s,2}.data-conddata{s,1}.data;
    diffdata.setname = sprintf('%s-%s',conddata{s,2}.setname,condlist{1});
    pop_saveset(diffdata,'filepath',filepath,'filename',[diffdata.setname '.set']);

end
gaerp = gaerp ./ length(subjlist);

for c = 1:length(condlist)
    
    gaset = conddata{1,c};
    gaset.data = gaerp(:,:,c);
    gaset.setname = condlist{c};
    pop_saveset(gaset,'filepath',filepath,'filename',[gaset.setname '.set']);

    plotdata = gaerp(:,:,c);
    
    pntshift = find(min(abs(EEG.times - timeshift)) == abs(EEG.times - timeshift));
    [maxval, maxidx] = max(abs(plotdata(:,pntshift:end)),[],2);
    [~, maxmaxidx] = max(maxval);
    plottime = EEG.times(pntshift-1+maxidx(maxmaxidx));
    if plottime == EEG.times(end)
        plottime = EEG.times(end-1);
    end
    
    figure('Name',condlist{c},'Color','white');
    timtopo(plotdata,EEG.chanlocs,...
        'limits',[EEG.times(1)-timeshift EEG.times(end)-timeshift, ylim],...
        'plottimes',plottime-timeshift);
end

gadiff = gaset;
gadiff.data = gaerp(:,:,2)-gaerp(:,:,1);
gadiff.setname = sprintf('%s-%s',condlist{2},condlist{1});
pop_saveset(gadiff,'filepath',filepath,'filename',[gadiff.setname '.set']);
    


if length(subjlist) == 1
    evalin('base','eeglab redraw');
    for c = 1:length(conddata)
        assignin('base','EEG',conddata{c});
        evalin('base','[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG,EEG);');
    end
    evalin('base','eeglab redraw');
end