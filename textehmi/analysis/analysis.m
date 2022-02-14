% Matlab script built by Pavlo Bazilinskyy and Joost de Winter
% <pavlo.bazilinskyy@gmail.com>
clear all;close all;clc; %#ok<*CLALL>

%% ************************************************************************
%% Constants
%% ************************************************************************
N_STIMULI = 227;  % number of stimuli
N_PERSON = 80;    % number of stimuli per person
N_SUB = 20;       % number of top and bottom stimuli to show in
                  % barplots
STEP_COLOUR = 5;  % step for traversing over colourmap
COLOUR_SAME_EHMI = true;  % flag for colouring eHMI in ES/EN on figures
                          % with all eHMI

%% ************************************************************************
%% Load config
%% **************************there**********************************************
config = jsondecode(fileread('../../config'));

%% ************************************************************************
%% Process data
%% ************************************************************************
% indices to traverse in appen data
appen_indices = [19,... % 1. Instructions understood
                 39,... % 2. Gender
                 38,... % 3. Age
                 17,... % 4. Age of obtaining driver's license
                 42,... % 5. Primary mode of transportation
                 34,... % 6. How many times in past 12 months did you drive a vehicle
                 16,... % 7. Mileage
                 20,... % 8. Number of accidents
                 12,...  % Country
                 21,... % 9. DBQ1
                 22,... % 10. DBQ2
                 23,... % 11. DBQ3
                 24,... % 12. DBQ4
                 25,... % 13. DBQ5
                 26,... % 14. DBQ6
                 27,... % 15. DBQ7
                 40,... % 16. Knowledge of English
                 41,... % 17. Knowledge of Spanish
                 18,... % 18. English 1
                 37,... % 19. English 2
                 28,... % 20. English 3
                 29,... % 21. English 4
                 36,... % 22. English 5
                 7,...  % 23. Start
                 5,...  % 24. End
                 11,...  % 321. Worker id
                 2,...  % worker_code
                 15];   % IP
% process data using external function
[X, Country] = process_experiment(config.file_appen, ...
                                  appen_indices, ...
                                  config.file_heroku, ...
                                  N_STIMULI);

%% Read mapping of eHMIs
mapping = readtable(config.mapping);

%% Prepare data for output
RT = X(:, 27:106);       % time used to press the key
RP = X(:, 107:186);      % response from the slider
imageid = X(:,187:266);  % image ids as shown
lang_br = X(:,267);      % Browsers language (1=Spanish, 0=not Spanish)
eHMI_text=mapping(:,2);  % labels with eHMIs
% Order based on image number
[RPo,RTo]=deal(NaN(size(RP,1),N_STIMULI));
for i=1:size(RP,1) % loop over pp
    RPo(i,imageid(i,:)+1)=RP(i,:);
    RTo(i,imageid(i,:)+1)=RT(i,:);
end
% Median willingness to cross
[RPoMed,RPoMedVE,RPoMedUS,RToMedVE,RToMedUS]=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    % equal medians sorted on SD
    RPoMed(i)=nanmedian(RPo(:,i))-nanstd(RPo(:,i))/10^6;
    % mean for participants from VEN
    RPoMedVE(i)=nanmedian(RPo(contains(Country,'VE'),i));
    % mean for participants from USA
    RPoMedUS(i)=nanmedian(RPo(contains(Country,'US'),i));
    % median RT participants from VEN
    RToMedVE(i)=nanmedian(RTo(contains(Country,'VE'),i));
    % median RT participants from USA
    RToMedUS(i)=nanmedian(RTo(contains(Country,'US'),i));
end
[RPoMedSorted,b]=sort(RPoMed);
eHMI_text_MedSorted=char(eHMI_text{b,:});
% Mean willingness to cross
[RPoMean,RPoMeanVE,RPoMeanUS,RToMeanVE,RToMeanUS,o,NN]=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    % equal mean sorted on SD
    RPoMean(i)=nanmean(RPo(:,i))-nanstd(RPo(:,i))/10^6;
    % mean for participants from VEN
    RPoMeanVE(i)=nanmean(RPo(contains(Country, 'VE'),i));
    % mean for participants from USA
    RPoMeanUS(i)=nanmean(RPo(contains(Country, 'US'),i));
    % mean RT participants from VEN
    RToMeanVE(i)=nanmean(RTo(contains(Country, 'VE'),i));
    % mean RT participants from USA  
    RToMeanUS(i)=nanmean(RTo(contains(Country, 'US'),i)); 
