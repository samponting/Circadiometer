files = dir('*.mat');
receptorClasses = ['S','M','L','R','I'];

means = zeros(length(files),5);
stds = zeros(length(files),5);

saveFig = true;
for i = 1:length(files)
    disp(['processing image ',num2str(i)])
    load(files(i).name)
    means(i,:) = mean(img,1:2);
    for x = 1:5
        stds(i,x) = std(img(:,:,x),[],1:2)/sqrt(size(img,1)*size(img,2));
        maxes(i,x) = max(img(:,:,x),[],'all');
    end
    times{i} = files(i).name(1:end-4);
end


timestamp = datetime(times,'InputFormat','yyyy_MM_dd_HH_mm');
newtimes = string(datetime(timestamp,'Format','MM/dd/uuuu HH:mm')');

colors = [0.15,0.15,0.85;0.15,0.85,0.15;0.85,0.15,0.15;0.15,0.15,0.15;0.15,0.85,0.85];
%%
fig = figure();
for z= 1:5
    ts = timeseries(means(:,z),newtimes);
    p = plot(ts);hold on
    p.LineWidth = 2;
    p.Color = colors(z,:);
end
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
% for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
%     patch('XData',[i i+hours(12) i+hours(12) i],'YData',[0 0 0.5 0.5],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
% end
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[0 0 0.5 0.5],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylim([0 0.5])
legend('S cone','M cone','L cone','Rod','ipRGC')
%     ax.XTickLabel = ax.XTickLabel;
ylabel('Irradiance')
xlabel('Time')
fig.Position = [0 0 1500 1000];
title('Mean Irradiance over Time')
ax.Children = flip(ax.Children);

if saveFig
    saveas(fig,'MeanRadianceOverTime.png')
end

%% Radiance Maps

for d = 1:7
    for p = 1:5
        dayind = 17+d;
        daymax(d,p) = max(means(day(timestamp)==dayind,p));
        daymaxind(d,p) = find(means(:,p) == daymax(d,p));
        daymaxtime(d,p) = timestamp(daymaxind(d,p));
        daymaxtimestr(d,p) = string(timeofday(timestamp(daymaxind(d,p))));
    end
end

for d = 1:7
    for p = 1:5
        fig = figure();
        load(files(daymaxind(d,p)).name)
        maxval = max(maxes,[],'all');
        imshow(img(:,:,p));
        colormap(colorcet('L3'));
        colorbar;
        caxis([0,maxval])
        title([string(daymaxtime(d,p)),' : ',num2str(daymax(d,p))])
        saveas(fig,sprintf('%s_maxRadianceDay%s.png',receptorClasses(p),num2str(d)))
        close all
    end
end

%% Max Radiance across each day



for i = 1:5
    dayplotvals((1+((i-1)*7)):(7+((i-1)*7)),1) = daymaxtimestr(1:7,i);
    dayplotvals2((1+((i-1)*7)):(7+((i-1)*7)),1) = 1:7;
end

for i = 1:5
    plotRec(((i-1)*7)+1:(i*7)) = i;
end

% scatter(datetime(dayplotvals),dayplotvals2)


for i = 1:5
    scatter3(dayplotvals2(((i-1)*7)+1:(i*7)),plotRec(((i-1)*7)+1:(i*7)),datetime(dayplotvals(((i-1)*7)+1:(i*7))),200,'MarkerFaceColor',colors(i,:),'MarkerEdgeColor','none');hold on
end

xlabel('Day')
xlim([0 7])
xticks(1:7)
yticks([])
legend('S Cone','M Cone','L Cone','Rod','ipRGC','Location','northeast')
ztickformat('HH:mm')
title('Time of Maximal Radiance')
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;


%% STD plot

fig = figure();
for z= 1:5
    ts = timeseries(stds(:,z),newtimes);
    p = plot(ts);hold on
    p.LineWidth = 2;
    p.Color = colors(z,:);
end
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    patch([i i+hours(12) i+hours(12) i],[0 0 0.5 0.5],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylim([0 0.0006])
legend('S cone','M cone','L cone','Rod','ipRGC')
%     ax.XTickLabel = ax.XTickLabel;
ylabel('Standard Deviation')
xlabel('Time')
fig.Position = [0 0 1500 1000];
title('Standard Deviation of Radiance over Time')
ax.Children = flip(ax.Children);
saveas(fig,[pwd,'/STDRadiance.png'])

%% Variation Over the Day
for x = 1:5
    for i = 14:370
        curday = day(timestamp(i));
        daymeans(i-13-((curday-18)*51),curday-17,x) = means(i,x);
    end
end
dayVar = squeeze(std(daymeans,[],2));



fig = figure();
for z= 1:5
    ts = timeseries(dayVar(:,z),newtimes(14:64));
    p = plot(ts);hold on
    p.LineWidth = 2;
    p.Color = colors(z,:);
end
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):hours(2):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('HH:mm')
xlim([datetime('18-Jan-2023 00:00') datetime('18-Jan-2023 22:00')])
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('29-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[0 0 0.5 0.5],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylim([0 0.5])
legend('S cone','M cone','L cone','Rod','ipRGC')
ax.XTickLabel = ax.XTickLabel;
ylim([0 0.2])
ylabel('Standard Error')
xlabel('Time')
fig.Position = [0 0 1500 1000];
title('Variability of Irradiance Across Days')
ax.Children = flip(ax.Children);
saveas(fig,[pwd,'/VariationThroughoutTheDay.png'])


%% Irradiance Throughout The Day Per Region

files = dir('*.mat');
receptorClasses = ['S','M','L','R','I'];
load([pwd,'/other/clusterMap.mat'])
greyClustImg = greyClustImg.*3;
downscale = 1/4;
means = zeros(length(files),5);
stds = zeros(length(files),5);
timestamp = datetime(times,'InputFormat','yyyy_MM_dd_HH_mm');
newtimes = string(datetime(timestamp,'Format','MM/dd/uuuu HH:mm')');


saveFig = true;
for i = 1:length(files)
    disp(['processing image ',num2str(i)])
    load(files(i).name)
    imgResize = imresize(img, downscale);
    imgReshape = reshape(imgResize,[size(imgResize,1)*size(imgResize,2),5]);

    for z = 1:3
        filter = greyClustImg == z;
        filterReshape = reshape(filter, [size(filter,1)*size(filter,2),1]);
        test = imgReshape.*filterReshape;
        for y = 1:5
            means(i,y,z) = mean(test(find(test(:,y)>0),y),1);
            stds(i,y,z) = std(test(find(test(:,y)>0),y))/sqrt(size(test,1));
        end
    end
    times{i} = files(i).name(1:end-4);
end
%%
colors = [0.15,0.15,0.85;0.15,0.85,0.15;0.85,0.15,0.15;0.15,0.15,0.15;0.15,0.85,0.85];

for cluster = 1:3
    fig = figure();
    for z= 1:5
        ts = timeseries(means(:,z,cluster),newtimes);
        p = plot(ts);hold on
        p.LineWidth = 2;
        p.Color = colors(z,:);
    end
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
    xtickformat('dd/MM')
    xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
    % for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    %     patch('XData',[i i+hours(12) i+hours(12) i],'YData',[0 0 0.5 0.5],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
    % end
    for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
        fill([i i+hours(12) i+hours(12) i],[0 0 0.5 0.5],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
    end
%     ylim([0 0.5])
    legend('S cone','M cone','L cone','Rod','ipRGC')
    %     ax.XTickLabel = ax.XTickLabel;
    ylabel('Irradiance')
    xlabel('Time')
    fig.Position = [0 0 1500 1000];
    title('Mean Irradiance over Time')
    ax.Children = flip(ax.Children);
end











