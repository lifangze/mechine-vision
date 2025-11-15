% --- 0. 环境清理 ---
clear; clc; close all;

%% --- 阶段一 & 二: 检查模型，如果不存在则训练 ---
classifierFile = 'charClassifier_Grayscale_HOG_SVM.mat';

if exist(classifierFile, 'file')
    fprintf('检测到已保存的最终模型文件，正在加载...\n');
    load(classifierFile);
    fprintf('模型加载成功！\n');
else
    fprintf('未检测到模型文件，将执行完整的训练与验证流程...\n');
    
    % --- 阶段一: 提取特征并翻译标签 ---
    [features, rawLabels] = extractMyHOGFeatures('p_dataset_26');
    fprintf('\n--- 正在转换标签 ---\n');
    labelMap = containers.Map(...
        {'Sample1', 'Sample2', 'Sample3', 'SampleA', 'SampleB', 'SampleC'}, ...
        {'1', '2', '3', 'A', 'B', 'C'});
    finalLabels = cell(size(rawLabels));
    for i = 1:length(rawLabels), finalLabels{i} = labelMap(rawLabels{i}); end
    fprintf('标签转换完成！\n');

    % --- 阶段二: 划分、训练并验证 SVM 分类器 ---
    fprintf('\n--- 开始训练和验证 SVM 分类器 ---\n');

    % 【已修改】将数据划分为 75% 训练集 和 25% 验证集
    cv = cvpartition(finalLabels, 'HoldOut', 0.25);
    trainingFeatures = features(cv.training, :);
    trainingLabels = finalLabels(cv.training, :);
    validationFeatures = features(cv.test, :);
    validationLabels = finalLabels(cv.test, :);
    
    % 【已修改】仅使用 75% 的数据进行训练
    fprintf('正在使用 %d 个训练样本 (75%%) 训练 SVM 分类器...\n', length(trainingLabels));
    svmClassifier = fitcecoc(trainingFeatures, trainingLabels);
    
    % 【已添加】在 25% 的验证集上评估性能
    fprintf('正在使用 %d 个验证样本 (25%%) 评估模型性能...\n', length(validationLabels));
    predictedLabels = predict(svmClassifier, validationFeatures);
    accuracy = sum(strcmp(predictedLabels, validationLabels)) / numel(validationLabels);
    fprintf('分类器在 25%% 验证集上的准确率: %.2f%%\n', accuracy * 100);

    % 【已添加】显示混淆矩阵
    figure('Name', '分类器验证性能 (Grayscale HOG+SVM)');
    confusionchart(validationLabels, predictedLabels);
    title(sprintf('SVM 验证集混淆矩阵 (准确率: %.2f%%)', accuracy * 100));
    
    fprintf('\n正在保存新训练的模型到文件 "%s" ...\n', classifierFile);
    save(classifierFile, 'svmClassifier', 'labelMap');
    fprintf('保存成功！\n');
end


%% --- 阶段三: 识别目标图像中的字符 ---
% (这部分代码无需任何改动)
fprintf('\n--- 开始识别目标图像中的字符 ---\n');
filename = 'charact1.txt';
imageSize=64; imageMatrix=zeros(imageSize,imageSize); fid=fopen(filename,'r');
for r=1:imageSize, l=fgetl(fid); if ~ischar(l),break,end; for c=1:imageSize, v=l(c); if(v>='0'&&v<='9'), imageMatrix(r,c)=v-'0'; elseif(v>='A'&&v<='V'), imageMatrix(r,c)=v-'A'+10; end,end,end
fclose(fid);
binaryImage = imbinarize(mat2gray(imageMatrix));
[labeledImage, numObjects] = bwlabel(binaryImage);
targetFeatures = [];
targetCharImages = {};
stats = regionprops(labeledImage, 'BoundingBox', 'Centroid');
centroids = cat(1, stats.Centroid);
[~, sortedOrder] = sort(centroids(:, 1));
stats = stats(sortedOrder);
RESIZE_SIZE = [48 48];
for i = 1:numObjects
    singleCharImage = (labeledImage == sortedOrder(i));
    singleCharImage = bwareafilt(singleCharImage, 1);
    standardCanvas = preprocess_char(singleCharImage);
    bbox = stats(i).BoundingBox;
    croppedChar = imcrop(singleCharImage, bbox);
    targetCharImages{end+1} = croppedChar;
    grayChar = double(croppedChar);
    blurredChar = imgaussfilt(grayChar, 0.5); 
    resizedImage = imresize(blurredChar, RESIZE_SIZE);
    hogFeatures = extractHOGFeatures(resizedImage);
    targetFeatures = [targetFeatures; hogFeatures];
end
finalResults = predict(svmClassifier, targetFeatures);
figure('Name', '最终识别结果');
sgtitle('对目标图像中各字符的识别结果', 'FontSize', 16, 'FontWeight', 'bold');
for i = 1:length(finalResults)
    subplot(1, length(finalResults), i);
    imshow(targetCharImages{i}, 'InitialMagnification', 400);
    title(sprintf('识别为: %s', finalResults{i}), 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'r');
end
fprintf('\n--- 最终识别结果 ---\n');
for i = 1:length(finalResults)
    fprintf('图像中从左到右第 %d 个字符被识别为: %s\n', i, finalResults{i});
end