end
[RPoMeanSorted,b]=sort(RPoMean);
eHMI_text_MeanSorted=char(eHMI_text{b,:});
% SD willingness to cross
RPoSTD=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    RPoSTD(i)=nanstd(RPo(:,i));
end
[RPoSTDSorted, bs]=sort(RPoSTD);
eHMI_text_STDSorted=char(eHMI_text{bs,:});
% Types of eHMIs
ego=find(mapping{:,7}==1 & mapping{:,8}==0);
allo=find(mapping{:,7}==0 & mapping{:,8}==1);
other=find(~ismember(1:227, union(ego,allo)));

%% ************************************************************************
%% OUTPUT
%% ************************************************************************
set(0, 'DefaultFigurePosition', [5 60  1920/2 1080/2]);
opengl hardware

%% Figure 2. Multi-column barplot for crossing percentage
[RPo_mean_sorted,RPO_mean_sorted_o]=sort(nanmean(RPo),'ascend');
% prepare data
cd=NaN(size(RPo,2),3);
cd(ego,:)=repmat([0 .9 0], length(ego), 1);
cd(allo,:)=repmat([0.8 0.8 0.8], length(allo), 1);
cd(other,:)=repmat([1 .5 0], length(other), 1);
% 1st column
figure
subplot(1,4,1)
b=barh(RPo_mean_sorted(1:114),'facecolor','flat');
b.CData=cd(RPO_mean_sorted_o(1:114),:);
for i=1:114
    text(1,i,eHMI_text{RPO_mean_sorted_o(i),:},'color','k','fontsize',6)
end
set(gca,'xlim',[0 85], ...
    'pos',[0.01 0.045 0.22 0.95], ...
    'yticklabel', {}, ...
    'ytick',[], ...
    'ticklength', [0.005 0], ...
    'ydir', 'reverse')
xlabel('Mean willingness to cross (%)')
% 2nd column
subplot(1,4,2)
b=barh(RPo_mean_sorted(115:227),'facecolor',[.8 .8 .8],'facecolor','flat');
b.CData=cd(RPO_mean_sorted_o(115:227),:);
for i=115:227
    text(1,i-114,eHMI_text{RPO_mean_sorted_o(i),:},'color','k','fontsize',6)
end
set(gca,'xlim',[0 85], ...
    'pos',[0.24 0.045 0.22 0.95], ...
    'yticklabel', {}, ...
    'ytick',[], ...
    'ticklength', [0.005 0], ...
    'ydir', 'reverse')
xlabel('Mean willingness to cross (%)')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'mean-cross-multiple-columns'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'mean-cross-multiple-columns'], 'jpg')
    % crop figure
    img = imread([config.path_figures filesep ...
                  'mean-cross-multiple-columns.jpg']);
    [rows, columns, numberOfColorChannels] = size(img);
    img2 = imcrop(img, [0 0 columns/2 - columns/30 rows]);
    imwrite(img2, ...
           [config.path_figures filesep 'mean-cross-multiple-columns.jpg'], ...
           'jpg');
end

%% Figure 3. Text scatter plot of English-text eHMIs. Median response time
% and median response time
figure;hold on;box on
cd=NaN(180,3);
cd(ego,:)=repmat([0 0.8 0], length(ego), 1);
cd(allo,:)=repmat([0 0 0], length(allo), 1);
cd(other,:)=repmat([1 0 0], length(other), 1);
cd=cd(1:180,:);
plot(-10,-10,'o','markerfacecolor',cd(ego(1),:),'markersize',10)
plot(-10,-10,'o','markerfacecolor',cd(allo(1),:),'markersize',10)
plot(-10,-10,'o','markerfacecolor',cd(other(1),:),'markersize',10)
h = textscatter([nanmedian(RTo(:,1:180))' nanstd(RPo(:,1:180))'], ...
                table2cell(eHMI_text(1:180, :)), ...
                'markersize', 22, ...
                'colordata', cd, ...
                'TextDensityPercentage', 75, ...
                'maxtextlength', 100, ...
                'fontsize', 12);
