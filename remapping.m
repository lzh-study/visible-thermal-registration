function J2_aligned = image_remapping(J2, H, outputSize)
    fprintf('\n=== 3.3.3 图像重映射 ===\n');
    
    % 创建几何变换对象
    tform = affine2d(H');
    
    % 创建输出视图
    Rout = imref2d([outputSize(1), outputSize(2)]);
    
    % 应用变换（使用双线性插值）
    fprintf('应用逆映射和双线性插值...\n');
    J2_aligned = imwarp(J2, tform, 'OutputView', Rout, ...
        'InterpolationMethod', 'linear', 'FillValues', 0);
    
    fprintf('重映射完成，输出尺寸: %dx%d\n', size(J2_aligned,2), size(J2_aligned,1));
end

%% 裁剪重叠区域（论文图14）
function [J1_cropped, J2_cropped, cropInfo] = crop_overlap_region_paper(J1, J2_aligned)
    fprintf('\n=== 裁剪共同重叠区域 ===\n');
    
    % 获取图像尺寸
    [h1, w1, ~] = size(J1);
    [h2, w2, ~] = size(J2_aligned);
    
    fprintf('原始尺寸: RGB图像 %dx%d, 配准后热红外图像 %dx%d\n', w1, h1, w2, h2);
    
    % 创建有效区域掩码
    if size(J1, 3) == 3
        gray1 = rgb2gray(J1);
    else
        gray1 = J1;
    end
    
    if size(J2_aligned, 3) == 3
        gray2 = rgb2gray(J2_aligned);
    else
        gray2 = J2_aligned;
    end
    
    % 找到非黑色区域
    mask1 = true(h1, w1);
    mask2 = gray2 > 10;  % 排除黑色填充区域
    
    % 调整mask2尺寸
    if size(mask2,1) ~= size(mask1,1) || size(mask2,2) ~= size(mask1,2)
        mask2 = imresize(double(mask2), [h1, w1]) > 0.5;
    end
    
    % 计算重叠区域
    overlap_mask = mask1 & mask2;
    
    % 找到重叠区域边界
    [rows, cols] = find(overlap_mask);
    if isempty(rows)
        error('未找到重叠区域');
    end
    
    y_min = max(1, min(rows));
    y_max = min(h1, max(rows));
    x_min = max(1, min(cols));
    x_max = min(w1, max(cols));
    
    % 添加安全边距
    margin = 5;
    y_min = max(1, y_min - margin);
    y_max = min(h1, y_max + margin);
    x_min = max(1, x_min - margin);
    x_max = min(w1, x_max + margin);
    
    width = x_max - x_min + 1;
    height = y_max - y_min + 1;
    
    fprintf('重叠区域边界框: [%d,%d,%d,%d] (大小: %dx%d)\n', ...
        x_min, y_min, width, height, width, height);
    
    % 裁剪图像
    J1_cropped = J1(y_min:y_max, x_min:x_max, :);
    J2_cropped = J2_aligned(y_min:y_max, x_min:x_max, :);
    
    % 确保尺寸一致
    if ~isequal(size(J1_cropped), size(J2_cropped))
        target_h = min(size(J1_cropped,1), size(J2_cropped,1));
        target_w = min(size(J1_cropped,2), size(J2_cropped,2));
        J1_cropped = imresize(J1_cropped, [target_h, target_w]);
        J2_cropped = imresize(J2_cropped, [target_h, target_w]);
    end
    
    % 存储裁剪信息
    cropInfo.originalRGB = [h1, w1];
    cropInfo.originalThermal = [h2, w2];
    cropInfo.croppedSize = size(J1_cropped);
    cropInfo.cropRect = [x_min, y_min, width, height];
    cropInfo.overlapRatio = (height * width) / (h1 * w1);
    
    fprintf('裁剪完成: 重叠区域尺寸 %dx%d, 重叠比例 %.1f%%\n', ...
        width, height, cropInfo.overlapRatio*100);
end
