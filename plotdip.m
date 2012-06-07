function plotdip(subjlist,condlist,latency)

loadpaths

timeshift = 0.6;
numcomps = 10;

load conds.mat

if ischar(subjlist)
    subjlist = {subjlist};
elseif isempty(subjlist)
    subjlist = {
        'subj02'
        'subj05'
        'subj06'
        'subj07'
        'subj08'
        'subj09'
        'subj10'
        'subj13'
        'subj16'
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
        conddata{s,c} = pop_select(EEG,'trial',selectepochs);
        conddata{s,c}.setname = [conddata{s,c}.setname '_' condlist{c}];
        
        figure; maincomps = pop_envtopo(conddata{s,c}, [EEG.times(1) EEG.times(end)] ,'limcontrib',(timeshift+latency)*1000,'compsplot',numcomps);
        close(gcf);
        pop_dipplot(conddata{s,c},maincomps(1:numcomps),...
        'mri',conddata{s,c}.dipfit.mrifile,'drawedges','on','projimg','on','projlines','on','normlen','on');
        saveas(gcf,sprintf('figures/%s_%s_dip.fig',subjlist{s},condlist{c}));
        close(gcf);
    end
end