xlabel('Median response time (ms)');
ylabel('\it{SD}\rm willingness to cross (%)');
set(gca, 'Fontsize', 20, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [3600 7200], ...
    'ylim', [19 35], ...
    'ticklength', [0.005 0.005])
legend('Egocentric', 'Allocentric', 'Egocentric and allocentric', ...
       'location', 'southeast')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'scatter-text-en-median'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'scatter-text-en-median'], 'jpg')
end

%% Figure 4. Scatter plot for Spanish and corresponding English eHMI texts
% assign colours to pairs of EN and ES eHMIs
Ewi=NaN(47,1);
for i=1:47 % loop over 47 Spanish eHMI texts
    % find the index of the corresponding English eHMI text
    Ewi(i)=find(strcmp(mapping{:,2},mapping{180+i,10}));
end
figure;
hold on;
grid on;
box on
for i=1:47
    scatter1 = scatter(nanmean(RPo(lang_br==1,Ewi(i))), ...
                       nanmean(RPo(lang_br==1,i+180)), ...
                       250, ...
                       'markerfacecolor', [255, 204, 0]/255, ...
                       'markeredgecolor', 'none');
    scatter2 = scatter(nanmean(RPo(lang_br==0,Ewi(i))), ...
                       nanmean(RPo(lang_br==0,i+180)), ...
                       250, ...
                       'markerfacecolor', [179, 25, 66]/255, ...
                       'markeredgecolor', 'none');
    plot([nanmean(RPo(lang_br==1,Ewi(i))) nanmean(RPo(lang_br==0,Ewi(i)))], ...
         [nanmean(RPo(lang_br==1,i+180)) nanmean(RPo(lang_br==0,i+180))], ...
         'k--')
    scatter1.MarkerFaceAlpha = 0.8;
    scatter2.MarkerFaceAlpha = 0.8;
end
    plot([0 100],[0 100],'b--')
legend('Participants with browser language Spanish', ...
       'Participants with browser language English', ...
       'location','southeast')
xlabel('Mean willingness to cross - eHMI in English (%)');
ylabel('Mean willingness to cross - eHMI in Spanish (%)');
h=findobj('FontName', 'Helvetica');
set(h,'FontSize', 20, 'Fontname', 'Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [0 100], ...
    'ylim', [0 100], ...
    'pos', [0.25 0.08 0.5 0.9])
if config.save_figures
% maximise and export as eps and jpg (for readme)
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'ehmis-en-es'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'ehmis-en-es'], 'jpg')
end

%% Median willingness to cross for all stimuli
figure;
hold on;
grid on;
box on;
for i=1:N_STIMULI % loop over eHMIs
    bar_obj(i) = bar(i, 1+RPoMedSorted(i), ...
                     'barwidth', 1, ...
                     'facecolor', 'b', ...
                     'edgecolor', 'k');
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
            set(bar_obj(i), 'FaceColor', cmap(counter_colour,:));
            set(bar_obj(i_es), 'FaceColor', cmap(counter_colour,:));
            counter_colour = counter_colour + STEP_COLOUR;
        end
    end
end
set(gca, 'xlim', [-1 N_STIMULI+1], ...
    'tickdir', 'out', ...
    'ylim', [0 100], ...
    'xtick', [1:1:N_STIMULI], ...
    'xticklabel', eHMI_text_MedSorted, ...
    'LooseInset',[0.01 0.01 0.01 0.01])
xlabel('eHMI');
ylabel('Median cross percentage (%)')
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'median-cross'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'median-cross'], 'jpg')
end

%% Mean willingness to cross for all stimuli
figure;
hold on;
grid on;
box on;
for i=1:N_STIMULI % loop over eHMIs
    bar_obj(i) = bar(i, 1+RPoMeanSorted(i), ...
                     'barwidth', 1, ...
                     'facecolor', 'b', ...
                     'edgecolor','k');
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
set(gca,'xlim', [-1 N_STIMULI+1], ...
    'tickdir', 'out', ...
    'ylim', [0 100], ...
    'xtick', [1:1:N_STIMULI], ...
    'xticklabel', eHMI_text_MeanSorted, ...
    'LooseInset', [0.01 0.01 0.01 0.01])
