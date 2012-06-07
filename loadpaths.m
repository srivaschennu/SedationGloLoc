function loadpaths

[~, hostname] = system('hostname');

if strncmpi(hostname,'hsbpc58',length('hsbpc58'))
    assignin('caller','filepath','/Users/chennu/Data/Sedation GloLoc/');
    assignin('caller','chanlocpath','/Users/chennu/Work/EGI/');
elseif strncmpi(hostname,'hsbpc57',length('hsbpc57'))
    assignin('caller','filepath','D:\Data\Sedation GloLoc\');
    assignin('caller','chanlocpath','D:\EGI\');
else
    assignin('caller','filepath','');
    assignin('caller','chanlocpath','');
end