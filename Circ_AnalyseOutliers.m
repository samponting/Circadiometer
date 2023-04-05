%% Circ_AnalyseOutliers
addpath([pwd,'/other']);
files = dir('*.mat');
for i = 1:length(files)
    times{i} = files(i).name(1:end-4);
end
timestamp = datetime(times,'InputFormat','yyyy_MM_dd_HH_mm');
newtimes = string(datetime(timestamp,'Format','MM/dd/uuuu HH:mm')');

%%
load('correlationCoefficients.mat')
r = squeeze(R(1,2,:,4));
fig = figure();
ts = timeseries(r,newtimes(1:end-1));
plot(ts,'LineWidth',2);hold on
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
for i = datetime('18-Jan-2023 16:45'):caldays(1):datetime('24-Jan-2023 16:45:00')
    fill([i i+hours(1.25) i+hours(1.25) i],[0 0 2 2],[0.5 0 0.5],'FaceAlpha',0.5,'LineStyle','none')
end
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[0 0 1 1],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylabel('Correlation Coefficient (R)')
xlabel('Time')
ylim([0.07 1])
% legend('Inside','Outside','Whole Image')
% legend('In')
fig.Position = [0 0 1500 1000];
title('Melanopsin-Luminance Correlations: Screen')
ax.Children = flip(ax.Children);

% saveas(fig,[pwd,'/correlationFigures/correlationCoefficientsOverTimeScreenWithMarkers.png'])

%%
load('regressionSlope.mat')
fig = figure();
ts = timeseries(lineSlope(:,3),newtimes(1:end-1));
plot(ts,'LineWidth',2);hold on
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
for i = datetime('18-Jan-2023 16:45'):caldays(1):datetime('24-Jan-2023 16:45:00')
    fill([i i+hours(1.25) i+hours(1.25) i],[0 0 21 21],[0.5 0 0.5],'FaceAlpha',0.5,'LineStyle','none')
end
for i = datetime('18-Jan-2023 07:45'):caldays(1):datetime('24-Jan-2023 07:45')
    fill([i i+hours(1) i+hours(1) i],[0 0 21 21],[0 0.5 0.5],'FaceAlpha',0.5,'LineStyle','none')
end
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[0 0 21 21],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylim([0 21])
ylabel('Regression Slope (B)')
xlabel('Time')
% legend('Inside','Outside','Whole Image')
% legend('Whole Image')

fig.Position = [0 0 1500 1000];
title('Mel-Lum Correlation Slope: Screen')
ax.Children = flip(ax.Children);

saveas(fig,[pwd,'/correlationFigures/SlopeGradientOverTimeScreenWithMarkers.png'])


%%

load('lowerOutliers.mat')
fig = figure();
ts = timeseries(numLowerOutliers(:,[1 2]),newtimes(1:end-1));
plot(ts,'LineWidth',2);hold on
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
% for i = datetime('18-Jan-2023 16:45'):caldays(1):datetime('24-Jan-2023 16:45:00')
%     fill([i i+hours(1.25) i+hours(1.25) i],[0 0 2 2],[0.5 0 0.5],'FaceAlpha',0.5,'LineStyle','none')
% end
% for i = datetime('18-Jan-2023 07:45'):caldays(1):datetime('24-Jan-2023 07:45')
%     fill([i i+hours(1) i+hours(1) i],[0 0 2 2],[0 0.5 0.5],'FaceAlpha',0.5,'LineStyle','none')
% end
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[0 0 40000 40000],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylim([0 6500])
ylabel('Number of Outliers')
xlabel('Time')
legend('Inside','Outside')
% legend('Whole Image')

fig.Position = [0 0 1500 1000];
title("Number of 'Luminous' Outliers")
ax.Children = flip(ax.Children);

saveas(fig,[pwd,'/correlationFigures/LuminousOutliers.png'])

