xlabel('eHMI');
ylabel('Mean willingness to cross (%)')
h=findobj('FontName', 'Helvetica');
set(h, 'FontSize', 8, 'Fontname', 'Arial')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'mean-cross'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'mean-cross'], 'jpg')
end

%% SD willingness to cross for all stimuli
figure;
hold on;
box on;
for i=1:N_STIMULI % loop over eHMIs
    bar_obj(i) = bar(i, RPoSTDSorted(i), ...
                     'barwidth', 1, ...
                     'facecolor', 'b', ...
                     'edgecolor','k');
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
set(gca, 'xlim', [-1 N_STIMULI+1], ...
    'tickdir', 'out', ...
    'ylim', [0 40], ...
    'xtick', [1:1:N_STIMULI], ...
    'xticklabel', eHMI_text_STDSorted, ...
    'LooseInset', [0.01 0.01 0.01 0.01])
xlabel('eHMI')
ylabel('\it{SD}\rm willingness to cross (%)')
h=findobj('FontName', 'Helvetica');
set(h,'FontSize', 8, 'Fontname', 'Arial')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'sd-cross'], 'epsc')
    export_figure(gcf, [config.path_figures filesep 'sd-cross'], 'jpg')
end

%% Text scatter plot of English-text eHMIs. Mean willingness to cross and
% SD willingness to cross and median response time
figure;hold on;box on
cd=NaN(180,3);
cd(ego,:)=repmat([0 0.8 0], length(ego), 1);
cd(allo,:)=repmat([0 0 0], length(allo), 1);
cd(other,:)=repmat([1 0 0], length(other), 1);
id=find(nanmean(RPo(:,1:180))>45 & nanmean(RPo(:,1:180))<55);
cd=cd(id,:);
h = textscatter([nanmean(RPo(:,id))' nanstd(RPo(:,id))'], ...
                table2cell(eHMI_text(id, :)), ...
                'markersize', 22, ...
                'colordata', cd, ...
                'TextDensityPercentage', 100, ...
                'maxtextlength', 100, ...
                'fontsize', 14);
xlabel('Mean willingness to cross (%)');
ylabel('\it{SD}\rm willingness to cross (%)');
set(gca, 'Fontsize', 20, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [38 62], ...
    'ylim', [19 32], ...
    'ticklength', [0.005 0.005])
[a,b]=sortrows([nanmean(RPo(:,id))' nanstd(RPo(:,id))' nanmedian(RTo(:,id))'], 2);
t=table(eHMI_text(id(b),:),round(a(:,1),1),round(a(:,2),1),round(a(:,3),4));
t.Properties.VariableNames={'eHMI','Mean (%)','SD (%)','Median RT (ms)'};
disp(t)
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' filesep ...
                        'scatter-text-en-mean'], 'epsc')
    export_figure(gcf, [config.path_figures filesep ...
                        'scatter-text-en-mean'], 'jpg')
end

%% Response time learning curve
figure; hold on; grid on
plot(nanmedian(RT),'k-o','Linewidth',3)
xlabel('Trial number')
ylabel('Median response time (ms)')
set(gca, 'Fontsize', 20, ...
    'LooseInset', [0.01 0.01 0.01 0.01],...
    'xtick',[1 10:10:80])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'response-time-learning'], 'epsc')
    export_figure(gcf, [config.path_figures filesep ...
                        'response-time-learning'], 'jpg')
end

%% Response time USA/VEN
figure;
hold on;
grid on;
clear h; % empty h object to store colour for the legend
for i=1:180 % English eHMIs
    scatter1 = scatter(nanmedian(RTo(lang_br==0, i)), ...
                       nanmedian(RTo(lang_br==1, i)), ...
                       mapping{i, 3} * 20, ...
                       'markerfacecolor', 'k', ...
                       'markeredgecolor', 'none');
    scatter1.MarkerFaceAlpha = 0.3;
    h(1) = scatter1(1); % store 1st object for the colour in the legend
end
for i=181:227 % Spanish eHMIs
    scatter2 = scatter(nanmedian(RTo(lang_br==0,i)), ...
                       nanmedian(RTo(lang_br==1,i)), ...
                       mapping{i,3}*20, ...
                       'markerfacecolor', 'r', ...
                       'markeredgecolor', 'none');
    scatter2.MarkerFaceAlpha = 0.3;
    h(2) = scatter2(1); % store 1st object for the colour in the legend
