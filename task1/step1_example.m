% --- 0. 清理环境 ---
clear;      % 清除工作区所有变量，解决可能的变量冲突
clc;        % 清空命令窗口
close all;  % 关闭所有图形窗口

% --- 1. 设置 ---
filename = 'chromo.txt'; % 确保此文件与脚本在同一个文件夹
imageSize = 64;
imageMatrix = zeros(imageSize, imageSize); % 预先分配矩阵内存

% --- 2. 打开并读取文件 ---
fid = fopen(filename, 'r');

% 检查文件是否成功打开
if fid == -1
    error('无法打开文件: %s。请确认文件名正确且文件在当前目录下。', filename);
end

% 逐行读取文件
for row = 1:imageSize
    line = fgetl(fid); % 读取一行
    
    % 检查是否提前到达文件末尾或某行为空/过短
    if ~ischar(line) || length(line) < imageSize
        warning('文件在第 %d 行提前结束或该行字符数不足。', row);
        break;
    end
    
    % --- 3. 转换字符并填充矩阵 ---
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

% --- 4. 转换数据类型并显示图像 ---
imageMatrix = uint8(imageMatrix); % 转换为uint8类型

figure;
imshow(imageMatrix, []); % 使用[]自动调整显示范围
title('重建后的图像 (已修正)');
colorbar;

disp('图像已成功生成。');