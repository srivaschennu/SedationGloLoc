function batchrun

subjlist = {
    'subj02'
    'subj05'
    'subj06'
    'subj07'
    'subj08'
    'subj09'
    %'subj10'
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

loadpaths

for s = 1:length(subjlist)
    basename = subjlist{s};
    
    %computeic(basename);
    %computedip(basename);
    
    extractcond(basename,{'s_ld','r_ld'});
end