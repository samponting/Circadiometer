%% Data handling
% cd([pwd,'/test'])
clear
receptorClasses = ['S','M','L','R','I'];

for receptorClass = 5
    files = dir('*.mat');
    downscale = 1/4;
    % sample = zeros([3388*2712*downscale.^2,length(files)]);
    saveFig = true;
    clear sample
    for i = 1:length(files)
        disp(['processing image ',num2str(i)])
        load(files(i).name)
        imgResize = imresize(img(:,:,receptorClass), downscale);
        imgReshape = reshape(imgResize,[size(imgResize,1)*size(imgResize,2),1]);
        sample(:,i) = imgReshape;
        times{i} = files(i).name(1:end-4);
    end
    sample = sample';
    
    timestamp = datetime(times,'InputFormat','yyyy_MM_dd_HH_mm');
    newtimes = string(datetime(timestamp,'Format','MM/dd/uuuu HH:mm')');
    
    sample2 = sample;
    for x = 1:size(sample2,1)
        for y = 1:size(sample2,2)
            if sample2(x,y) <= 0
                sample2(x,y) = 0.0000001;
            end
        end
    end
    sample2 = log(sample2);
%     sample = real(sample);

    %% Spatial PCA
    
    [coefs,score,latent,tsquared,explained] = pca(sample2);
    
    fig=figure();
    bar(explained)
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    xlabel('Component Number')
    ylabel('Variance Explained')
    xlim([0 50])
    saveas(fig,'logPCAvar.png')
    numComp = 0;
    for c = 1:length(explained)
        if explained(c) >= 5
            numComp = numComp + 1;
        end
    end
    numComp = 2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  %%%%PLOTS%%%%
    %% Spatial weightings of PCs
    
    for z= 1:numComp
        figure()
        im = reshape(coefs(:,z),size(imgResize,1),size(imgResize,2));
        imshow(im)
        colormap(gca,colorcet('L3'))
        colorbar
        caxis([min(coefs(:,1:numComp),[],'all') max(coefs(:,1:numComp),[],'all')])
        title(sprintf('%s PC%d Weightings (Variance Explained: %s)',receptorClasses(receptorClass),z,num2str(round(explained(z)))))
        ax = gca;
        ax.FontSize = 8;
        ax.FontName = 'Ariel';
        if saveFig
            saveas(gca,[pwd,'/',sprintf('%s_logPC%dweightings.png',receptorClasses(receptorClass),z)])
        end
    end
    
    
    %% Score of PCs over timeframes
    fig = figure();
    for z= 1:numComp
        scores = sample*coefs;
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
    title(sprintf('%s PC Score over Time',receptorClasses(receptorClass)))
    ax.Children = flip(ax.Children);
    if saveFig
        saveas(gca,[pwd,'/',sprintf('%s_logPCscoresOverTime.png',receptorClasses(receptorClass))])
    end
    %% Cluster
    
    samplePC = coefs(:,1:3);
    clustNum = 3;
    [clusters,centroid] = kmeans(samplePC,clustNum,'Replicates',5);
    
    cm = colorcet('C8');
    clusterInd = 1/clustNum:1/clustNum:1;
    clustCol = cm(round(clusterInd.*256),:);
    fig = figure();
    p = gscatter(samplePC(:,1),samplePC(:,2),clusters,clustCol);
    
    % 3D plot
%     clustCol = cm(round(clusters./clustNum.*256),:);
%     scatter3(samplePC(:,1),samplePC(:,2),samplePC(:,3),2,clustCol);
%     scatter(samplePC(:,1),samplePC(:,2),2,clustCol);

%     scatter3(samplePC(:,1),samplePC(:,2),samplePC(:,3),2);

    %
    
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    xlabel('PC1')
    ylabel('PC2')
%     zlabel('PC3')
    title('K-means clustering')
    legend('Cluster 1','Cluster 2','Cluster 3','Location','northeast');
    axis square tight manual
    fig.Position = [0 0 790 1000];
    V = VideoWriter(sprintf('%s_log3dscatter',receptorClasses(receptorClass)));
    open(V);
    for n = 90:-2:30
        view([0,n])
        frame=getframe(gcf);
        writeVideo(V,frame)
    end
    for b = 1:2
        for n = 0:2:90
            view([n,30])
            frame=getframe(gcf);
            writeVideo(V,frame)
        end
        for n = 90:-2:0
            view([n,30])
            frame=getframe(gcf);
            writeVideo(V,frame)
        end
    end
    for n = 30:2:90
        view([0,n])
        frame=getframe(gcf);
        writeVideo(V,frame)
    end
    close(V);
    % 
    % if saveFig
    %     saveas(gca,'kmeansClustersScattered.png');
    % end
    
    clusterImg = reshape(clusters,size(imgResize,1),size(imgResize,2));
    clusterImg = cat(3,clusterImg,clusterImg,clusterImg)./clustNum;
    fig = figure();
    greyClustImg = rgb2gray(clusterImg);
    imshow(greyClustImg)
    colormap(gca,colorcet('C8'))
    title(sprintf('%s K-means clustering',receptorClasses(receptorClass)))
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    fig.Position = [790 0 650 1000];
    if saveFig
        saveas(gca,[pwd,'/test/',sprintf('%s_logclustersVisualised.png',receptorClasses(receptorClass))])
    end
    
    
    %% Temporal PCA
    numComp = 2;
    clustCol = cm(round(clusterInd.*256),:);
    for z = 1:clustNum
        fig = figure();
        sample3 = sample2(:,find(clusters==z));
        coefs2 = coefs(find(clusters==z),:);
        score2 = sample3*coefs2;
        for x= 1:numComp
            ts = timeseries(score2(:,x),newtimes);
            p = plot(ts);hold on
            p.LineWidth = 2;
        end
        ax = gca;
        ax.FontSize = 16;
        ax.FontName = 'Ariel';
        ax.LineWidth = 1.6;
        xticks(datetime('18-Jan-2023 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('25-Jan-2023 00:00','Format','MM/dd HH:mm'))
        xtickformat('dd/MM')
        xlim([datetime('18-Jan-2023 12:00') datetime('25-Jan-2023 14:00')])
    %     for i = datetime('29-Oct-2022 12:00'):caldays(1):datetime('07-Nov-2022 12:00')
    %         patch([i i+hours(12) i+hours(12) i],[min(score(:,1:numComp),[],'all')-50 min(score(:,1:numComp),[],'all')-50 max(score(:,1:numComp),[],'all')+50 max(score(:,1:numComp),[],'all')+50],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
    %     end
        for j = datetime('18-Jan-2023 12:00'):caldays(1):datetime('24-Jan-2023 12:00')
            patch([j j+hours(12) j+hours(12) j],[min(score2(:,1:numComp),[],'all')-50 min(score2(:,1:numComp),[],'all')-50 max(score2(:,1:numComp),[],'all')+50 max(score2(:,1:numComp),[],'all')+50],clustCol(z,:),'FaceAlpha',0.5,'LineStyle','none')
        end
        ylim([min(score2(:,1:numComp),[],'all')-50 max(score2(:,1:numComp),[],'all')+50])
        legend('PC1','PC2')
%         ax.XTickLabel = ax.XTickLabel;
        ylabel('PCA score')
        xlabel('Time')
        fig.Position = [0 0 1500 600];
        title(sprintf('%s PC Score over Time: Cluster %d',receptorClasses(receptorClass),z))
        ax.Children = flip(ax.Children);
        if saveFig
            saveas(gca,[pwd,'/test/',sprintf('%s_logPCscoresOverTimeCluster%d.png',receptorClasses(receptorClass),z)])
        end
    end
    close all
end
