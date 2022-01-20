% Matlab script built by Pavlo Bazilinskyy Joost de Winter <pavlo.bazilinskyy@gmail.com>
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
%% ************************************************************************
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
                 2];   % worker_code
% process data using external function
[X, Country] = process_experiment(config.file_appen, ...
                                  appen_indices, ...
                                  config.file_heroku, ...
                                  N_STIMULI);

%% Read mapping of eHMIs
mapping = readtable(config.mapping);

%% ************************************************************************
%% OUTPUT
%% ************************************************************************
set(0, 'DefaultFigurePosition', [5 60  1920/2 1080/2]);
opengl hardware

%% Prepare data
RT = X(:, 27:106);       % time used to press the key
RP = X(:, 107:186);      % response from the slider
imageid = X(:,187:266);  % image ids as shown
lang_es = X(:,267);      % Browsers language (1=Spanish, 0=not Spanish)
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
ylabel('Median willingness to cross (%)')
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

%% Text scatter plot of English-text eHMIs. Mean willingness to cross vs
% median response time
figure;hold on;box on
cd=NaN(size(RPo,2),3);
cd(ego,:)=repmat([0 0.8 0], length(ego), 1);
cd(allo,:)=repmat([0 0 0], length(allo), 1);
cd(other,:)=repmat([1 0 0], length(other), 1);
cd=cd(1:180,:);
plot(-10,-10,'o','markerfacecolor',cd(ego(1),:),'markersize',10)
plot(-10,-10,'o','markerfacecolor',cd(allo(1),:),'markersize',10)
plot(-10,-10,'o','markerfacecolor',cd(other(1),:),'markersize',10)
h = textscatter([nanmean(RPo(:,1:180))' nanmedian(RTo(:,1:180))'], ...
                table2cell(eHMI_text(1:180, :)), ...
                'markersize', 22, ...
                'colordata', cd, ...
                'TextDensityPercentage', 100, ...
                'maxtextlength', 100, ...
                'fontsize', 10);
xlabel('Mean willingness to cross (%)');
ylabel('Median response time (ms)');
set(gca, 'Fontsize', 20, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [13.5 86.5], ...
    'ylim', [3400 6400])
legend('Egocentric', 'Allocentric', 'Egocentric and allocentric', ...
       'location','northwest')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'median-cross-mean-cross'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'median-cross-mean-cross'], 'jpg')
end

%% Multi-column barplot for mean willingness to cross
[RPo_mean_sorted,RPO_mean_sorted_o]=sort(nanmean(RPo),'ascend');

cd=NaN(size(RPo,2),3);
cd(ego,:)=repmat([0 .9 0], length(ego), 1);
cd(allo,:)=repmat([0.8 0.8 0.8], length(allo), 1);
cd(other,:)=repmat([1 .5 0], length(other), 1);

figure
subplot(1,4,1)
b=barh(RPo_mean_sorted(1:114),'facecolor','flat');
b.CData=cd(RPO_mean_sorted_o(1:114),:);
for i=1:114
    text(1,i,eHMI_text{RPO_mean_sorted_o(i),:},'color','k','fontsize',6)
end

set(gca,'xlim',[0 85])
set(gca,'ydir','reverse')
set(gca,'pos',[0.01 0.045 0.22 0.94])
set(gca,'yticklabel',{})
set(gca,'ticklength',[0.005 0])
xlabel('Mean willingness to cross (%)')

subplot(1,4,2)
b=barh(RPo_mean_sorted(115:227),'facecolor',[.8 .8 .8],'facecolor','flat');
b.CData=cd(RPO_mean_sorted_o(115:227),:);
for i=115:227
    text(1,i-114,eHMI_text{RPO_mean_sorted_o(i),:},'color','k','fontsize',6)
end

set(gca,'xlim',[0 85], ...
    'pos',[0.26 0.045 0.22 0.94], ...
    'yticklabel', {}, ...
    'ticklength', [0.005 0], ...
    'ydir', 'reverse')
xlabel('Mean willingness to cross (%)')


%subplot(1,4,3)
%b=barh(RPo_mean_sorted(153:227),'facecolor',[.8 .8 .8],'facecolor','flat');
%b.CData=cd(RPO_mean_sorted_o(153:227),:);
%for i=153:227
%    text(1,i-152,eHMI_text{RPO_mean_sorted_o(i),:},'color','k','fontsize',8)
%end
%set(gca,'xlim',[0 100])
%set(gca,'ydir','reverse')
%set(gca,'pos',[0.51 0.045 0.22 0.94])
%set(gca,'yticklabel',{})
%set(gca,'ticklength',[0.005 0])
%xlabel('Mean willingness to cross (%)')

% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'mean-cross-multiple-columns'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'mean-cross-multiple-columns'], 'jpg')
end

%% Text scatter plot of English-text eHMIs. Mean vs SD willingness to cross
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
h = textscatter([nanmean(RPo(:,1:180))' nanstd(RPo(:,1:180))'], ...
                table2cell(eHMI_text(1:180, :)), ...
                'markersize', 22, ...
                'colordata', cd, ...
                'TextDensityPercentage', 75, ...
                'maxtextlength', 100, ...
                'fontsize', 13);
xlabel('Mean willingness to cross (%)');
ylabel('\it{SD}\rm willingness to cross (%)');
set(gca, 'Fontsize', 20, ...
    'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [13.5 86.5])
legend('Egocentric', 'Allocentric', 'Egocentric and allocentric', ...
       'location', 'southwest')
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'mean-cross-sd-cross'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'mean-cross-sd-cross'], 'jpg')
end

