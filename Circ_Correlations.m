% Circ_Correlations

pr = 5;
files = dir('*.mat');
saveFig = true;
clear sample
downscale = 1/16;
for i = 1:length(files)
    disp(['processing image ',num2str(i)])
    load(files(i).name)
    imgResize = imresize(img(:,:,pr), downscale);
    imgReshape = reshape(imgResize,[size(imgResize,1)*size(imgResize,2),1]);
    mel(:,i) = imgReshape;
    lumMapx = 0.68990272.*img(:,:,2)+0.34832189.*img(:,:,3);
    lumResize = imresize(lumMapx,downscale);
    mapReshape = reshape(lumResize,[size(lumResize,1)*size(lumResize,2),1]);
    lumMap(:,i) = mapReshape;
    times{i} = files(i).name(1:end-4);
end

timestamp = datetime(times,'InputFormat','yyyy_MM_dd_HH_mm');
newtimes = string(datetime(timestamp,'Format','MM/dd/uuuu HH:mm')');


for i = 1:size(lumMap,2)
    [R(:,:,i),p(:,:,i)] = corrcoef(mel(:,i),lumMap(:,i));
end

%%

fig = figure();

ts = timeseries(squeeze(R(1,2,:)),newtimes);
p = plot(ts);hold on
p.LineWidth = 2;
p.Color = [0.15,0.85,0.85];

ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
for i = datetime('18-Jan-2023 16:45'):caldays(1):datetime('24-Jan-2023 16:45:00')
    fill([i i+hours(1.25) i+hours(1.25) i],[0 0 1 1],[0.5 0 0.5],'FaceAlpha',0.5,'LineStyle','none')
end
for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[0 0 1 1],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
ylim([0 1])
% legend('S cone')
ylabel('Correlation Coefficient (R)')
xlabel('Time')
fig.Position = [0 0 1500 1000];
title('Luminance-Melanopsin Correlation Over Time')
ax.Children = flip(ax.Children);

% saveas(fig,[pwd,'/Lum-MelCorrelation.png'])

saveas(fig,[pwd,'/Lum-MelCorrelationWithTimeMarkers.png'])

%%
for x = 1:size(mel,1)
    for y = 1:size(mel,2)
    photosimMap(x,y) = mel(x,y)./lumMap(x,y);
    end
end
photosimMap = mel./lumMap;
photosimMean = mean(photosimMap);
photosimSTD = std(photosimMap);
%%

fig = figure();

ts = timeseries(photosimMean,newtimes);
p = plot(ts);hold on
p.LineWidth = 2;
p.Color = [0.15,0.85,0.85];

ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
xtickformat('dd/MM')
xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])

for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
    fill([i i+hours(12) i+hours(12) i],[-1 -1 7 7],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
end
% ylim([0 0.01])
% legend('S cone')
ylabel('Mel/(L+M)')
xlabel('Time')
fig.Position = [0 0 1500 1000];
title('Mel-Luminance Ratio Over Time')
ax.Children = flip(ax.Children);

if saveFig
    saveas(fig,'MelLumRatioOverTime.png')
end
%%
pr = 5;
files = dir('*.mat');
downscale = 1/4;
load([pwd,'/other/clusterMap.mat'])
greyClustImg = greyClustImg.*3;
for z = 1:4
    filter = greyClustImg == z;
    filterReshape = reshape(filter, [size(filter,1)*size(filter,2),1]);
    if z == 4
        filterReshape(filterReshape == 0) = 1;
    end
    for i = 1:length(files)-1
%         fig = figure();
        fprintf('\nloading file %s of 398', num2str(i));
        load(files(i).name);
        
        imgResize = imresize(img(:,:,pr), downscale);
        imgReshape = reshape(imgResize,[size(imgResize,1)*size(imgResize,2),1]);
        testmel = imgReshape.*filterReshape;
        lumMapx = 0.68990272.*img(:,:,2)+0.34832189.*img(:,:,3);
        lumResize = imresize(lumMapx,downscale);
        mapReshape = reshape(lumResize,[size(lumResize,1)*size(lumResize,2),1]);
        testlumMap = mapReshape.*filterReshape;
    
        [R(:,:,i,z),p(:,:,i,z)] = corrcoef(testmel,testlumMap);
        
        [b,bint,r,rint] = regress(testmel,[ones(length(testlumMap),1),testlumMap]);
        upperOutliers = find(r>0.45);
        lowerOutliers = find(r<-0.45);
        numUpperOutliers(i,z) = length(upperOutliers);
        numLowerOutliers(i,z) = length(lowerOutliers);
        lineSlope(i,z) = b(2);
        testmelx = testmel;
        testmelx(testmelx<0) = 0;
        OLimage = cat(3,testmelx,testmelx,testmelx);
        OLimage(OLimage<0) = 0;
        OLimage = OLimage./max(OLimage,[],'all');
        OLimage = OLimage.^(1/4);
        OLimage(upperOutliers,1) = 1;OLimage(upperOutliers,2) = 0;OLimage(upperOutliers,3) = 0;
        OLimage(lowerOutliers,1) = 1;OLimage(lowerOutliers,2) = 1;OLimage(lowerOutliers,3) = 0;
    
        x = 0:0.01:max(testlumMap);
        y=b(2)*x+b(1);
        testmelImg = reshape(OLimage,[size(lumResize,1),size(lumResize,2),3]);
%         subplot(3,2,1)
%         scatter(testlumMap,testmel,'filled','b');hold on;
%         scatter(testlumMap(upperOutliers),testmel(upperOutliers),'filled','r')
%         scatter(testlumMap(lowerOutliers),testmel(lowerOutliers),'filled','y')
%         timestamp = datetime(files(i).name(1:end-4),'InputFormat','yyyy_MM_dd_HH_mm');
%         ylabel('Melanopsin')
%         xlabel('Luminance')
%         xlim([0 6.2])
%         ylim([0 6.2])
%         title(string(timeofday(timestamp)))
%         plot(x,y,'LineWidth',2)
%         subplot(3,2,3)
%         scatter(testlumMap,testmel,'filled','b');hold on;
%         scatter(testlumMap(upperOutliers),testmel(upperOutliers),'filled','r')
%         scatter(testlumMap(lowerOutliers),testmel(lowerOutliers),'filled','y')
%         ylabel('Melanopsin')
%         xlabel('Luminance')
%         xlim([0 0.4])
%         ylim([0 0.4])
%         plot(x,y,'LineWidth',2)
%         subplot(3,2,5)
%         histogram(r,10,'FaceColor','b','BinEdge',-1:0.02:1);
%         xlim([-1 1])
%         xlabel('Residual')
%         ylabel('Frequency')
%         xlim([-1 1])
%         subplot(1,2,2)
%         imshow(testmelImg)
%         title(string(timestamp))
%         saveas(fig,sprintf('%s_Cluster%sShowOutliers.png',string(files(i).name(1:end-4)),num2str(z)))
%         if z == 4
%             saveas(fig,sprintf('%s_WholeImageShowOutliers.png',string(files(i).name(1:end-4))))
%         end
%         close all
    end
end

save([pwd,'/other/correlationCoefficients.mat'],'R','p')
save([pwd,'/other/UpperOutliers.mat'],'numUpperOutliers')
save([pwd,'/other/LowerOutliers.mat'],'numLowerOutliers')
save([pwd,'/other/regressionSlope.mat'],'lineSlope')




