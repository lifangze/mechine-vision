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

% --- 6. 阈值处理与二值化 ---
normalized_image = mat2gray(imageMatrix);
threshold_level = graythresh(normalized_image);
binaryImage = imbinarize(normalized_image, threshold_level);

% --- 7. 特征提取 ---
% 骨架提取 (单像素厚度)
skeletonImage = bwmorph(binaryImage, 'skel', Inf);

% 【您的方案：高效轮廓提取】
% 1. 反转二值图像，将字符变成背景中的"洞"
invertedImage = ~binaryImage;
% 2. 在反转后的图像上提取轮廓，此时只会得到外轮廓
contourImage = bwperim(invertedImage);

% --- 8. 显示结果 ---
figure('Position', [100, 100, 1000, 1000], 'Name', '图像处理与特征提取 (高效轮廓方案)');

% 在 2x2 的网格中绘制第一个子图
subplot(2, 2, 1);
imshow(imageMatrix, [], 'InitialMagnification', 400);
colormap(gca, gray);
title('原始灰度图像');
xlabel('像素列');
ylabel('像素行');

% 在 2x2 的网格中绘制第二个子图
subplot(2, 2, 2);
imshow(binaryImage, 'InitialMagnification', 400);
title('二值图像');
xlabel('像素列');
ylabel('像素行');

% 在 2x2 的网格中绘制第三个子图
subplot(2, 2, 3);
imshow(skeletonImage, 'InitialMagnification', 400);
title('骨架图像');
xlabel('像素列');
ylabel('像素行');

% 在 2x2 的网格中绘制第四个子图
subplot(2, 2, 4);
imshow(contourImage, 'InitialMagnification', 400);
title('清晰轮廓图像 (您的方案)');
xlabel('像素列');
ylabel('像素行');