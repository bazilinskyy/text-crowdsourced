% Matlab script built by Joost de Winter and Pavlo Bazilinksyy <pavlo.bazilinskyy@gmail.com>
clear all;close all;clc; %#ok<*CLALL>

%% ************************************************************************
%% Constants
%% ************************************************************************
N_STIMULI = 227;  % number of stimuli
N_PERSON = 80;    % number of stimuli per person
N_SUB = 20;       % number of top and bottom stimuli to show in
                  % barplots
STEP_COLOUR = 5;  % stepa for traversing over colourmap
COLOUR_SAME_EHMI = true;  % flag for colouring eHMI in ES/EN on figures
                          % with all eHMI

%% ************************************************************************
%% Load config
%% ************************************************************************
config = jsondecode(fileread('../../config'));

%% ************************************************************************
%% Process data
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

%% Read mapping of eHMIs
mapping = readtable(config.mapping);

%% ************************************************************************
%% OUTPUT
%% ************************************************************************
opengl hardware
%% Prepare data
RT = X(:, 27:106);       % amount of time used to press the key
RP = X(:, 107:186);      % response from the slider
imageid = X(:,187:266);  % image ids as shown
lang_es = X(:,267);      % language (1=Spanish, 0=not Spanish)
eHMI_text=mapping(:,2);  % labels with eHMIs
% Order based on image number
[RPo,RTo]=deal(NaN(size(RP,1),N_STIMULI));
for i=1:size(RP,1) % loop over pp
    % TODO: check if no matlab logic is broken with conversion from 0 to 1 for index
    RPo(i,imageid(i,:)+1)=RP(i,:);
    RTo(i,imageid(i,:)+1)=RT(i,:);
end
% Median willingness to cross
[RPoMed,RPoSTD,RPoMedVE,RPoMedUS,RToMedVE,RToMedUS]=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    RPoMed(i)=nanmedian(RPo(:,i))-nanstd(RPo(:,i))/10^6; % equal medians sorted on SD
    RPoSTD(i)=nanstd(RPo(:,i));
    RPoMedVE(i)=nanmean(RPo(contains(Country,'VE'),i)); % mean for participants from VEN
    RPoMedUS(i)=nanmean(RPo(contains(Country,'US'),i)); % mean for participants from USA
    RToMedVE(i)=nanmedian(RTo(contains(Country,'VE'),i)); % median RT participants from VEN
    RToMedUS(i)=nanmedian(RTo(contains(Country,'US'),i)); % median RT participants from USA
end
[RPoMedSorted,b]=sort(RPoMed);
eHMI_text_MedSorted=char(eHMI_text{b,:});
% Mean willingness to cross
[RPoMean,RPoSTD,RPoMeanVE,RPoMeanUS,RToMeanVE,RToMeanUS,o,NN]=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    RPoMean(i)=nanmean(RPo(:,i))-nanstd(RPo(:,i))/10^6; % equal mean sorted on SD
    RPoSTD(i)=nanstd(RPo(:,i));
    RPoMeanVE(i)=nanmean(RPo(contains(Country,'VE'),i)); % mean for participants from VEN
    RPoMeanUS(i)=nanmean(RPo(contains(Country,'US'),i)); % mean for participants from USA
    RToMeanVE(i)=nanmean(RTo(contains(Country,'VE'),i)); % mean RT participants from VEN
    RToMeanUS(i)=nanmean(RTo(contains(Country,'US'),i)); % mean RT participants from USA  
end
[RPoMeanSorted,b]=sort(RPoMean);
eHMI_text_MeanSorted=char(eHMI_text{b,:});
% SD willingness to cross
[RPoSTDSorted,bs]=sort(RPoSTD);
eHMI_text_STDSorted=char(eHMI_text{bs,:});

