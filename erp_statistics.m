% define the parameters for the statistical comparison
clear all; clc; close all;
figpath='/Data/ERP/';
load erp %run erp.m code first
j=2% j=1 for 200 ms average, j=2 for 100 ms average
for i=0:5*j+1
cfg = [];
k=0.2*i/j;
cfg.latency     = [-0.2+k 0+k];
cfg.avgovertime = 'yes';
cfg.parameter   = 'avg';
cfg.method      = 'analytic';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'bonferroni';

Nsub = 20;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
 
stat{i+1} = ft_timelockstatistics(cfg,timelock_social_array{:},timelock_nonsocial_array{:});
mask{i+1}=stat{i+1}.mask;
size(find(stat{i+1}.mask==1),1)
end

cfg = [];
subtimelock_diff = ft_timelockgrandaverage(cfg,timelock_difference_array{:});

%toi = [-0.2 0 0.2 0.4 0.6 0.8 1];
toi = [-0.2:0.1:1];
zmin = -3;
zmax = 3;

% make the plot
for i=1:12
cfg = [];
cfg.commentpos = 'title';
cfg.layout = 'acticap-64ch-standard2';
cfg.xlim = toi(i):0.2/j:toi(i+1);
cfg.avgovertime = 'yes';
cfg.zlim = [zmin zmax];
cfg.colormap='parula';
cfg.comment = 'xlim';
cfg.commentpos = 'title';
cfg.highlight = 'labels'; 
cfg.highlightfontsize=16;
cfg.highlightchannel = find(mask{i});
ft_topoplotER(cfg, subtimelock_diff);
%add colorbar
pos = get(gca,'Position');
title(['Time = [', num2str(cfg.xlim(1)*1000),' ms - ', num2str(cfg.xlim(2)*1000),' ms]'], 'FontSize',20);
colorbar('FontSize',16);
print(gcf,'-dpng','-r300',fullfile(figpath, ['avg_erp_gfp_group_diff_tstats_bonferroni_' num2str(i)]));
fprintf('%f - \n', cfg.xlim);
fprintf('Maximum %s \n', char(stat{1,i}.label(find(stat{1,i}.stat==max(stat{1,i}.stat)))));
fprintf('minimum %s \n', char(stat{1,i}.label(find(stat{1,i}.stat==min(stat{1,i}.stat)))));
end






