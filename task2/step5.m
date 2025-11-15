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

% --- 7. 分割、提取轮廓并裁剪显示 ---

% 步骤 7.1: 在二值图像（实心字符）上找到所有独立的字符
[labeledImage, numObjects] = bwlabel(binaryImage);

% 步骤 7.2: 获取每个字符的属性，我们主要需要'BoundingBox'
stats = regionprops(labeledImage, 'BoundingBox');

if numObjects == 0
    error('未在二值图像中找到任何字符。');
end
fprintf('成功分割出 %d 个字符，正在进行裁剪和显示...\n', numObjects);

% 步骤 7.3: 创建显示窗口
figure('Name', '裁剪并居中显示的独立字符轮廓');

% 步骤 7.4: 遍历每一个字符，提取轮廓、裁剪并显示
for k = 1:numObjects
    % 创建一个只包含当前字符轮廓的全尺寸图像
    singleCharImage = (labeledImage == k);
    invertedChar = ~singleCharImage;
    charContour = bwperim(invertedChar);
    
    % 获取当前字符的边界框 [x, y, width, height]
    bbox = stats(k).BoundingBox;
    
    % 【新增】对边界框增加一些内边距(padding)，防止裁剪过紧
    padding = 4; % 4个像素的内边距
    bboxPadded = [
        max(1, bbox(1) - padding), ...
        max(1, bbox(2) - padding), ...
        bbox(3) + 2*padding, ...
        bbox(4) + 2*padding
    ];

    % 【新增】使用带内边距的边界框来裁剪轮廓图
    croppedContour = imcrop(charContour, bboxPadded);
    
    % 在子图中显示裁剪后的轮廓
    subplot(2, ceil(numObjects/2), k); 
    imshow(croppedContour); % 显示裁剪后的图像
    title(sprintf('字符 %d', k));
end