%% Median willingness to cross for all stimuli
figure;
hold on;
grid on;
box on;
for i=1:N_STIMULI % loop over eHMIs
    bar_obj(i) = bar(i,1+RPoMedSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
% assign colours to pairs of EN and ES eHMIs
if COLOUR_SAME_EHMI
    cmap = colormap(jet); % choose colormap
    counter_colour = 1;  % counter for assigned colours
    for i=1:N_STIMULI % loop over eHMIs
        % get index in cell array
        ehmi = strtrim(eHMI_text_MedSorted(i,:));
        % check if there is Spanish translation
        if find(ismember(mapping{:,10}, ehmi))
            index_es = find(ismember(mapping{:,10}, ehmi));
            ehmi_es = char(mapping{index_es,2});
            % find index of ES eHMI
            for j=1:N_STIMULI % loop over eHMIs
                ehmi_tick_trimmed = strtrim(eHMI_text_MedSorted(j,:));
                if strcmp(ehmi_es, ehmi_tick_trimmed)
                    i_es = j;
                    break;
                end
            end
            % set colour
            set(bar_obj(i),'FaceColor', cmap(counter_colour,:));
            set(bar_obj(i_es),'FaceColor', cmap(counter_colour,:));
            counter_colour = counter_colour + 5;
        end
    end
end
set(gca,'xlim',[-1 N_STIMULI+1],'tickdir','out','ylim',[0 100],'xtick',[1:1:N_STIMULI])
set(gca,'xticklabel',eHMI_text_MedSorted)
xlabel('eHMI');
ylabel('Median willingness to cross (%)')
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'median-cross'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'median-cross'], 'jpg')
end

%% Median willingness to cross for limited number of stimuli
figure;
% bottom N_SUB
subplot(1,2,1);
hold on;
grid on;
box on;
for i=1:1+N_SUB % loop over eHMIs
    bar(i,1+RPoMedSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
set(gca,'xlim',[1 1+N_SUB+1],'tickdir','out','ylim',[0 100],'xtick',[1:1:1+N_SUB])
set(gca,'xticklabel',eHMI_text_MedSorted(1:1+N_SUB,:))
xlabel('eHMI');
ylabel('Median willingness to cross (%)')
% top N_SUB
subplot(1,2,2);
hold on;
grid on;
box on;
for i=N_STIMULI-N_SUB:N_STIMULI % loop over eHMIs
    bar(i,1+RPoMedSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
set(gca,'xlim',[N_STIMULI-N_SUB N_STIMULI+1],'tickdir','out','ylim',[0 100],'xtick',[N_STIMULI-N_SUB:1:N_STIMULI])
set(gca,'xticklabel',eHMI_text_MedSorted(N_STIMULI-N_SUB:N_STIMULI,:))
xlabel('eHMI');
ylabel('Median willingness to cross (%)')
% config for the whole figure
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'median-cross-subgroup'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'median-cross-subgroup'], 'jpg')
end

%% Mean willingness to cross for all stimuli
figure;
hold on;
grid on;
box on;
for i=1:N_STIMULI % loop over eHMIs
    bar_obj(i) = bar(i,1+RPoMeanSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
% assign colours to pairs of EN and ES eHMIs
if COLOUR_SAME_EHMI
    cmap = colormap(jet); % choose colormap
    counter_colour = 1;  % counter for assigned colours
    for i=1:N_STIMULI % loop over eHMIs
        % get index in cell array
        ehmi = strtrim(eHMI_text_MeanSorted(i,:));
        % check if there is Spanish translation
        if find(ismember(mapping{:,10}, ehmi))
            index_es = find(ismember(mapping{:,10}, ehmi));
            ehmi_es = char(mapping{index_es,2});
            % find index of ES eHMI
            for j=1:N_STIMULI % loop over eHMIs
                ehmi_tick_trimmed = strtrim(eHMI_text_MeanSorted(j,:));
                if strcmp(ehmi_es, ehmi_tick_trimmed)
                    i_es = j;
                    break;
                end
            end
            % set colour
            set(bar_obj(i),'FaceColor', cmap(counter_colour,:));
            set(bar_obj(i_es),'FaceColor', cmap(counter_colour,:));
            counter_colour = counter_colour + STEP_COLOUR;
        end
    end
end
set(gca,'xlim',[-1 N_STIMULI+1],'tickdir','out','ylim',[0 100],'xtick',[1:1:N_STIMULI])
set(gca,'xticklabel',eHMI_text_MeanSorted)
xlabel('eHMI');
ylabel('Mean willingness to cross (%)')
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'mean-cross'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'mean-cross'], 'jpg')
end

