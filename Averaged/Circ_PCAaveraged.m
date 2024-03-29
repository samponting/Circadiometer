%% Data handling
clear
receptorClasses = ['S','M','L','R','I'];
for receptorClass = 1:5
    clear sample
    files = dir('*.mat');
    downscale = 1/4;
    % sample = zeros([3388*2712*downscale.^2,length(files)]);
    saveFig = true;
    for i = 1:length(files)
        disp(['processing image ',num2str(i)])
        load(files(i).name)
        img = averageIm;
        imgResize = imresize(img(:,:,receptorClass), downscale);
%         imgResize = imresize(img, downscale);
        imgReshape = reshape(imgResize,[size(imgResize,1)*size(imgResize,2),1]);
        sample(:,i) = imgReshape;
        times{i} = files(i).name(1:end-4);
    end
    sample = sample';
    
    timestamp = datetime(times,'InputFormat','HH_mm');
    newtimes = string(datetime(timestamp,'Format','HH:mm')');
    
    %% Spatial PCA
    
    [coefs,score,latent,tsquared,explained] = pca(sample);
    
    numComp = 0;
    for c = 1:length(explained)
        if explained(c) >= 5
            numComp = numComp + 1;
        end
    end
    numComp = 3;
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
        ax.FontSize = 16;
        ax.FontName = 'Ariel';
        if saveFig
            saveas(gca,[pwd,'/test/',sprintf('%s_PC%dweightings.png',receptorClasses(receptorClass),z)])
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
    % xticks(datetime('8-Dec-2022 00:00','Format','HH:mm'):hours(1):datetime('9-Dec-2022 00:00','Format','HH:mm'))
    % xtickformat('dd-MMM-yyyy HH:mm')
    % xlim([datetime('29-Oct-2022 12:00') datetime('07-Nov-2022 14:00')])
    % for i = datetime('29-Oct-2022 12:00'):caldays(1):datetime('07-Nov-2022 12:00')
    patch([0.5 1 1 0.5],[min(scores(:,1:numComp),[],'all')-50 min(scores(:,1:numComp),[],'all')-50 max(scores(:,1:numComp),[],'all')+50 max(scores(:,1:numComp),[],'all')+50],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
    % end
    ylim([min(scores(:,1:numComp),[],'all')-50 max(scores(:,1:numComp),[],'all')+50])
    legend('PC1','PC2','PC3')
    % ax.XTickLabel = ax.XTickLabel;
    ylabel('PCA score')
    xlabel('Time (Days)')
    fig.Position = [0 0 1500 1000];
    title(sprintf('%s PC Score over Time',receptorClasses(receptorClass)))
    ax.Children = flip(ax.Children);
    if saveFig
        saveas(gca,[pwd,'/test/',sprintf('%s_PCscoresOverTime.png',receptorClasses(receptorClass))])
    end
    %% Cluster
    
    samplePC = coefs(:,1:3);
    clustNum = 4;
    [clusters,centroid] = kmeans(samplePC,clustNum,'Replicates',500);
    
    cm = colorcet('C8');
    clusterInd = 1/clustNum:1/clustNum:1;
    clustCol = cm(clusterInd.*256,:);
    fig = figure();
%     p = gscatter(samplePC(:,1),samplePC(:,2),clusters,clustCol);
    
    % 3D plot
    clustCol = cm(clusters./4.*256,:);
    scatter3(samplePC(:,1),samplePC(:,2),samplePC(:,3),2,clustCol);
    %
    
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    xlabel('PC1')
    ylabel('PC2')
    zlabel('PC3')
    title('K-means clustering (Averaged Day)')
    % legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','northeast');
    axis square
    fig.Position = [0 0 790 1000];
    
    V = VideoWriter(sprintf('%s_3dscatter',receptorClasses(receptorClass)));
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
    
%     if saveFig
%         saveas(gca,'kmeansClustersScatteredDownscaled.png');
%     end
    
    clusterImg = reshape(clusters,size(imgResize,1),size(imgResize,2));
    clusterImg = cat(3,clusterImg,clusterImg,clusterImg)./clustNum;
    fig = figure();
    greyClustImg = rgb2gray(clusterImg);
    imshow(greyClustImg)
    colormap(gca,colorcet('C8'))
    title(sprintf('%s K-means clustering (Averaged day)',receptorClasses(receptorClass)))
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Ariel';
    ax.LineWidth = 1.6;
    fig.Position = [790 0 650 1000];
    if saveFig
        saveas(gca,[pwd,'/test/',sprintf('%s_clustersVisualised.png',receptorClasses(receptorClass))])
    end
    
    
    %% Temporal PCA
    clustCol = cm(clusterInd.*256,:);
    for z = 1:clustNum
        fig = figure();
        sample2 = sample(:,find(clusters==z));
        coefs2 = coefs(find(clusters==z),:);
        score2 = sample2*coefs2;
        for x= 1:numComp
            ts = timeseries(score2(:,x),newtimes);
            p = plot(ts);hold on
            p.LineWidth = 2;
        end
        ax = gca;
        ax.FontSize = 16;
        ax.FontName = 'Ariel';
        ax.LineWidth = 1.6;
    %     xticks(datetime('29-Oct-2022 00:00','Format','dd/MM HH:mm'):caldays(1):datetime('07-Nov-2022 00:00','Format','MM/dd HH:mm'))
    %     xtickformat('dd/MM')
    %     xlim([datetime('29-Oct-2022 12:00') datetime('07-Nov-2022 14:00')])
    %     for i = datetime('29-Oct-2022 12:00'):caldays(1):datetime('07-Nov-2022 12:00')
    %         patch([i i+hours(12) i+hours(12) i],[min(score(:,1:numComp),[],'all')-50 min(score(:,1:numComp),[],'all')-50 max(score(:,1:numComp),[],'all')+50 max(score(:,1:numComp),[],'all')+50],[0.8 0.8 0.8],'FaceAlpha',0.5,'LineStyle','none')
    %     end
    %     for j = datetime('29-Oct-2022 00:00'):caldays(1):datetime('07-Nov-2022 00:00')
        patch([0.5 1 1 0.5],[min(score(:,1:numComp),[],'all')-50 min(score(:,1:numComp),[],'all')-50 max(score(:,1:numComp),[],'all')+50 max(score(:,1:numComp),[],'all')+50],clustCol(z,:),'FaceAlpha',0.5,'LineStyle','none')
    %     end
        ylim([min(score(:,1:numComp),[],'all')-50 max(score(:,1:numComp),[],'all')+50])
        legend('PC1','PC2')
    %     ax.XTickLabel = ax.XTickLabel;
        ylabel('PCA score')
        xlabel('Time')
        fig.Position = [0 0 1000 1000];
        title(sprintf('%s PC Score over Time: Cluster %d',receptorClasses(receptorClass),z))
        ax.Children = flip(ax.Children);
        if saveFig
            saveas(gca,[pwd,'/test/',sprintf('%s_PCscoresOverTimeCluster%d.png',receptorClasses(receptorClass),z)])
        end
    end
    close all
end
