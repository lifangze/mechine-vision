% --- 0. 环境清理 ---
clear;      % 清除工作区所有变量
clc;        % 清空命令窗口
close all;  % 关闭所有已打开的图形窗口

% --- 1. 参数设置 ---
filename = 'charact1.txt'; % 定义包含图像数据的文件名
imageSize = 64;          % 图像的尺寸是 64x64

% --- 2. 初始化矩阵 ---
imageMatrix = zeros(imageSize, imageSize);

% --- 3. 打开并读取文件 ---
fid = fopen(filename, 'r');
if fid == -1
    error('无法打开文件: %s。请确认文件名正确且文件在当前目录下。', filename);
end

% --- 4. 逐行解析文件并转换数据 ---
for row = 1:imageSize
    line = fgetl(fid);
    if ~ischar(line) || length(line) < imageSize
        warning('文件在第 %d 行提前结束或该行字符数不足。', row);
        break;
    end
    for col = 1:imageSize
        char_val = line(col);
        if (char_val >= '0' && char_val <= '9')
            imageMatrix(row, col) = char_val - '0';
        elseif (char_val >= 'A' && char_val <= 'V')
            imageMatrix(row, col) = char_val - 'A' + 10;
        end
    end
end

% --- 5. 关闭文件 ---
fclose(fid);

% --- 6. 【新增功能】阈值处理与二值化 ---
% 首先，将图像矩阵的灰度值归一化到[0, 1]范围，这是 graythresh 函数的要求
normalized_image = mat2gray(imageMatrix);

% 使用大津法(Otsu's method)自动计算最佳阈值
threshold_level = graythresh(normalized_image);

% 使用计算出的阈值将归一化后的图像转换为二值图像
binaryImage = imbinarize(normalized_image, threshold_level);


% --- 7. 显示结果 ---
figure('Position', [100, 100, 1000, 500]); % 创建一个更宽的窗口

% 在 1x2 的网格中绘制第一个子图
subplot(1, 2, 1);
imshow(imageMatrix, [], 'InitialMagnification', 500);
colormap(gca, gray); % 为当前子图设置灰度色彩
title('原始灰度图像');
xlabel('像素列');
ylabel('像素行');

% 在 1x2 的网格中绘制第二个子图
subplot(1, 2, 2);
imshow(binaryImage, 'InitialMagnification', 500);
title(['二值图像 (Otsu阈值 = ' num2str(threshold_level) ')']);
xlabel('像素列');
ylabel('像素行');