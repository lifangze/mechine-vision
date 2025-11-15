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

% --- 4. 【新增功能】阈值处理与二值化 ---

% 使用大津法(Otsu's method)自动计算最佳阈值
% graythresh需要输入为[0,1]范围的图像，所以先用mat2gray进行归一化
normalized_image = mat2gray(imageMatrix);
threshold_level = graythresh(normalized_image);

% 使用计算出的阈值将图像转换为二值图像
% 像素值 < 阈值*最大值 的变为1 (白色)，其余变为0 (黑色)
binaryImage = imbinarize(normalized_image, threshold_level);


% --- 5. 显示结果 ---
figure; % 创建一个新的图形窗口

% 使用 imshowpair 将原始图和二值图并排显示，方便对比
imshowpair(imageMatrix, binaryImage, 'montage');

% 添加标题
title('原始灰度图像 (左)   vs.  二值图像 (右)');

disp('图像阈值处理完成，已生成二值图像。');