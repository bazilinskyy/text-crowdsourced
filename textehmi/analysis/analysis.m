% Matlab script built by Joost de Winter and Pavlo Bazilinksyy <pavlo.bazilinskyy@gmail.com>
clear all;close all;clc; %#ok<*CLALL>

%% ************************************************************************
%% Constants
%% ************************************************************************
N_STIMULI = 227;  % number of stimuli
N_PERSON = 80;    % number of stimuli per person

%% ************************************************************************
%% Load config
%% ************************************************************************
config = jsondecode(fileread('../../config'));

%% ************************************************************************
%% Process appen and heroku data from experiment
%% ************************************************************************
% indices to traverse in appen data
appen_indices = [16,... % 1. Instructions understood
    37,... % 2. Gender
    36,... % 3. Age
    14,... % 4. Age of obtaining driver's license
    40,... % 5. Primary mode of transportation
    31,... % 6. How many times in past 12 months did you drive a vehicle
    13,... % 7. Mileage
    17,... % 8. Number of accidents
    9,...  % Country
    18,... % 9. DBQ1
    19,... % 10. DBQ1
    20,... % 11. DBQ2
    21,... % 12. DBQ3
    22,... % 13. DBQ4
    23,... % 14. DBQ5
    24,... % 15. DBQ6
    38,... % 16. Knowledge of English
    39,... % 17. Knowledge of Spanish
    15,... % 18. English 1
    35,... % 19. English 2
    25,... % 20. English 3
    26,... % 21. English 4
    33,... % 22. English 5
    4,...  % 23. Start
    2,...  % 24. End
    8,...  % 321. Worker id
    34];   % worker_code
[X, Country] = process_experiment(config.file_appen, ...
    appen_indices, ...
    config.file_heroku, ...
    N_STIMULI);

%% Rewad mapping of eHMIs
mapping=readtable(config.mapping);

%% ************************************************************************
%% OUTPUT
%% ************************************************************************
RT = X(:, 26:105);  % amount of time used to press the key
% RT(:,1)=[];  % remove the first unneded column
RP = X(:, 106:185);  % response from the slider
imageid = X(:,186:265);  % image ids as shown
eHMI_text=mapping(:,2);  % labels with eHMIs

%% Order based on image number
[RPo,RTo]=deal(NaN(size(RP,1),N_STIMULI));
for i=1:size(RP,1) % loop over pp
    % TODO: check if no matlab logic is broken with conversion from 0 to 1 for index
    RPo(i,imageid(i,:)+1)=RP(i,:);
    RTo(i,imageid(i,:)+1)=RT(i,:);
end

%% Median willingness to cross
opengl hardware
[RPoMed,RPoSTD,RPoMedVE,RPoMedUS,RToMedVE,RToMedUS]=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    RPoMed(i)=nanmedian(RPo(:,i))-nanstd(RPo(:,i))/10^6; % equal medians sorted on SD
    RPoSTD(i)=nanstd(RPo(:,i));
    RPoMedVE(i)=nanmean(RPo(contains(Country,'VE'),i)); % mean for participants from VEN
    RPoMedUS(i)=nanmean(RPo(contains(Country,'US'),i)); % mean for participants from USA
    RToMedVE(i)=nanmedian(RTo(contains(Country,'VE'),i)); % median RT participants from VEN
    RToMedUS(i)=nanmedian(RTo(contains(Country,'US'),i)); % median RT participants from USA
end
%% Slider rating USA/VEN
figure;hold on;grid on
clear h; % empty h object to store colour for the legend
for i=1:180 % English eHMIs
    scatter1 = scatter(RPoMedUS(i), RPoMedVE(i), mapping{i,3}*20, ...
        'markerfacecolor', 'k', ...
        'markeredgecolor', 'none');
    scatter1.MarkerFaceAlpha = 0.3;
    h(1) = scatter1(1); % store 1st object for the colour in the legend
