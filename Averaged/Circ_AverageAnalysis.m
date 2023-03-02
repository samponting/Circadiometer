receptorClasses = ['S','M','L','R','I'];
receptorClass = 5;
files = dir('*.mat');
downscale = 1/8;
saveFig = true;
clear sample
for i = 1:length(files)
    disp(['processing image ',num2str(i)])
    load(files(i).name)
    imgResize = imresize(averageIm(:,:,receptorClass), downscale);
    sample(:,:,i) = imgResize;
    times{i} = files(i).name(1:end-4);
end

timestamp = datetime(times,'InputFormat','HH_mm');
newtimes = string(datetime(timestamp,'Format','HH:mm')');

V = VideoWriter(sprintf('%s_activationMap',receptorClasses(receptorClass)));
open(V);

sampleMeans = squeeze(mean(sample,1:2));
sampleSTD = squeeze(std(sample,0,1:2))./sqrt(size(sample,1)*size(sample,2));
fig = figure();
fig.Position = [0 0 2000 2000];
xs = 0:1/24:23/24;
for i = 1:size(sample,3)
    subplot(1,2,1)
    imshow(sample(:,:,i))
    c = colorcet('L3');
    colormap(c)
    colorbar
    subplot(1,2,2)
    ts = timeseries(sampleMeans(1:i),newtimes(1:i));hold on
    ts.TimeInfo.Units = 'hours';
    plot(ts,'LineWidth',2,'Color','blue');hold on
%     errorbar(xs(1:i),sampleMeans(1:i),sampleSTD(1:i),'LineStyle','none');hold on
    ax = gca;
    ax.XTick = 0:1/24:23/24;
    ax.XTickLabels = 0:24;
    ax.XLim = [0 1];
    ax.YLim = [0 max(sampleMeans)*1.1];
    title('Average Melanopic Light')
    xlabel('Time (Hours)')
    ylabel('Average Radiance (W/st/m^2)')
    axis square
    frame=getframe(gcf);
    writeVideo(V,frame)
end

fig2 = figure();
[~,maxActTime] = max(sampleMeans);
imshow(sample(:,:,maxActTime))
title(sprintf('Time of Maximal Activation: %s',newtimes(maxActTime)))
colormap(c)
colorbar
saveas(gca,[pwd,sprintf('/%s_maxActivation.png',receptorClasses(receptorClass))])