%% Response time USA/VEN
figure;
hold on;
grid on
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
plot([0 100], [0 100], 'b--')
xlabel('Median response time - participants from USA');
ylabel('Median response time - participants from Venezuela');
h=findobj('FontName', 'Helvetica');
set(h, 'FontSize', 20, 'Fontname','Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [2500 5500], ...
    'ylim', [3000 7000])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'response-time-usa-ven'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'response-time-usa-ven'], 'jpg')
end

%% Response time vs number of characters
figure;
hold on;
grid on
for i=1:227 % English eHMIs
    scatter_obj = scatter(mapping{i,3}, nanmedian(RTo(:,i)), 400, ...
                          'markerfacecolor', 'k', ...
                          'markeredgecolor', 'none');
    scatter_obj.MarkerFaceAlpha = 0.3;
end
plot([0 100], [0 100],'b--')
xlabel('Number of characters');
ylabel('Median response time');
h=findobj('FontName', 'Helvetica');
set(h, 'FontSize', 20, 'Fontname', 'Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01], ...
    'ylim', [3000 6500])
% maximise and export as eps and jpg (for readme)
if config.save_figures
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'response-time-num-chars'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'response-time-num-chars'], 'jpg')
end

%% Scatter plot for Spanish and corresponding English eHMI texts
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
    scatter1 = scatter(nanmean(RPo(lang_es==1,Ewi(i))), ...
                       nanmean(RPo(lang_es==1,i+180)), ...
                       250, ...
                       'markerfacecolor', [255, 204, 0]/255, ...
                       'markeredgecolor', 'none');
    scatter2 = scatter(nanmean(RPo(lang_es==0,Ewi(i))), ...
                       nanmean(RPo(lang_es==0,i+180)), ...
                       250, ...
                       'markerfacecolor', [179, 25, 66]/255, ...
                       'markeredgecolor', 'none');
    plot([nanmean(RPo(lang_es==1,Ewi(i))) nanmean(RPo(lang_es==0,Ewi(i)))], ...
         [nanmean(RPo(lang_es==1,i+180)) nanmean(RPo(lang_es==0,i+180))], ...
         'k--')
    scatter1.MarkerFaceAlpha = 0.8;
    scatter2.MarkerFaceAlpha = 0.8;
end
    plot([0 100],[0 100],'b--')
legend('Participants with browser language Spanish', ...
       'Participants with browser language English', ...
       'location','southeast')
xlabel('Mean willingness to cross - eHMI in English');
ylabel('Mean willingness to cross - eHMI in Spanish');
h=findobj('FontName', 'Helvetica');
set(h,'FontSize', 20, 'Fontname', 'Arial')
set(gca, 'LooseInset', [0.01 0.01 0.01 0.01], ...
    'xlim', [0 100], ...
    'ylim', [0 100], ...
    'pos', [0.25 0.08 0.5 0.9])
if config.save_figures
% maximise and export as eps and jpg (for readme)
    export_figure(gcf, [config.path_output filesep 'figures' ...
                        filesep 'median-cross-en-es'], 'epsc')
    export_figure(gcf, [config.path_figures ...
                        filesep 'median-cross-en-es'], 'jpg')
end

%% Correlation matrix and plot
% fetch relevant columns from X for correlation matrix 
CMATR = X(:,[2:4 6:17]);
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
          'ES'};
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
XCM=[abs(50-nanmean(RPo))' nanmedian(RTo)' mapping{:,[3 7 8]}];
disp('Correlation matrix all participants, all eHMIs')
disp(round(corr(XCM),2))

XCM=[abs(50-nanmean(RPo(:,1:180)))' nanmedian(RTo(:,1:180))' mapping{1:180,[3 7 8]}];
disp('Correlation matrix all participants, Enligh-text eHMIs')
disp(round(corr(XCM),2))

XCM=[abs(50-nanmean(RPo(lang_es==1,181:end)))' ...
     nanmedian(RTo(lang_es==1,181:end))' ...
     mapping{181:end,[3 7 8]}];
disp(['Correlation matrix Spanish-language participants, ' ...
      'Spanish eHMI texts'])
disp(round(corr(XCM),2))

XCM=[abs(50-nanmean(RPo(lang_es==0,1:180)))' ...
     nanmedian(RTo(lang_es==0,1:180))' ...
     mapping{1:180,[3 7 8]}];
disp(['Correlation matrix Non-Spanish-language participants, ' ...
      'English eHMI texts'])
disp(round(corr(XCM),2))

%%
crossego=find(mapping{1:180,7}==1&mapping{1:180,5}==1);
dontcrossego=find(mapping{1:180,7}==1&mapping{1:180,5}==0);
%rossego=find(mapping{1:180,7}==1&nanmean(RPo(:,1:180))'>50);
%dontcrossego=find(mapping{1:180,7}==1&nanmean(RPo(:,1:180))'<50);
Xp=[lang_es X(:,[16 17]) nanmean(RPo(:,crossego),2)-nanmean(RPo(:,dontcrossego), 2) ];

%% Information on browser language
disp(['Number of participants (1) US & non-es browser, ' ...
      '(2) VE & non-es browser, (3) US & es browser, ...' ...
      '(4) VE & es_browser'])
disp([sum(contains(Country,'US') & lang_es==0) ...
      sum(contains(Country,'VE') & lang_es==0) ...
      sum(contains(Country,'US') & lang_es==1) ...
      sum(contains(Country,'VE') & lang_es==1)])

g1=contains(Country,'VE');
g2=contains(Country,'IN');
disp([sum(g1) sum(g2)
      nanmedian(X(g1,26)) nanmedian(X(g2,26)) % survey duration
      nanmean(X(g1,3)) nanmean(X(g2,3)) % mean age 
      100*(-1+nanmean(X(g1,2))) 100*(-1+nanmean(X(g2,2))) % percentage males
      mean(X(g1,5)==1) mean(X(g2,5)==1)])

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