end
for i=181:227 % Spanish eHMIs
    scatter2 = scatter(RPoMedUS(i), RPoMedVE(i), mapping{i,3}*20, ...
        'markerfacecolor', 'r', ...
        'markeredgecolor', 'none');
    scatter2.MarkerFaceAlpha = 0.3;
    h(2) = scatter2(1); % store 1st object for the colour in the legend
end
legend(h, {'eHMIs in English' 'eHMIs in Spanish'}, ...
    'autoupdate', 'off', ...
    'location', 'northwest')
plot([0 100],[0 100],'b--')
xlabel('Median willingness to cross - participants from USA');
ylabel('Median willingness to cross - participants from Venezuela');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim',[0 101], ...
    'ylim',[0 101])
axis equal
% maximise and export as eps and jpg (for readme)
%export_figure(gcf, [config.path_output filesep 'median-cross-usa-ven'], 'epsc')
%export_figure(gcf, [config.path_figures filesep 'median-cross-usa-ven'], 'jpg')

%% Response time USA/VEN
figure;hold on;grid on
clear h; % empty h object to store colour for the legend
for i=1:227 % English eHMIs
    scatter1 = scatter(mapping{i,3}, nanmedian(RTo(:,i)), 400, ...
        'markerfacecolor', 'k', ...
        'markeredgecolor', 'none');
    scatter1.MarkerFaceAlpha = 0.3;
end
h(1) = scatter1(1); % store 1st object for the colour in the legend
plot([0 100],[0 100],'b--')
xlabel('Number of characters');
ylabel('Median response time');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'ylim', [2000 10000])
%axis equal
% maximise and export as eps and jpg (for readme)
%export_figure(gcf, [config.path_output filesep 'response-time-usa-ven'], 'epsc')
%export_figure(gcf, [config.path_figures filesep 'response-time-usa-ven'], 'jpg')


%% Scatter plot for Spanish and corresponding English eHMI texts
% assign colours to pairs of EN and ES eHMIs
Ewi=NaN(47,1);
for i=1:47 % loop over 47 Spanish eHMI texts
    Ewi(i)=find(strcmp(mapping{:,2},mapping{180+i,10})); % find the index of the corresponding English eHMI text
end
figure;hold on;grid on;box on
for i=1:47
    scatter1 = scatter(nanmean(RPo(contains(Country,'VE'),Ewi(i))), nanmean(RPo(contains(Country,'VE'),i+180)), 250, ...
        'markerfacecolor', [255, 204, 0]/255, ...
        'markeredgecolor', 'none');
    scatter2 = scatter(nanmean(RPo(~contains(Country,'VE') & ~contains(Country,'US'),Ewi(i))), nanmean(RPo(~contains(Country,'VE') & ~contains(Country,'US'),i+180)), 250, ...
        'markerfacecolor', [179, 25, 66]/255, ...
        'markeredgecolor', 'none');
    plot([nanmean(RPo(contains(Country,'VE'),Ewi(i))) nanmean(RPo(~contains(Country,'VE') & ~contains(Country,'US'),Ewi(i)))],...
        [nanmean(RPo(contains(Country,'VE'),i+180)) nanmean(RPo(~contains(Country,'VE') & ~contains(Country,'US'),i+180))],'k--')
    scatter1.MarkerFaceAlpha = 0.5;
    scatter2.MarkerFaceAlpha = 0.5;
end
    plot([0 100],[0 100],'b--')
legend('Participants from VEN','Participants from countries other than VEN and USA','location','southeast')
xlabel('Mean willingness to cross - English text');
ylabel('Mean willingness to cross - Spanish text');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01],'xlim',[0 100],'ylim',[0 100],'pos',[0.05 0.08 0.5 0.9])

%% ************************************************************************
%% Export of overview to csv
%% ************************************************************************
% m = [mapping(:,2); nanmedian(RPo(:)); nanstd(RPo(:))]';
% m_int = sortrows(m, 1, 'descend');  % sort by willingness to cross score
% m_std = sortrows(m, 2, 'descend');  % sort by std
% writecell([m m_int m_std],'ehmis.csv');
