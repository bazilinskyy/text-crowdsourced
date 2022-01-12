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
[RPoMed,RPoSTD,RPoMedVE,RPoMedUS,RToMedVE,RToMedUS,o,NN]=deal(NaN(N_STIMULI,1));
for i=1:size(RPo,2)
    RPoMed(i)=nanmedian(RPo(:,i))-nanstd(RPo(:,i))/10^6; % equal medians sorted on SD
    RPoSTD(i)=nanstd(RPo(:,i));
    RPoMedVE(i)=nanmean(RPo(contains(Country,'VE'),i)); % mean for participants from VEN
    RPoMedUS(i)=nanmean(RPo(contains(Country,'US'),i)); % mean for participants from USA
    RToMedVE(i)=nanmedian(RTo(contains(Country,'VE'),i)); % median RT participants from VEN
    RToMedUS(i)=nanmedian(RTo(contains(Country,'US'),i)); % median RT participants from USA  
end
[RPoMedSorted,b]=sort(RPoMed);
% build xticks
eHMI_text_MedSorted=char(eHMI_text{b,:});
figure;
hold on;
grid on;
box on;
for i=1:N_STIMULI % loop over colors
    bar(i,1+RPoMedSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
set(gca,'xlim',[-1 N_STIMULI+1],'tickdir','out','ylim',[0 100],'xtick',[1:1:N_STIMULI])
set(gca,'xticklabel',eHMI_text_MedSorted)
xlabel('eHMI');
ylabel('Median willingness to cross (%)')
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
% display top and low
% disp('Top 5 highest - median willingness to cross')
% disp(round(RPoMedSorted(end-4:end)))
% disp('Top 5 lowest - median willingness to cross')
% disp(round(RPoMedSorted(1:4)))
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
% maximise and export as eps and jpg (for readme)
export_figure(gcf, [config.path_output filesep 'median-cross'], 'epsc')
export_figure(gcf, [config.path_figures filesep 'median-cross'], 'jpg')

%% SD willingness to cross - Please cross
[RPoSTDSorted,bs]=sort(RPoSTD);
% build xticks
eHMI_text_STDSorted=char(eHMI_text{bs,:});
figure;
hold on;
box on;
for i=1:N_STIMULI % loop over colors
    bar(i,RPoSTDSorted(i),'barwidth',1,'facecolor','b','edgecolor','k');
end
set(gca,'xlim',[-1 N_STIMULI+1],'tickdir','out','ylim',[0 100],'xtick',[1:1:N_STIMULI])
set(gca,'xticklabel',eHMI_text_STDSorted)
xlabel('eHMI')
ylabel('\it{SD}\rm willingness to cross (%)')
h=findobj('FontName','Helvetica');
set(h,'FontSize',8,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
% display top and low
%disp('Top 15 highest - SD willingness to cross')
%disp(sortrows([eHMI_text_STDSorted(end-14:end,:) round(RPoSTDSorted(end-14:end))],-4))
%disp('Top 15 lowest - SD willingness to cross')
%disp([eHMI_text_STDSorted(1:15,:) round(RPoSTDSorted(1:15))])
% maximise and export as eps and jpg (for readme)
export_figure(gcf, [config.path_output filesep 'sd-cross'], 'epsc')
export_figure(gcf, [config.path_figures filesep 'sd-cross'], 'jpg')

%% Slider rating USA/VEN
figure;hold on;grid on
for i=1:180 % English eHMIs
    scatter1=scatter(RPoMedUS(i),RPoMedVE(i),mapping{i,3}*20,'markerfacecolor','k','markeredgecolor','none');
    scatter1.MarkerFaceAlpha = .3;
end
for i=181:227 % Spanish eHMIs
    scatter2=scatter(RPoMedUS(i),RPoMedVE(i),mapping{i,3}*20,'markerfacecolor','r','markeredgecolor','none');
    scatter2.MarkerFaceAlpha = .3;
end
legend('eHMIs in English','eHMIs in English','autoupdate','off','location','northwest')
plot([0 100],[0 100],'b--')
xlabel('Median willingness to cross - participants from USA');
ylabel('Median willingness to cross - participants from Venezuela');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01],'xlim',[-1 101],'ylim',[-1 101])
axis equal
% maximise and export as eps and jpg (for readme)
export_figure(gcf, [config.path_output filesep 'median-cross-usa-ven'], 'epsc')
export_figure(gcf, [config.path_figures filesep 'median-cross-usa-ven'], 'jpg')

%% Response time USA/VEN
figure;hold on;grid on
for i=1:180 % English texts
    scatter1=scatter(RToMedUS(i),RToMedVE(i),mapping{i,3}*20,'markerfacecolor','k','markeredgecolor','none');
    scatter1.MarkerFaceAlpha = .3;
end
for i=181:227 % Spanish texts
    scatter2=scatter(RToMedUS(i),RToMedVE(i),mapping{i,3}*20,'markerfacecolor','r','markeredgecolor','none');
    scatter2.MarkerFaceAlpha = .3;
end
legend('English texts','Spanish texts','autoupdate','off','location','northwest')
plot([0 100],[0 100],'b--')
xlabel('Median response time - Participants from USA');
ylabel('Median response time - Participants from Venezuela');
h=findobj('FontName','Helvetica');
set(h,'FontSize',20,'Fontname','Arial')
set(gca,'LooseInset',[0.01 0.01 0.01 0.01])
axis equal
% maximise and export as eps and jpg (for readme)
export_figure(gcf, [config.path_output filesep 'response-time-usa-ven'], 'epsc')
export_figure(gcf, [config.path_figures filesep 'response-time-usa-ven'], 'jpg')

%% ************************************************************************
%% Export of overview to csv
%% ************************************************************************
% m = [mapping(:,2); nanmedian(RPo(:)); nanstd(RPo(:))]';
% m_int = sortrows(m, 1, 'descend');  % sort by willingness to cross score
% m_std = sortrows(m, 2, 'descend');  % sort by std
% writecell([m m_int m_std],'ehmis.csv');
