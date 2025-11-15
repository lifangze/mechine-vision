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
% (此部分代码不变)
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
% (此部分代码不变)
normalized_image = mat2gray(imageMatrix);
threshold_level = graythresh(normalized_image);
binaryImage = imbinarize(normalized_image, threshold_level);

% --- 5. 【关键修复】反转二值图像 ---
% 这是解决问题的核心步骤。
% 它将前景和背景对调，确保我们感兴趣的对象是白色(1)，背景是黑色(0)。
binaryImage = ~binaryImage; % 或者使用 imcomplement(binaryImage);

% --- 6. 骨架提取 (单像素厚度) ---
% (注意：现在是对反转后的图像操作)
skeletonImage = bwmorph(binaryImage, 'skel', 'Inf');

% --- 7. 轮廓提取 ---
% (注意：现在是对反转后的图像操作)
contourImage = bwperim(binaryImage);

% --- 8. 显示第一组结果 (图像变换) ---
figure('Name', '图像处理变换', 'Position', [100, 100, 800, 800]);
subplot(2, 2, 1); imshow(imageMatrix, []); title('原始灰度图像');
subplot(2, 2, 2); imshow(binaryImage); title('修正后的二值图像');
subplot(2, 2, 3); imshow(skeletonImage); title('骨架图像 (单像素厚度)');
subplot(2, 2, 4); imshow(contourImage); title('轮廓图像');

% --- 9. 连接组件分析与标签 ---
% (现在 bwlabel 将在正确的二值图像上工作)
[labeledMatrix, nObjects] = bwlabel(binaryImage);
stats = regionprops(labeledMatrix, 'Centroid');

% --- 10. 显示第二组结果 (对象标签) ---
figure('Name', '对象标签结果');
rgb_labels = label2rgb(labeledMatrix, 'jet', 'k', 'shuffle'); % 将背景改为黑色'k'更清晰
imshow(rgb_labels);
hold on;

title(['对象标记结果 (共发现 ' num2str(nObjects) ' 个对象)']);

for k = 1:nObjects
    centroid = stats(k).Centroid;
    text(centroid(1), centroid(2), num2str(k), ...
        'Color', 'w', ... % 标签文字改为白色'w'
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle');
end
hold off;

disp(['图像处理完成，已标记 ' num2str(nObjects) ' 个独立对象。']);