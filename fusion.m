function [J_F, fusionInfo] = fuse_images_paper(J1, J2)
    fprintf('\n=== 图像融合 ===\n');
    
    % 转换为双精度
    J1_double = im2double(J1);
    J2_double = im2double(J2);
    
    % 创建叠加显示（论文图14(c)）
    J_F = imfuse(J1_double, J2_double, 'blend', 'Scaling', 'joint');
    
    % 计算融合质量指标
    fusionInfo.contrast = std2(rgb2gray(J_F));
    fusionInfo.entropy = entropy(rgb2gray(J_F));
    fusionInfo.fusionQuality = fusionInfo.contrast * 0.5 + fusionInfo.entropy * 0.5;
    
    fprintf('融合完成\n');
    fprintf('  对比度: %.2f\n', fusionInfo.contrast);
    fprintf('  信息熵: %.2f\n', fusionInfo.entropy);
    fprintf('  融合质量: %.2f\n', fusionInfo.fusionQuality);
end
