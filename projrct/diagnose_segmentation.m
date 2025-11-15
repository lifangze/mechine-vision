% --- diagnose_grayscale.m ---
% 诊断 charact1.txt 的原始灰度图和二值化过程

clear;
clc;
close all;

%% --- 步骤 1: 加载并创建灰度图 ---
fprintf('正在加载 charact1.txt 并创建原始灰度图...\n');

filename = 'charact1.txt';
imageSize = 64;
imageMatrix = zeros(imageSize, imageSize);
fid = fopen(filename, 'r');
if fid == -1, error('无法打开文件: %s', filename); end
for row = 1:imageSize
    line = fgetl(fid);
    if ~ischar(line) || length(line) < imageSize, break; end
    for col = 1:imageSize
        char_val = line(col);
        if (char_val >= '0' && char_val <= '9')
            imageMatrix(row, col) = char_val - '0';
        elseif (char_val >= 'A' && char_val <= 'V')
            imageMatrix(row, col) = char_val - 'A' + 10;
        end
    end
end
fclose(fid);
normalized_image = mat2gray(imageMatrix);

%% --- 步骤 2: 计算阈值并进行二值化 ---
threshold = graythresh(normalized_image);
binaryImage = imbinarize(normalized_image, threshold);

%% --- 步骤 3: 可视化诊断结果 ---
fprintf('正在生成诊断图像...\n');
figure('Name', '灰度与二值化过程诊断', 'Position', [100, 100, 1000, 800]);
sgtitle('charact1.txt 处理过程诊断', 'FontSize', 16, 'FontWeight', 'bold');

% 左上: 显示原始灰度图
subplot(2, 2, 1);
imshow(normalized_image);
title({'1. 原始灰度图'; '观察字符''1''的亮度是否与其他字符不同'}, 'FontSize', 12);

% 右上: 显示灰度直方图和阈值线
subplot(2, 2, 2);
imhist(normalized_image);
hold on;
xline(threshold, 'r', 'LineWidth', 2);
hold off;
legend(sprintf('自动阈值 = %.4f', threshold));
title({'2. 灰度直方图与自动阈值'; '红线左边变黑，右边变白'}, 'FontSize', 12);

% 左下: 显示最终的二值图
subplot(2, 2, 3);
imshow(binaryImage);
title({'3. 最终二值图像'; '检查''1''是否在这里已经损坏'}, 'FontSize', 12);

% 右下: 显示连通分量
subplot(2, 2, 4);
[labeledImage, numObjects] = bwlabel(binaryImage);
imshow(label2rgb(labeledImage, @jet, 'k', 'shuffle'));
title({'4. 连通分量分析'; ['找到了 ', num2str(numObjects), ' 个对象']}, 'FontSize', 12);

fprintf('诊断图像已生成。请仔细检查图像。\n');