end
plot([0 100], [0 100], 'b--')
xlabel('Median response time - participants with non-Spanish browser');
ylabel('Median response time - participants with Spanish browser');
legend(h, {'eHMIs in English' 'eHMIs in Spanish'}, ...
       'autoupdate', 'off', ...
       'location', 'northwest')
h=findobj('FontName', 'Helvetica');
set(h, 'FontSize', 20, 'Fontname','Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01], ...
    'ylim', [3000 7000])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'response-time-en-es'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'response-time-en-es'], 'jpg')
end

%% Response time vs number of characters
figure;
hold on;
grid on;
box on;
clear h; % empty h object to store colour for the legend
for i=1:180 % English eHMIs
    scatter1 = scatter(mapping{i,3}, nanmedian(RTo(:,i)), 400, ...
                       'markerfacecolor', 'k', ...
                       'markeredgecolor', 'none');
    scatter1.MarkerFaceAlpha = 0.3;
    h(1) = scatter1(1); % store 1st object for the colour in the legend
end
for i=181:227 % Spanish eHMIs
    scatter2 = scatter(mapping{i,3}, nanmedian(RTo(:,i)), 400, ...
                       'markerfacecolor', 'r', ...
                       'markeredgecolor', 'none');
    scatter2.MarkerFaceAlpha = 0.3;
    h(2) = scatter2(1);
end
plot([0 100], [0 100],'b--')
xlabel('Number of characters');
ylabel('Median response time');
legend(h, {'eHMIs in English' 'eHMIs in Spanish'}, ...
       'autoupdate', 'off', ...
       'location', 'northwest')
h=findobj('FontName', 'Helvetica');
set(h, 'FontSize', 20, 'Fontname', 'Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01], ...
    'ylim', [3000 7000])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'response-time-num-chars'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'response-time-num-chars'], 'jpg')
end

%% Correlation matrix and plot
% fetch relevant columns from X for correlation matrix 
CMATR = [X(:,[2:4 6:17 23]) lang_br];
% compute correlations
[c_CMATR, p_CMATR] = corr(CMATR, 'type', 'spearman', 'rows', 'pairwise');
% labels for output
labels = {'Gend', ...
          'Age ', ...
          'Licen', ...
          'Drive', ...
          'Mile', ...
          'Accid', ...
          'DBQ1', ...
          'DBQ2', ...
          'DBQ3', ...
          'DBQ4', ...
          'DBQ5', ...
          'DBQ6', ...
          'DBQ7', ...
          'EN', ...
          'ES', ...
          'EnQs', ...
          'Lang'};
% output of correlation matrix
printmat(round(c_CMATR*100)/100, ...
         'Spearman correlation matrix', ...
         char(strjoin(labels)), ...
         char(strjoin(labels)))
% output of correlation plot
clear gcf;  % clear from previous figure to handle saving of files
figure;
% TODO: remove title from figure
[R,PValue] = corrplot(CMATR, ...
                      'type', 'spearman', ...
                      'rows', 'pairwise', ...
                      'varNames', labels, ...
                      'testR','on');
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'corrplot'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'corrplot'], 'jpg')
end
h=findobj('FontName','Helvetica');
set(h, 'Fontname','Arial')

%% Display correlation matrices at the level of stimuli
%XCM=[abs(50-nanmean(RPo))' nanmean(RTo)' mapping{:,[3 7 8]}];
%disp('Correlation matrix all participants, all eHMIs')
%disp(round(corr(XCM),2))

XCM=[2*abs(nanmean(RPo(:,1:180)-50))' nanstd(RPo(:,1:180))' nanmedian(RTo(:,1:180))' mapping{1:180,[3 7 8]}];
disp([datestr(now, 'HH:MM:SS.FFF') ' - Correlation matrix all participants, Enligh-text eHMIs'])
disp(round(corr(XCM),2))

% XCM=[abs(50-nanmean(RPo(lang_br==1,181:end)))' ...
%      nanmedian(RTo(lang_br==1,181:end))' ...
%      mapping{181:end,[3 7 8]}];
% disp(['Correlation matrix Spanish-language participants, ' ...
%       'Spanish eHMI texts'])
% disp(round(corr(XCM),2))
% 
% XCM=[abs(50-nanmean(RPo(lang_br==0,1:180)))' ...
%      nanmedian(RTo(lang_br==0,1:180))' ...
%      mapping{1:180,[3 7 8]}];
% disp(['Correlation matrix Non-Spanish-language participants, ' ...
%       'English eHMI texts'])
% disp(round(corr(XCM),2))

%% Table. Regression model statistics
y=XCM(:,3);
x=XCM(:,4:5);
stu=regstats(y, x);
y=zscore(y);x=zscore(x);
st=regstats(y, x);
disp([round([stu.beta st.beta st.tstat.t ], 3), ...
      round(1000*st.tstat.pval(1:end))/1000])
disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of trials in the ' ...
      'regression analysis = ' num2str(length(y))])
