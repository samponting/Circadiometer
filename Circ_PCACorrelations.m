% Correlation PCA / CCT
% Circadiometer data: [S M L R I]
% Plan: do PCA on each photoreceptor class, then find the pairwise
% correlations

files = dir('*.mat');
downscale = 1/16;
saveFig = false;

% sample = zeros([3388*2712*downscale.^2,length(files)]);
for i = 1:length(files)
    disp(['processing image ',num2str(i)])
    load(files(i).name)
    imgResize = imresize(img(:,:,1:5), downscale);
    imgReshape = reshape(imgResize,[size(imgResize,1)*size(imgResize,2),5]);
    sample(:,i,:) = imgReshape;
    times{i} = files(i).name(1:end-4);
end
% sample = sample';

timestamp = datetime(times,'InputFormat','yyyy_MM_dd_HH_mm');
newtimes = string(datetime(timestamp,'Format','MM/dd/uuuu HH:mm:ss')');


%% PC 1
for i = 1:5

    [coefs,score,latent,tsquared,explained] = pca(sample(:,:,i)');
    PC1(:,i) = coefs(:,1);
    PC2(:,i) = coefs(:,2);

end

[R,P] = corrcoef(PC1);
[R2,P2] = corrcoef(PC2);

luminanceMap = 0.68990272.*sample(:,:,2)+0.34832189.*sample(:,:,3);


[coefs,score,latent,tsquared,explained] = pca(luminanceMap');

[d,MelonLum,transform] = procrustes([coefs(:,1) coefs(:,2)], [PC1(:,5) PC2(:,5)]);

% 
corrcoef(coefs(:,1),MelonLum(:,1))
corrcoef(coefs(:,2),MelonLum(:,2))

% corrcoef(coefs(:,1),PC1(:,5))
% corrcoef(coefs(:,2),PC2(:,5))

scatter(coefs(:,2),MelonLum(:,2));hold on
scatter(coefs(:,1),MelonLum(:,1));

% scatter(coefs(:,2),PC1(:,5));hold on
% scatter(coefs(:,1),PC2(:,5));
xlabel('luminance')
ylabel('melanopsin')
% load([pwd '/cluster/clusters.mat'])

clustNum = 4;
cm = colorcet('C8');
clusterInd = 1/clustNum:1/clustNum:1;
clustCol = cm(clusterInd.*256,:);
gscatter(MelonLum(:,1),MelonLum(:,2),clusters,clustCol./1.3);hold on
gscatter(coefs(:,1),coefs(:,2),clusters,clustCol./max(clustCol,[],'all'));

