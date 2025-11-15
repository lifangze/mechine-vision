% --- 0. 环境清理 ---
clear;      % 清除工作区所有变量
clc;        % 清空命令窗口
close all;  % 关闭所有已打开的图形窗口

% --- 1. 参数设置 ---
filename = 'charact1.txt'; % 定义包含图像数据的文件名
imageSize = 64;          % 图像的尺寸是 64x64

% --- 2. 初始化矩阵 ---
% 预先分配一个 64x64 的矩阵来存储图像的灰度值，用0填充
imageMatrix = zeros(imageSize, imageSize);

% --- 3. 打开并读取文件 ---
% 以只读模式('r')打开文件
fid = fopen(filename, 'r');

% 检查文件是否成功打开，如果失败则报错并终止程序
if fid == -1
    error('无法打开文件: %s。请确认文件名正确且文件在当前目录下。', filename);
end

% --- 4. 逐行解析文件并转换数据 ---
% 循环读取文件的每一行 (总共64行)
for row = 1:imageSize
    % 读取当前行
    line = fgetl(fid);

    % 检查行是否存在或长度是否足够
    if ~ischar(line) || length(line) < imageSize
        warning('文件在第 %d 行提前结束或该行字符数不足。', row);
        break; % 如果行数据不完整，则跳出循环
    end

    % 循环处理当前行的每一个字符 (总共64列)
    for col = 1:imageSize
        char_val = line(col); % 获取当前位置的字符

        % 根据规则将字符转换为 0-31 的灰度值
        if (char_val >= '0' && char_val <= '9')
            % 如果字符是 '0' 到 '9'，其灰度值为字符的数值
            imageMatrix(row, col) = char_val - '0';
        elseif (char_val >= 'A' && char_val <= 'V')
            % 如果字符是 'A' 到 'V'，其灰度值为 10 + (字符与'A'的偏移量)
            imageMatrix(row, col) = char_val - 'A' + 10;
        end
    end
end

% --- 5. 关闭文件 ---
fclose(fid);

% --- 6. 显示图像 ---
figure; % 创建一个新的图形窗口
% 使用 imshow 函数显示图像矩阵
% 第二个参数 '[]' 会自动将矩阵中的最小/最大值映射到黑/白
imshow(imageMatrix, [],'InitialMagnification', 'fit');
colormap gray; % 设置色彩模式为灰度
title('从 chromo.txt 读取的原始图像'); % 添加标题
xlabel('像素列'); % 添加 X 轴标签
ylabel('像素行'); % 添加 Y 轴标签
colorbar;      % 显示一个颜色条，标示灰度值