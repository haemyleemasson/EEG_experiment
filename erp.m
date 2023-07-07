clear all; clc; close all;
figpath='/Data/ERP/'; 
filename='erp.mat'
numsub=20;
% use ft_timelockanalysis to compute the ERPs and visualize
if isfile([figpath filename])
    load([figpath filename])
    startsub=size(timelock_social_array,2)+1;
else
    startsub=1;
end
for isub = startsub:numsub
    cd ../Data
    data = load([num2str(isub) '_data' '.mat']); %load preprocessed data. 
    social=[1:39];
    trialsocial=[];
    for i=1:size(social,2)
        index=find(data.trialinfo==social(i));
        trialsocial=[trialsocial; index];
    end
    cfg = [];
    cfg.trials=trialsocial;
    timelock_social = ft_timelockanalysis(cfg, data);
    eeg_ploterp(timelock_social, isub, figpath,'social') %1=social, 2=nonsocial, nothing for all
    timelock_social_array{isub} = timelock_social;
    
    nonsocial=[40:75];
    trialnonsocial=[];
    for i=1:size(nonsocial,2)
        index=find(data.trialinfo==nonsocial(i));
        trialnonsocial=[trialnonsocial; index];
    end
    cfg = [];
    cfg.trials=trialnonsocial;
    timelock_nonsocial = ft_timelockanalysis(cfg, data);
    eeg_ploterp(timelock_nonsocial, isub, figpath,'nonsocial') %1=social, 2=nonsocial, nothing for all
    timelock_nonsocial_array{isub} = timelock_nonsocial;
    
    cfg        = [];
    cfg.layout = 'acticap-64ch-standard2';
    figure
    ft_singleplotER(cfg, timelock_social, timelock_nonsocial);
    legend({'social', 'nonsocial'})
    
    cfg = [];
    timelock_all = ft_timelockanalysis(cfg, data);
    eeg_ploterp(timelock_all, isub, figpath, 'all') %1=social, 2=nonsocial, nothing for all
    timelock_all_array{isub} = timelock_all;
    
    cfg = [];
    cfg.operation = 'subtract';
    cfg.parameter = 'avg';
    difference = ft_math(cfg, timelock_social, timelock_nonsocial);
    eeg_ploterp(difference, isub, figpath, 'diff')
    timelock_difference_array{isub} = difference;
end
%% plot & save grand average topography and global field power
cfg = [];
subtimelock_social = ft_timelockgrandaverage(cfg,timelock_social_array{:});
%save(fullfile(outpath,'avg_erp.mat'),'subtimelock_social','timelock_social_array')
eeg_ploterp(subtimelock_social,'avg',figpath, 'group_social');

cfg = [];
subtimelock_nonsocial = ft_timelockgrandaverage(cfg,timelock_nonsocial_array{:});
%save(fullfile(outpath,'avg_erp.mat'),'subtimelock','timelock_array')
eeg_ploterp(subtimelock_nonsocial,'avg',figpath, 'group_nonsocial');

cfg = [];
subtimelock_all = ft_timelockgrandaverage(cfg,timelock_all_array{:});
%save(fullfile(outpath,'avg_erp.mat'),'subtimelock','timelock_array')
eeg_ploterp(subtimelock_all,'avg',figpath, 'group_all');

cfg = [];
subtimelock_diff = ft_timelockgrandaverage(cfg,timelock_difference_array{:});
%save(fullfile(outpath,'avg_erp.mat'),'subtimelock','timelock_array')
eeg_ploterp(subtimelock_diff,'avg',figpath, 'group_diff');

cfg        = [];
cfg.layout = 'acticap-64ch-standard2';
figure
ft_singleplotER(cfg, subtimelock_social, subtimelock_nonsocial);
legend({'social', 'nonsocial'})

outpath=figpath;
outfile='erp.mat'
save(fullfile(outpath,outfile),'-v7.3','timelock_all_array','timelock_social_array','timelock_nonsocial_array','timelock_difference_array');