%% SD willingness to cross for all stimuli
figure;
hold on;
box on;
for i=1:N_STIMULI % loop over eHMIs
    bar_obj(i) = bar(i,RPoSTDSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
% assign colours to pairs of EN and ES eHMIs
if COLOUR_SAME_EHMI
    cmap = colormap(jet); % choose colormap
    counter_colour = 1;  % counter for assigned colours
    for i=1:N_STIMULI % loop over eHMIs
        % get index in cell array
        ehmi = strtrim(eHMI_text_STDSorted(i,:));
        % check if there is Spanish translation
        if find(ismember(mapping{:,10}, ehmi))
            index_es = find(ismember(mapping{:,10}, ehmi));
            ehmi_es = char(mapping{index_es,2});
            % find index of ES eHMI
            for j=1:N_STIMULI % loop over eHMIs
                ehmi_tick_trimmed = strtrim(eHMI_text_STDSorted(j,:));
                if strcmp(ehmi_es, ehmi_tick_trimmed)
                    i_es = j;
                    break;
                end
            end
            % set colour
            set(bar_obj(i),'FaceColor', cmap(counter_colour,:));
            set(bar_obj(i_es),'FaceColor', cmap(counter_colour,:));
            counter_colour = counter_colour + STEP_COLOUR;
        end
    end
end
set(gca,'xlim',[-1 N_STIMULI+1],'tickdir','out','ylim',[0 40],'xtick',[1:1:N_STIMULI])
set(gca,'xticklabel',eHMI_text_STDSorted)
xlabel('eHMI')
ylabel('\it{SD}\rm willingness to cross (%)')
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'sd-cross'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'sd-cross'], 'jpg')
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
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'median-cross-usa-ven'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'median-cross-usa-ven'], 'jpg')
end

%% Response time USA/VEN
figure;hold on;grid on
clear h; % empty h object to store colour for the legend
for i=1:180 % English eHMIs
    scatter1 = scatter(RToMedUS(i), RToMedVE(i), mapping{i,3}*20, ...
                       'markerfacecolor', 'k', ...
                       'markeredgecolor', 'none');
    scatter1.MarkerFaceAlpha = 0.3;
    h(1) = scatter1(1); % store 1st object for the colour in the legend
end
for i=181:227 % Spanish eHMIs
    scatter2 = scatter(RToMedUS(i), RToMedVE(i), mapping{i,3}*20, ...
                       'markerfacecolor', 'r', ...
                       'markeredgecolor', 'none');
    scatter2.MarkerFaceAlpha = 0.3;
    h(2) = scatter2(1); % store 1st object for the colour in the legend
end
legend(h, {'eHMIs in English' 'eHMIs in Spanish'}, ...
       'autoupdate', 'off', ...
       'location', 'northwest')
plot([0 100],[0 100],'b--')
xlabel('Median response time - Participants from USA');
ylabel('Median response time - Participants from Venezuela');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [2000 10000], ...
    'ylim', [3000 10000])
axis equal
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'response-time-usa-ven'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'response-time-usa-ven'], 'jpg')
end

%% Response time over number of characters
figure;hold on;grid on
clear h; % empty h object to store colour for the legend
for i=1:227 % English eHMIs
    scatter_obj = scatter(mapping{i,3}, nanmedian(RTo(:,i)), 400, ...
                          'markerfacecolor', 'k', ...
                          'markeredgecolor', 'none');
    scatter_obj.MarkerFaceAlpha = 0.3;