disp([st.fstat.dfr st.fstat.dfe st.fstat.f st.fstat.pval ...
      corr(st.yhat,y) st.rsquare])

%% SD analysis in groups of 10%
[Number_of_eHMIs,MinSD,MinSDindex,MaxSD,MaxSDindex]=deal(NaN(10,1));
for i=1:9
    ehmi_indexes=find(nanmean(RPo(:,1:180))>5+(i-1)*10 & nanmean(RPo(:,1:180))<5+i*10);
Number_of_eHMIs(i)=length(ehmi_indexes);
    try
    [MinSD(i) minsdindex]=min(nanmedian(RTo(:,ehmi_indexes)));
    [MaxSD(i) maxsdindex]=max(nanmedian(RTo(:,ehmi_indexes)));
        MinSDindex(i)=ehmi_indexes(minsdindex);
        MaxSDindex(i)=ehmi_indexes(maxsdindex);
    end
end
MinSD=round(MinSD,1);
MaxSD=round(MaxSD,1);
id=find(Number_of_eHMIs>0);
t=table(Number_of_eHMIs(id), eHMI_text(MinSDindex(id),:), MinSD(id), ...
        eHMI_text(MaxSDindex(id),:),MaxSD(id));
t.Properties.VariableNames={'Number of eHMIs','min SD','min SD (%)', ...
                            'max SD','max SD (%)'};
disp(t)

%% Information on browser language and country
disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of participants (1) US & ' ...
      'non-es browser, (2) VE & non-es browser, (3) US & es browser, ' ...
      '(4) VE & es_browser'])
disp([sum(contains(Country,'US') & lang_br==0) ...
      sum(contains(Country,'VE') & lang_br==0) ...
      sum(contains(Country,'US') & lang_br==1) ...
      sum(contains(Country,'VE') & lang_br==1)])
g1=contains(Country,'VE');
g2=contains(Country,'IN');
disp([sum(g1) sum(g2)
      nanmedian(X(g1,26)) nanmedian(X(g2,26)) % survey duration
      nanmean(X(g1,3)) nanmean(X(g2,3)) % mean age 
      100*(-1+nanmean(X(g1,2))) 100*(-1+nanmean(X(g2,2))) % percentage males
      mean(X(g1,5)==1) mean(X(g2,5)==1)])
% participants with browser English
disp([datestr(now, 'HH:MM:SS.FFF') ' - Participants with browser English:'])
disp(nanmean(X(lang_br==0,[16 17 23])))
% participants with browser Spanish
disp([datestr(now, 'HH:MM:SS.FFF') ' - Participants with browser Spanish:'])
disp(nanmean(X(lang_br==1,[16 17 23])))

%% ************************************************************************
%% Export of overview of eHMIs to csv
%% ************************************************************************
t = table(mapping{:,2}, ...
          RPoMed, ...
          RPoMean, ...
          RPoSTD, ...
          'VariableNames', {'eHMI' 'med' 'mean' 'std'});
% sort by median of willingness to cross
t_med = sortrows(t, 2, 'descend');
% sort by mean of willingness to cross
t_mean = sortrows(t, 3, 'descend');
% sort by std of willingness to cross
t_std = sortrows(t, 4, 'descend');
% export to csvs
writetable(t, [config.path_output filesep 'ehmis.csv']);
writetable(t_med, [config.path_output filesep 'ehmis_med.csv']);
writetable(t_mean, [config.path_output filesep 'ehmis_mean.csv']);
writetable(t_std, [config.path_output filesep 'ehmis_std.csv']);
