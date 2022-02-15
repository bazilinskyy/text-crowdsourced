% Matlab script built by Pavlo Bazilinksyy <pavlo.bazilinskyy@gmail.com>
%% ************************************************************************
%% Process appen and heroku data for the experiment
%% ************************************************************************
function [X, Country] = process_experiment(appen_file, appen_indices, heroku_file, N_STIMULI)
    %% Load data
    % Import csv file with keypress data
    raw_heroku = readtable(heroku_file, 'ReadVariableNames', false);
    % Import csv file with appen data (crowdsourced study)
    % TODO: fix warning about datetime format
    raw_appen = readtable(appen_file, 'ReadVariableNames', true);
    raw_appen = table2cell(raw_appen);  % convert to cell array for ease of checking
    %% Process appen data
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Processing appen data']);
    X=NaN(size(raw_appen,1),269);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents = ' num2str(size(raw_appen, 1))])
    % Instructions understood
    temp=raw_appen(:,appen_indices(1));X(:,1)=strcmp(temp,'no')+2*strcmp(temp,'yes');
    % Gender
    temp=raw_appen(:,appen_indices(2));X(:,2)=1*strcmp(temp,'female')+2*strcmp(temp,'male')-1*strcmp(temp,'i_prefer_not_to_respond');
    % Age
    temp=raw_appen(:,appen_indices(3));for i=1:length(temp);try if strcmp(temp(i),'?');X(i,3)=NaN;else;X(i,3)= cell2mat(temp(i));end;catch error;X(i,3)=NaN;end;end
    X(X(:,3)>110,3)=NaN; % People who report age greater than 110 years
    % Age of obtaining driver's license
    temp=raw_appen(:,appen_indices(4));for i=1:length(temp);try if strcmp(temp(i),'?');X(i,4)=NaN;else;X(i,4)= cell2mat(temp(i));end;catch error;X(i,4)=NaN;end;end
    X(X(:,4)>110,4)=NaN; % People who report licence more than 110 years
    % Primary mode of transportation
    temp=raw_appen(:,appen_indices(5));X(:,5)=1*strcmp(temp,'private_vehicle')+2*strcmp(temp,'public_transportation')+3*strcmp(temp,'motorcycle')+4*strcmp(temp,'walkingcycling')+5*strcmp(temp,'other')-1*strcmp(temp,'i_prefer_not_to_respond');
    % How many times in past 12 months did you drive a vehicle
    temp=raw_appen(:,appen_indices(6));X(:,6)=1*strcmp(temp,'never')+2*strcmp(temp,'less_than_once_a_month')+3*strcmp(temp,'once_a_month_to_once_a_week')+4*strcmp(temp,'1_to_3_days_a_week')+5*strcmp(temp,'4_to_6_days_a_week')+6*strcmp(temp,'every_day')-1*strcmp(temp,'i_prefer_not_to_respond');
    % Mileage
    temp=raw_appen(:,appen_indices(7));for i=1:length(temp);try X(i,7)=1+cell2mat(temp(i));catch error;X(i,7)=1*strcmp(temp(i),'0_km__mi')+2*strcmp(temp(i),'1__1000_km_1__621_mi')+3*strcmp(temp(i),'1001__5000_km_622__3107_mi')+4*strcmp(temp(i),'5001__15000_km_3108__9321_mi')+5*strcmp(temp(i),'15001__20000_km_9322__12427_mi')+6*strcmp(temp(i),'20001__25000_km_12428__15534_mi')+7*strcmp(temp(i),'25001__35000_km_15535__21748_mi')+8*strcmp(temp(i),'35001__50000_km_21749__31069_mi')+9*strcmp(temp(i),'50001__100000_km_31070__62137_mi')+10*strcmp(temp(i),'more_than_100000_km_more_than_62137_mi')-1*strcmp(temp(i),'i_prefer_not_to_respond');end;end
    % Number of accidents
    temp=raw_appen(:,appen_indices(8));for i=1:length(temp);try X(i,8)=1+cell2mat(temp(i));catch error;X(i,8)=7*strcmp(temp(i),'more_than_5')-1*strcmp(temp(i),'i_prefer_not_to_respond');end;end
    % Country
    temp=raw_appen(:,appen_indices(9));Country=cell(size(X,1),1);for i=1:length(temp);try Country(i)=unique(temp(i));catch error;Country(i)={'NaN'};end;end
    % Driver behaviour questionnaire (DBQ)
    temp=raw_appen(:,appen_indices(10:16));X(:,9:15)=1*strcmp(temp,'0_times_per_month')+2*strcmp(temp,'1_to_3_times_per_month')+3*strcmp(temp,'4_to_6_times_per_month')+4*strcmp(temp,'7_to_9_times_per_month')+5*strcmp(temp,'10_or_more_times_per_month')-1*strcmp(temp,'i_prefer_not_to_respond');
    % Proficiency of English
    temp=raw_appen(:,appen_indices(17));X(:,16)=1*strcmp(temp,'no_proficiency')+2*strcmp(temp,'limited_working_proficiency')+3*strcmp(temp,'professional_working_proficiency')+4*strcmp(temp,'full_professional_proficiency')+5*strcmp(temp,'native_or_bilingual_proficiency')-1*strcmp(temp,'i_prefer_not_to_respond');
    % Proficiency of Spanish
    temp=raw_appen(:,appen_indices(18));X(:,17)=1*strcmp(temp,'no_proficiency')+2*strcmp(temp,'limited_working_proficiency')+3*strcmp(temp,'professional_working_proficiency')+4*strcmp(temp,'full_professional_proficiency')+5*strcmp(temp,'native_or_bilingual_proficiency')-1*strcmp(temp,'i_prefer_not_to_respond');
    % English test question 1. Correct: a2. Only for half an hour.
    temp=raw_appen(:,appen_indices(19));X(:,18)=+0*strcmp(temp,'a0')+0*strcmp(temp,'a1')+1*strcmp(temp,'a2');
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents that made mistake in question on English proficiency (Q1) = ' num2str(sum(X(:,18)<=0))])
    % English test question 2. Correct: a1. We can't decide.
    temp=raw_appen(:,appen_indices(20));X(:,19)=+0*strcmp(temp,'a0')+1*strcmp(temp,'a1')+0*strcmp(temp,'a2');
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents that made mistake in question on English proficiency (Q2) = ' num2str(sum(X(:,19)<=0))])
    % English test question 3. Correct: a0. Would you like some help?
    temp=raw_appen(:,appen_indices(21));X(:,20)=1*strcmp(temp,'a0')+0*strcmp(temp,'a1')+0*strcmp(temp,'a2');
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents that made mistake in question on English proficiency (Q3) = ' num2str(sum(X(:,20)<=0))])
    % English test question 4. Correct: a2. I'll just check for you.
    temp=raw_appen(:,appen_indices(22));X(:,21)=+0*strcmp(temp,'a0')+0*strcmp(temp,'a1')+1*strcmp(temp,'a2');
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents that made mistake in question on English proficiency (Q4) = ' num2str(sum(X(:,21)<=0))])
    % English test question 5. Correct: a0. I'm too tired.
    temp=raw_appen(:,appen_indices(23));X(:,22)=1*strcmp(temp,'a0')+0*strcmp(temp,'a1')+0*strcmp(temp,'a2');
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents that made mistake in question on English proficiency (Q5) = ' num2str(sum(X(:,22)<=0))])
    % Sum of number of correct answers
    X(:,23) = X(:,18)+X(:,19)+X(:,20)+X(:,21)+X(:,22);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents that made mistakes in any questions on English proficiency = ' num2str(sum(X(:,23)<5))])
    % Set negative answers as NaN
    X(X<0)=NaN;
    %% Survey time
    for i=1:size(raw_appen, 1)
        try
            starttime=datenum(raw_appen{i,appen_indices(24)});
            endtime=datenum(raw_appen{i,appen_indices(25)});
        catch error
            starttime=datenum(raw_appen{i,appen_indices(24)});
            endtime=datenum(raw_appen{i,appen_indices(25)});
        end
        X(i,24)=starttime;
        X(i,25)=endtime;
        X(i,26)=round(2400*36*(endtime - starttime));
    end
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Survey time mean (minutes) - Before filtering = ' num2str(nanmean(X(:,26)/60))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Survey time median (minutes) - Before filtering = ' num2str(nanmedian(X(:,26)/60))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Survey time SD (minutes) - Before filtering = ' num2str(nanstd(X(:,26)/60))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - First survey start date - Before filtering = ' datestr(min(X(:,24)))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Last survey end date - Before filtering = ' datestr(max(X(:,25)))]);
    %% Worker id
    temp=raw_appen(:,appen_indices(26));for i=1:length(temp);try if strcmp(temp(i),'?');X(i,269)=NaN;else;X(i,269)= cell2mat(temp(i));end;catch error;X(i,269)=NaN;end;end % worker id
    %% Process heroku data
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Processing heroku data']);
    counter_code = 0;
    for i1=1:size(raw_heroku,1) % loop over rows
        temp=cell2mat(table2array(raw_heroku(i1,29)));
        temp2=cell2mat(table2array(raw_heroku(i1,29+N_STIMULI-1)));
        % detect if the browser language is Spanish
        temp3=cell2mat(table2array(raw_heroku(i1,28)));
        % browser language in heroku data
        browser_fetched = temp3(regexp(temp3,'browser_lang:')+14:end-1);
        if contains(browser_fetched, 'en-')
            browser_lang = 0;
        elseif contains(browser_fetched, 'es-')
            browser_lang = 1;
        else
            browser_lang = 2;
        end
        extracted_row=table2array(raw_heroku(i1,29+N_STIMULI:end));
        imageid(i1,:)=[str2double(temp(12:end)) table2array(raw_heroku(i1,30:29+N_STIMULI-2)) str2num(temp2(1:regexp(temp2,']')-1))];
        counter1=0;
        counter2=0;
        temp=extracted_row{652};
        heroku_code = temp(regexp(temp,'worker_code:')+13:end-1);  % worker_code in heroku data
        counter_code = counter_code + 1;
        row_appen_matched=find(strcmp(heroku_code,raw_appen(:,appen_indices(27))));  % worker_code in appen data
        for i2=1:length(extracted_row)
            cell_in_row=cell2mat(extracted_row(i2));
            % skip empty cells
            if isempty(cell_in_row)
                continue;
            end
            if strcmp(cell_in_row(2:6),'"rt":') % Keypress time found
                counter1=counter1+1;
                RT(i1,counter1) = str2num(cell_in_row(7:end)); % Record time key press from temp array into key presses
            end
            if strcmp(cell_in_row(1:4),'resp') % Answer found
                counter2=counter2+1;
                RP(i1,counter2) = str2num(cell_in_row(10:end)); % Record time key press from temp array into key presses
            end
        end
        % add data to corresponding row in X
        if ~isempty(row_appen_matched)
            row_appen_matched=row_appen_matched(1);
            X(row_appen_matched, 27:106)=RT(i1,:);
            X(row_appen_matched, 107:186)=RP(i1,:);
            X(row_appen_matched, 187:266)=imageid(i1,1:80);
            X(row_appen_matched, 267)=browser_lang;  % browser language
            X(row_appen_matched, 268)=1;  % flag that row was matched
        end
    end
    %% Remove participants who did not meet the criteria
    % respondents who did not read instructions
    invalid1 = find(X(:,1)==1);
    % respondents who indicated they are under 18 years old
    invalid2 = find(X(:,3)<18);
    % respondents who took less than 5 min to complete
    invalid3 = find(X(:,26)<300);
    % respondents with no response data / match
    invalid5 = find(isnan(sum(X(:,107:186),2)));
    %% Find rows with identical IP addresses
    y = NaN(size(X(:,1)));
    IPCF_1=NaN(size(raw_appen,1),1);
    for i=1:size(raw_appen,1)
        try IPCF_1(i)=str2double(strrep(raw_appen(i,appen_indices(28)),'.',''));
        catch
            IPCF_1(i)=cell2mat(raw_appen(i,appen_indices(28)));
        end
    end % reduce IP addresses of appen data to a single number
    for i=1:size(X,1)
        temp=find(IPCF_1==IPCF_1(i));
        if length(temp)==1 % if the IP address occurs only once
            y(i)=1; % keep
        elseif length(temp)>1 % if the IP addres occurs more than once
            y(temp(1))=1; % keep the first survey for that IP address
            y(temp(2:end))=2; % do not keep the other ones
        end
    end
    % respondents who completed the survey more than once (i.e., remove the
    % doublets)
    invalid4=find(y>1);
    %% Filter out data
    % Add together all invalid rows with data
    invalid = unique([invalid1;invalid2;invalid3;invalid4;invalid5]);
    X(invalid,:)=[]; % Remove invalid respondents
    Country(invalid)=[]; % Remove invalid countries
    raw_appen(invalid,:)=[]; % Remove invalid respondents
    %% Output with statistics and filtering information
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents who did not read instructions = ' num2str(length(invalid1))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents under 18 = ' num2str(length(invalid2))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents who took less than 300 s = ' num2str(length(invalid3))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of responses coming from the same IP = ' num2str(length(invalid4))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of rows in keypress data not matched:  ' num2str(length(invalid5))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents removed = ' num2str(length(invalid))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of respondents included in the analysis:  ' num2str(size(X,1))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Number of countries included in the analysis:  ' num2str(length(unique(Country)))])
    %% Gender, age
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Gender, male respondents = ' num2str(sum(X(:,2)==2))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Gender, female respondents = ' num2str(sum(X(:,2)==1))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Gender, I prefer not to respond = ' num2str(sum(isnan(X(:,2))))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Age, mean = ' num2str(nanmean(X(:,3)))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Age, sd = ' num2str(nanstd(X(:,3)))])
    %% Language
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Browser language set to English = '  num2str(sum(X(:,267)==0))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Browser language set to Spanish = '  num2str(sum(X(:,267)==1))])
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Browser language set to other language = '  num2str(sum(X(:,267)==2))])
    %% Survey time
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Survey time mean (minutes) - After filtering = ' num2str(nanmean(X(:,26)/60))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Survey time median (minutes) - After filtering = ' num2str(nanmedian(X(:,26)/60))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Survey time SD (minutes) - After filtering = ' num2str(nanstd(X(:,26)/60))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - First survey start date - After filtering = ' datestr(min(X(:,24)))]);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Last survey end date - After filtering = ' datestr(max(X(:,25)))]);
    %% Most common countries (after filtering)
    [~, ~, ub] = unique(Country);
    test2counts = histcounts(ub, 'BinMethod','integers');
    [B,I] = maxk(test2counts,10);
    country_unique = unique(Country);
    disp([datestr(now, 'HH:MM:SS.FFF') ' - Most common countries (after filtering) = '])
    disp(country_unique(I)')
    disp(B)
end
