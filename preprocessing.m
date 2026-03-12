function [processed1, processed2] = preprocess_images_paper(I1, I2)
    fprintf('\n=== 3.1 图像预处理 ===\n');
    
    % 确保两幅图像尺寸一致
    target_size = [size(I1,1), size(I1,2)];
    if ~isequal([size(I2,1), size(I2,2)], target_size)
        fprintf('调整热红外图像尺寸: %dx%d -> %dx%d\n', ...
            size(I2,2), size(I2,1), target_size(2), target_size(1));
        I2 = imresize(I2, target_size);
    end
    
    % 统一数据类型
    if ~isa(I1, 'uint8')
        I1 = im2uint8(I1);
    end
    if ~isa(I2, 'uint8')
        I2 = im2uint8(I2);
    end
    
    % 可见光图像预处理：高斯+中值滤波混合去噪
    fprintf('可见光图像：高斯+中值滤波混合去噪...\n');
    processed1 = imgaussfilt(I1, 0.5);  % 高斯滤波
    processed1 = medfilt2(rgb2gray(processed1), [3 3]);  % 中值滤波
    processed1 = repmat(processed1, [1 1 3]);  % 恢复RGB
    
    % 热红外图像预处理
    fprintf('热红外图像预处理：\n');
    
    % 如果是单通道，转换为伪彩色
    if size(I2, 3) == 1
        fprintf('  热红外图像伪彩色化处理...\n');
        I2_enhanced = imadjust(I2);
        processed2 = ind2rgb(I2_enhanced, hot(256));
    else
        processed2 = I2;
    end
    
    % 自适应直方图均衡化 (AHE)
    fprintf('  应用自适应直方图均衡化 (AHE)...\n');
    if size(processed2, 3) == 3
        % 对每个通道分别进行AHE
        for c = 1:3
            processed2(:,:,c) = adapthisteq(processed2(:,:,c), ...
                'NumTiles', [8 8], 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
        end
    else
        processed2 = adapthisteq(processed2, 'NumTiles', [8 8], ...
            'ClipLimit', 0.02, 'Distribution', 'rayleigh');
    end
    
    % 计算图像质量指标（论文表2）
    gray2 = rgb2gray(processed2);
    
    % 计算对比度（基于GLCM）
    glcm = graycomatrix(gray2, 'Offset', [0 1], 'Symmetric', true);
    glcm_norm = glcm / sum(glcm(:));
    [r, c] = meshgrid(1:size(glcm,1), 1:size(glcm,2));
    contrast = sum(sum(((r - c).^2) .* glcm_norm));
    
    % 计算信息熵
    entropy_val = entropy(gray2);
    
    % 计算均匀性
    uniformity = sum(glcm_norm(:).^2);
    
    fprintf('  预处理后图像质量指标：\n');
    fprintf('    对比度: %.2f\n', contrast);
    fprintf('    信息熵: %.2f\n', entropy_val);
    fprintf('    均匀性: %.4f\n', uniformity);
    
    fprintf('图像预处理完成\n');
end
