% --- classify_single_char.m ---
% 用于加载已保存的模型，并识别单个 .mat 文件中的字符

clear;
clc;
close all;

% --- 1. 加载训练好的分类器 ---
fprintf('正在加载已训练的模型...\n');
if ~exist('charClassifier.mat', 'file')
    error('错误: 未找到模型文件 "charClassifier.mat"。\n请先运行 train_and_classify_grid.m 来训练并保存模型。');
end
load('charClassifier.mat'); % 这会加载 knnClassifier 和 labelMap

fprintf('模型加载成功！\n');


% --- 2. 指定您想测试的单个字符文件 ---
% !!! 请修改下面这行，指向您想测试的任意一个 .mat 文件 !!!
testFile = 'p_dataset_26/SampleA/img011-00001.mat'; % 示例：测试 A 类别中的第10个文件


% --- 3. 加载并提取该文件的特征 ---
fprintf('正在处理文件: %s\n', testFile);
if ~exist(testFile, 'file')
    error('错误: 测试文件 "%s" 不存在。', testFile);
end

data = load(testFile);
charImage = data.imageArray;

if ~islogical(charImage), charImage = imbinarize(charImage); end
charImage = bwareafilt(charImage, 1);

% 应用与训练时完全相同的网格特征提取逻辑
RESIZE_SIZE = [20 20];
GRID_SIZE = [5 5];
resizedImage = imresize(charImage, RESIZE_SIZE);
cellHeight = RESIZE_SIZE(1) / GRID_SIZE(1);
cellWidth = RESIZE_SIZE(2) / GRID_SIZE(2);
targetFeatures = [];
for row = 1:GRID_SIZE(1)
    for col = 1:GRID_SIZE(2)
        r_start=(row-1)*cellHeight+1; r_end=row*cellHeight;
        c_start=(col-1)*cellWidth+1; c_end=col*cellWidth;
        gridCell = resizedImage(r_start:r_end, c_start:c_end);
        pixelCount = sum(gridCell(:));
        targetFeatures = [targetFeatures, pixelCount];
    end
end

% --- 4. 进行预测并报告结果 ---
predictedLabel = predict(knnClassifier, targetFeatures);

% 获取真实标签用于对比
[~, trueLabelName] = fileparts(fileparts(testFile)); % 从路径中获取文件夹名，如'SampleA'
trueLabel = labelMap(trueLabelName);

fprintf('\n--- 识别结果 ---\n');
fprintf('真实类别: %s\n', trueLabel);
fprintf('模型预测: %s\n', predictedLabel{1});

% 可视化结果
figure('Name', '单个字符识别结果');
imshow(charImage, 'InitialMagnification', 800);
title(sprintf('真实: %s, 预测: %s', trueLabel, predictedLabel{1}), 'FontSize', 16);

if strcmp(trueLabel, predictedLabel{1})
    fprintf('结论: 识别正确！\n');
else
    fprintf('结论: 识别错误。\n');
end