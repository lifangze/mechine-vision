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

% --- 7. 分割、裁剪、旋转、提取轮廓并显示 ---

% 步骤 7.1: 在二值图像上找到所有独立的字符
[labeledImage, numObjects] = bwlabel(binaryImage);

% 步骤 7.2: 获取每个字符的'BoundingBox'属性
stats = regionprops(labeledImage, 'BoundingBox');

if numObjects == 0
    error('未在二值图像中找到任何字符。');
end
fprintf('成功分割出 %d 个字符。\n', numObjects);

% 定义您想要的显示顺序
displayOrder = [1, 3, 2, 4, 6, 5];

% 检查指定的顺序是否与找到的字符数匹配
if length(displayOrder) ~= numObjects
    error('指定的显示顺序中的项目数 (%d) 与找到的字符数 (%d) 不匹配。', length(displayOrder), numObjects);
end

% 步骤 7.3: 创建显示窗口
figure('Name', '旋转后提取的字符轮廓 (稳健方案)');

% 步骤 7.4: 按照 displayOrder 数组的顺序来循环和显示
for i = 1:length(displayOrder)
    k = displayOrder(i);
    singleCharImage = (labeledImage == k);
    bbox = stats(k).BoundingBox;
    padding = 4;
    bboxPadded = [
        max(1, bbox(1) - padding), ...
        max(1, bbox(2) - padding), ...
        bbox(3) + 2*padding, ...
        bbox(4) + 2*padding
    ];
    croppedCharacter = imcrop(singleCharImage, bboxPadded);
    
    % 【修改】步骤 1: 将二值图转为 double 数值格式，为平滑旋转做准备
    numericCroppedChar = double(croppedCharacter);
    
    % 【修改】步骤 2: 对数值格式的图像进行旋转，确保输出为灰度图
    rotatedGrayChar = imrotate(numericCroppedChar, -30, 'bilinear', 'loose');
    
    % 步骤 3: 将旋转后的灰度图像重新二值化
    binarizedRotatedChar = imbinarize(rotatedGrayChar);
    
    % 步骤 4: 提取二值化后图像的轮廓
    finalContour = bwperim(binarizedRotatedChar);
    
    % 创建 1 行 numObjects 列的子图布局
    subplot(1, numObjects, i);
    imshow(finalContour);
    title(sprintf('原始编号: %d', k));
end