end
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
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'response-time-num-chars'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'response-time-num-chars'], 'jpg')
end

%% Scatter plot for Spanish and corresponding English eHMI texts
% assign colours to pairs of EN and ES eHMIs
Ewi=NaN(47,1);
for i=1:47 % loop over 47 Spanish eHMI texts
    Ewi(i)=find(strcmp(mapping{:,2},mapping{180+i,10})); % find the index of the corresponding English eHMI text
end
figure;hold on;grid on;box on
for i=1:47
    scatter1 = scatter(nanmean(RPo(lang_es==1,Ewi(i))), nanmean(RPo(lang_es==1,i+180)), 250, ...
                       'markerfacecolor', [255, 204, 0]/255, ...
                       'markeredgecolor', 'none');
    scatter2 = scatter(nanmean(RPo(lang_es==0,Ewi(i))), nanmean(RPo(lang_es==0,i+180)), 250, ...
                       'markerfacecolor', [179, 25, 66]/255, ...
                       'markeredgecolor', 'none');
    plot([nanmean(RPo(lang_es==1,Ewi(i))) nanmean(RPo(lang_es==0,Ewi(i)))],...
         [nanmean(RPo(lang_es==1,i+180)) nanmean(RPo(lang_es==0,i+180))],'k--')
    scatter1.MarkerFaceAlpha = 0.5;
    scatter2.MarkerFaceAlpha = 0.5;
end
    plot([0 100],[0 100],'b--')
legend('Participants with preferred language of Spanish','Participants with preferred language of English','location','southeast')
xlabel('Mean willingness to cross - English text');
ylabel('Mean willingness to cross - Spanish text');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01],'xlim',[0 100],'ylim',[0 100],'pos',[0.05 0.08 0.5 0.9])
if config.save_figures
% maximise and export as eps and jpg (for readme)
    export_figure(gcf, [config.path_output filesep 'median-cross-en-es'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'median-cross-en-es'], 'jpg')
end

%% Correlation matrix and plot
% fetch relevant columns from X for correlation matrix 
CMATR = X(:,[2:17, 23]);
% compute correlations
[c_CMATR, p_CMATR] = corr(CMATR, 'type', 'spearman', 'rows', 'pairwise');
% labels for output
labels = {'Gender', ...
          'Age ', ...
          'AgeLicense', ...
          'ModeTrans', ...
          'DriveFreq', ...
          'Mileage', ...
          'Accid', ...
          'DBQ1', ...
          'DBQ2', ...
          'DBQ3', ...
          'DBQ4', ...
          'DBQ5', ...
          'DBQ6', ...
          'DBQ7', ...
          'ProfEN', ...
          'ProfES', ...
          'ENQs'};
% output of correlation matrix
printmat(round(c_CMATR*100)/100, ...
         'Spearman correlation matrix', ...
         char(strjoin(labels)), ...
         char(strjoin(labels)))
% output of correlation plot
[R,PValue] = corrplot(c_CMATR, ...
                      'type', 'spearman', ...
                      'rows', 'pairwise', ...
                      'varNames', labels);
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'corrplot'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'corrplot'], 'jpg')
end

%% ************************************************************************
%% Export of overview to csv
%% ************************************************************************
% m = [mapping{:,2}; RPoMed; RPoSTD];
t = table(mapping{:,2}, RPoMed, RPoMean, RPoSTD, 'VariableNames', {'eHMI' 'med' 'mean' 'std'});
t_med = sortrows(t, 2, 'descend');  % sort by median of willingness to cross
t_mean = sortrows(t, 3, 'descend');  % sort by mean of willingness to cross
t_std = sortrows(t, 4, 'descend');  % sort by std of willingness to cross
% export to csvs
writetable(t,[config.path_output filesep 'ehmi.csv']);
writetable(t_med,[config.path_output filesep 'ehmi_med.csv']);
writetable(t_mean,[config.path_output filesep 'ehmi_mean.csv']);
writetable(t_std,[config.path_output filesep 'ehmi_std.csv']);
