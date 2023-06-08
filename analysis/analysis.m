
clear all;
close all

%% read csv data and convert to table
clear all;
close all;

folderName = "csv"; 
dataName = "data1"; %c
fileName = append(folderName, '\', dataName, '.csv');
T = readtable(fileName);

resultFolder = "table\";
resultName = append(resultFolder, dataName, '.mat');
save(resultName, 'T')

%% convert .mat file for each trial
clear all;
close all;

folderName = 'table\'; 
dataName = "data1"; %c
fileName = append(folderName, dataName, '.mat');
load(fileName);

trial = T.trial; 
trialNum = 9; %c number of trial

passResult = 'TrialData\';
mkdir(passResult, dataName);

for i = 1:trialNum
    %trialRows = strcmp(trial, int2str(i));
    trialRows = find(trial == i);
    obstacle = T.obstacle{trialRows};
    condition = T.condition{trialRows};
    cameraPositionX =  T.cameraPositionX(trialRows);
    cameraPositionY = T.cameraPositionY(trialRows);
    cameraPositionZ = T.cameraPositionZ(trialRows);
    time = T.time_ms(trialRows);
    
    mkdir(append(passResult, dataName, '\'), int2str(i));
    result1 = append(passResult, dataName, '\', int2str(i), '\obstacle.mat');
    save(result1, 'obstacle')
    result2 = append(passResult, dataName, '\', int2str(i), '\condition.mat');
    save(result2, 'condition')
    result3 = append(passResult, dataName, '\', int2str(i), '\cameraPositionX.mat');
    save(result3, 'cameraPositionX')
    result4 = append(passResult, dataName, '\', int2str(i), '\cameraPositionY.mat');
    save(result4, 'cameraPositionY')
    result5 = append(passResult, dataName, '\', int2str(i), '\cameraPositionZ.mat');
    save(result5, 'cameraPositionZ')
    result6 = append(passResult, dataName, '\', int2str(i), '\time.mat');
    save(result6, 'time')
end

%% movement path (xz)
clear all
close all

folderName = 'TrialData\'; 
dataName = "data1"; %c

trialNum = 9; %c number of trial
trainNum = 3;%c  number of train

fileName = append(folderName, dataName, '\', int2str(1), '\obstacle.mat');
load(fileName);

for i = trainNum+1:trialNum
    fileName1 = append(folderName, dataName, '\', int2str(i), '\cameraPositionX.mat');
    fileName2 = append(folderName, dataName, '\', int2str(i), '\cameraPositionZ.mat');
    load(fileName1);
    load(fileName2);
    
    % Get data between start to end from trial data.
    cameraPositionZ = -cameraPositionZ;
    dataLength = length(cameraPositionX);
    halfLength = round(dataLength/2); % Consider half length of data as between start to end data
    cameraPositionX = cameraPositionX(1:halfLength-150);
    cameraPositionZ = cameraPositionZ(1:halfLength-150);
    
    
    hold on
    plot(cameraPositionX, cameraPositionZ, 'LineWidth',1)
    title(append('All Trials Path towards "',obstacle, '"'))
    set(gca,'FontSize',16)
    ax = gca;
    xlim([-1.0 1.0])
    ylim([0 5.0])
    xlabel('x [m]')
    ylabel('z [m]')
    grid on
    box on
    
end
hold off
savfilename = append('fig/', 'path-', dataName, '.png');
saveas(gcf,savfilename)

%% avoidance direction 
clear all
close all

folderName = 'TrialData\'; 
dataName = "data1"; %c

trialNum = 9; %c number of trial
trainNum = 3;%c  number of train

fileName = append(folderName, dataName, '\', int2str(1), '\obstacle.mat');
load(fileName);

%counting avoidance based on condition
rightCountC = 0;
leftCountC = 0;
rightCountR = 0;
leftCountR= 0;
rightCountL = 0;
leftCountL= 0;

headonConditionNum = 0;
leftConditionNum = 0;
rightConditionNum = 0;



for i = trainNum+1:trialNum
    fileName1 = append(folderName, dataName, '\', int2str(i), '\cameraPositionX.mat');
    fileName2 = append(folderName, dataName, '\', int2str(i), '\cameraPositionZ.mat');
    load(fileName1);
    load(fileName2);
    
    fileName3 = append(folderName, dataName, '\', int2str(i), '\condition.mat');
    load(fileName3);
    
    % Get data between start to end from trial data.
    cameraPositionZ = -cameraPositionZ;
    dataLength = length(cameraPositionX);
    halfLength = round(dataLength/2); % Consider half length of data as between start to end data
    cameraPositionX = cameraPositionX(1:halfLength-150);
    cameraPositionZ = cameraPositionZ(1:halfLength-150);
    
    % Consider at z = 3m point as avoidance finished. 
    %Therefore, I can tell which direction avoid to see minus or plus of x at z = 3m.
    Above3m = cameraPositionX(cameraPositionZ>3);
    if strcmp(condition, 'head-on')
        headonConditionNum = headonConditionNum +1;
        if Above3m(1) > 0 
            rightCountC = rightCountC +1;
        else 
            leftCountC = leftCountC +1;
        end
    elseif strcmp(condition, 'right')
        rightConditionNum = rightConditionNum +1;
        if Above3m(1) > 0 
            rightCountR = rightCountR +1;
        else 
            leftCountR = leftCountR +1;
        end
    else 
        leftConditionNum = leftConditionNum +1;
        if Above3m(1) > 0 
            rightCountL = rightCountL +1;
        else 
            leftCountL = leftCountL +1;
        end
    end
    
    
end


%probability
PrightC = rightCountC/headonConditionNum;
PleftC = leftCountC/headonConditionNum;
PrightR = rightCountR/rightConditionNum;
PleftR = leftCountR/rightConditionNum;
PrightL = rightCountL/leftConditionNum;
PleftL = leftCountL/leftConditionNum;

avoidRightPercent = [PrightL; PrightC; PrightR];
avoidLeftPercent = [PleftL; PleftC; PleftR];

hold on
X = categorical({'Left','Headon','Right'});
X = reordercats(X,{'Left','Headon','Right'});
bar(X,avoidRightPercent,'b')
title(append('Towards "',obstacle, '"'))
ylim([0 1])
set(gca,'FontSize',16)
xlabel('Object Position ')
ylabel('Probability of Right Avoidance')
grid on
box on
hold off
savfilename = append('fig/', 'probabilityRight-', dataName, '.png');
saveas(gcf,savfilename)

hold on
X = categorical({'Left','Headon','Right'});
X = reordercats(X,{'Left','Headon','Right'});
bar(X,avoidLeftPercent,'b')
title(append('Towards "',obstacle, '"'))
ylim([0 1])
set(gca,'FontSize',16)
xlabel('Object Position ')
ylabel('Probability of Left Avoidance')
grid on
box on
hold off
savfilename = append('fig/', 'probabilityLeft-', dataName, '.png');
saveas(gcf,savfilename)
