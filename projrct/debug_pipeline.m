% --- debug_pipeline.m ---
% 这是一个诊断脚本，用于可视化对比训练数据和测试数据的完整预处理流程

clear;
clc;
close all;

%% --- 1. 准备数据 ---

% --- A. 加载一个训练样本 (以'A'为例) ---
fprintf('加载训练样本 A ...\n');
data = load('p_dataset_26/SampleA/img011-00001.mat'); % 加载第一个'A'样本
train_char_orig = data.imageArray;

% --- B. 加载并分割出目标图像中的'A' ---
fprintf('加载并分割目标字符 A ...\n');
filename = 'charact1.txt';
imageSize = 64;
imageMatrix = zeros(imageSize, imageSize);
fid = fopen(filename, 'r');
for row = 1:imageSize, line = fgetl(fid); if ~ischar(line), break, end; for col = 1:imageSize, char_val=line(col); if (char_val>='0'&&char_val<='9'), imageMatrix(row,col)=char_val-'0'; elseif (char_val>='A'&&char_val<='V'), imageMatrix(row,col)=char_val-'A'+10; end, end, end
fclose(fid);
binaryImage = imbinarize(mat2gray(imageMatrix));
[labeledImage, ~] = bwlabel(binaryImage);
stats = regionprops(labeledImage, 'Centroid');
centroids = cat(1, stats.Centroid);
[~, sortedOrder] = sort(centroids(:, 1));
% 我们知道第一个字符是 'A'
target_char_orig = (labeledImage == sortedOrder(1));


%% --- 2. 逐步执行并可视化处理流程 ---

figure('Name', '预处理流程诊断', 'Position', [100, 100, 1000, 800]);
sgtitle('训练样本 vs 目标样本 - 预处理流程对比', 'FontSize', 16, 'FontWeight', 'bold');

% --- 步骤 1: 原始图像 ---
subplot(4, 2, 1); imshow(train_char_orig); title('1. 训练样本 (原始)');
subplot(4, 2, 2); imshow(target_char_orig); title('1. 目标样本 (原始)');

% --- 步骤 2: 清理 (bwareafilt) ---
train_step2 = bwareafilt(imbinarize(train_char_orig), 1);
target_step2 = bwareafilt(target_char_orig, 1);
subplot(4, 2, 3); imshow(train_step2); title('2. 清理后 (bwareafilt)');
subplot(4, 2, 4); imshow(target_step2); title('2. 清理后 (bwareafilt)');

% --- 步骤 3: 标准化画布 (preprocess_char) ---
train_step3 = preprocess_char(train_step2);
target_step3 = preprocess_char(target_step2);
subplot(4, 2, 5); imshow(train_step3); title('3. 标准化画布后 (40x40)');
subplot(4, 2, 6); imshow(target_step3); title('3. 标准化画布后 (40x40)');

% --- 步骤 4: 缩放 (imresize) ---
RESIZE_SIZE = [20 20];
train_step4 = imresize(train_step3, RESIZE_SIZE);
target_step4 = imresize(target_step3, RESIZE_SIZE);
subplot(4, 2, 7); imshow(train_step4); title('4. 缩放后 (20x20) - 特征提取前');
subplot(4, 2, 8); imshow(target_step4); title('4. 缩放后 (20x20) - 特征提取前');

%% --- 3. 提取并对比最终的特征向量 ---

GRID_SIZE = [5 5];
cellHeight = RESIZE_SIZE(1)/GRID_SIZE(1);
cellWidth = RESIZE_SIZE(2)/GRID_SIZE(2);

% 提取训练样本的特征
trainFeatures = [];
for row = 1:GRID_SIZE(1)
    for col = 1:GRID_SIZE(2)
        gridCell = train_step4((row-1)*cellHeight+1:row*cellHeight, (col-1)*cellWidth+1:col*cellWidth);
        trainFeatures = [trainFeatures, sum(gridCell(:))];
    end
end

% 提取目标样本的特征
targetFeatures = [];
for row = 1:GRID_SIZE(1)
    for col = 1:GRID_SIZE(2)
        gridCell = target_step4((row-1)*cellHeight+1:row*cellHeight, (col-1)*cellWidth+1:col*cellWidth);
        targetFeatures = [targetFeatures, sum(gridCell(:))];
    end
end

fprintf('\n--- 特征向量对比 ---\n');
fprintf('训练样本''A''的特征向量:\n');
disp(trainFeatures);
fprintf('目标样本''A''的特征向量:\n');
disp(targetFeatures);

% 比较两个向量的差异
difference = norm(trainFeatures - targetFeatures);
fprintf('\n两个特征向量的欧几里得距离: %.2f\n', difference);
if difference > 50 % (一个经验阈值)
    fprintf('结论: 两个特征向量差异巨大！这解释了为何分类错误。\n');
else
    fprintf('结论: 两个特征向量相似。问题可能更深奥。\n');
end