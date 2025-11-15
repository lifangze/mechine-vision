% --- extractMyHOGFeatures.m ---
% (最终版 v9: 确保使用原始灰度图)
function [features, labels] = extractMyHOGFeatures(datasetPath)
    features = [];
    labels = {};
    fprintf('开始使用 HOG 特征法提取特征 (基于灰度图)...\n');
    if ~exist(datasetPath, 'dir'), error('错误: 找不到数据集文件夹 "%s"。', datasetPath); end
    d = dir(datasetPath);
    subFolders = d([d.isdir]);
    classFolders = subFolders(~ismember({subFolders.name},{'.','..'}));
    if isempty(classFolders), error('错误: 在 "%s" 文件夹下没有找到任何类别子文件夹。', datasetPath); end
    
    RESIZE_SIZE = [48 48];

    for i = 1:length(classFolders)
        folderName = classFolders(i).name;
        fullFolderPath = fullfile(datasetPath, folderName);
        matFiles = dir(fullfile(fullFolderPath, '*.mat'));
        fprintf('正在处理类别: %s (%d 个文件)\n', folderName, length(matFiles));
        
        for j = 1:length(matFiles)
            data = load(fullfile(fullFolderPath, matFiles(j).name));
            % 直接使用原始的 uint8 灰度图
            charImage = data.imageArray;
            
            resizedImage = imresize(charImage, RESIZE_SIZE);
            hogFeatures = extractHOGFeatures(resizedImage);
            
            features = [features; hogFeatures];
            labels = [labels; {folderName}]; 
        end
    end
    fprintf('特征提取完成！\n');
end