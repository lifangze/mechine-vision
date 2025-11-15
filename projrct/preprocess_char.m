% --- preprocess_char.m ---
function standardImage = preprocess_char(inputImage)
% 该函数接收一个任意大小的二值字符图像，
% 将其紧密裁剪后，粘贴到一个标准尺寸的方形画布中央。

    % 1. 紧密裁剪图像 (移除多余的黑边)
    stats = regionprops(inputImage, 'BoundingBox');
    if isempty(stats)
        % 如果是空图像，直接返回一个空的标准画布
        standardImage = false(40, 40); % 标准画布尺寸
        return;
    end
    croppedImage = imcrop(inputImage, stats(1).BoundingBox);

    % 2. 创建一个标准尺寸的方形黑色画布 (例如 40x40)
    canvasSize = 40;
    standardImage = false(canvasSize, canvasSize);

    % 3. 将裁剪后的图像粘贴到画布中央
    [h, w] = size(croppedImage);
    % 计算左上角的粘贴位置
    topLeftRow = round((canvasSize - h) / 2);
    topLeftCol = round((canvasSize - w) / 2);

    % 确保位置不小于1
    topLeftRow = max(topLeftRow, 1);
    topLeftCol = max(topLeftCol, 1);
    
    % 粘贴
    standardImage(topLeftRow : topLeftRow+h-1, topLeftCol : topLeftCol+w-1) = croppedImage;
end