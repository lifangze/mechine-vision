% --- 0. 清理环境 ---
clear;      % 清除工作区所有变量
clc;        % 清空命令窗口
close all;  % 关闭所有图形窗口

% --- 1. 设置 ---
filename = 'chromo.txt'; % 确保此文件与脚本在同一个文件夹
imageSize = 64;
imageMatrix = zeros(imageSize, imageSize); % 预先分配矩阵内存

% --- 2. 打开并读取文件 ---
fid = fopen(filename, 'r');
if fid == -1
    error('无法打开文件: %s。请确认文件名正确且文件在当前目录下。', filename);
end

% --- 3. 读取文件并填充矩阵 ---
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
fclose(fid); % 关闭文件
imageMatrix = uint8(imageMatrix); % 转换为uint8类型

% --- 4. 阈值处理与二值化 ---
% 使用大津法(Otsu's method)自动计算最佳阈值
normalized_image = mat2gray(imageMatrix);
threshold_level = graythresh(normalized_image);

% 使用计算出的阈值将图像转换为二值图像
binaryImage = imbinarize(normalized_image, threshold_level);
%【关键修复】反转二值图像 ---
% 这是解决问题的核心步骤。
% 它将前景和背景对调，确保我们感兴趣的对象是白色(1)，背景是黑色(0)。
binaryImage = ~binaryImage; % 或者使用 imcomplement(binaryImage);

% --- 5. 骨架提取 (单像素厚度) ---
% 对二值图像进行形态学骨架化处理
skeletonImage = bwmorph(binaryImage, 'skel', Inf);

% --- 6. 【新增功能】轮廓提取 ---
% 使用 bwperim 函数直接找到二值图像中物体的轮廓线（周长）
contourImage = bwperim(binaryImage);

% --- 7. 显示结果 ---
figure('Name', '图像处理流程', 'Position', [100, 100, 800, 800]); % 创建一个方形窗口以容纳2x2布局

% 子图1: 原始图像
subplot(2, 2, 1);
imshow(imageMatrix, []); % 使用'[]'自动调整灰度显示范围
title('原始灰度图像');

% 子图2: 二值图像
subplot(2, 2, 2);
imshow(binaryImage);
title('二值图像');

% 子图3: 骨架图像
subplot(2, 2, 3);
imshow(skeletonImage);
title('骨架图像 (单像素厚度)');

% 子图4: 轮廓图像
subplot(2, 2, 4);
imshow(contourImage);
title('轮廓图像');

disp('图像处理完成，已生成轮廓图像。');