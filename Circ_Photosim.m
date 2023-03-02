Receptor = 'I_L+M';
pr = 5;
files = dir('*.mat');
saveFig = true;
clear sample
downscale = 1/4;
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



photosimMap(:,:) = mel(:,:)./lumMap(:,:);

load([pwd,'photosimMap.mat']);

[coefs,score,latent,tsquared,explained] = pca(photosimMap');


fig=figure();
bar(explained)
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Ariel';
ax.LineWidth = 1.6;
xlabel('Component Number')
ylabel('Variance Explained')
xlim([0 50])
saveas(fig,'photosimPCAvar.png')
numComp = 0;
for c = 1:length(explained)
    if explained(c) >= 5
        numComp = numComp + 1;
    end
end


%%


for z= 1:numComp
    figure()
%     im = reshape(coefs(:,z),size(imgResize,1),size(imgResize,2));
    im = reshape(coefs(:,z),847,678);
    imshow(im./max(im,[],'all'))
    colormap(gca,colorcet('L3'))
    colorbar
    caxis([min(coefs(:,1:numComp),[],'all') max(coefs(:,1:numComp),[],'all')])
    title(sprintf('%s PC%d Weightings (Variance Explained: %s)',Receptor,z,num2str(round(explained(z)))))
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Ariel';
    if saveFig
        saveas(gca,[pwd,'/',sprintf('%s_PC%dweightings.png',Receptor,z)])
    end
end


%%

 fig = figure();
    for z= 1:numComp
        scores = photosimMap'*coefs;
        ts = timeseries(scores(:,z),newtimes);
        p = plot(ts);hold on
        p.LineWidth = 2;
    end
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('24-Jan-2023 00:00','Format','MM/dd HH:mm'))
    xtickformat('dd/MM')
    xlim([datetime('18-Jan-2023 00:00') datetime('25-Jan-2023 00:00')])
    for i = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
        patch([i i+hours(12) i+hours(12) i],[min(scores(:,1:numComp),[],'all')-50 min(scores(:,1:numComp),[],'all')-50 max(scores(:,1:numComp),[],'all')+50 max(scores(:,1:numComp),[],'all')+50],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
    end
    ylim([min(scores(:,1:numComp),[],'all')-50 max(scores(:,1:numComp),[],'all')+50])
    legend('PC1','PC2')
%     ax.XTickLabel = ax.XTickLabel;
    ylabel('PCA score')
    xlabel('Time')
    fig.Position = [0 0 1500 1000];
    title(sprintf('%s PC Score over Time',Receptor))
    ax.Children = flip(ax.Children);
    if saveFig
        saveas(gca,[pwd,'/',sprintf('%s_logPCscoresOverTime.png',Receptor)])
    end

