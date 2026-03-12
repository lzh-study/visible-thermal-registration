function display_images(parent, J1, J2, titleText)
    panel = uipanel('Parent', parent, 'Title', titleText, ...
                   'Position', [0.02 0.6 0.3 0.25], ...
                   'FontSize', 12, 'BackgroundColor', [0.96 0.96 0.96], ...
                   'BorderWidth', 1, 'HighlightColor', [0.7 0.7 0.7]);
    
    % RGB图像
    ax1 = subplot(1,2,1, 'Parent', panel);
    imshow(J1, 'Parent', ax1);
    title(ax1, sprintf('RGB图像 (预处理后)\n%d×%d', size(J1,2), size(J1,1)), ...
          'FontSize', 11, 'FontWeight', 'bold');
    set(ax1, 'Units', 'normalized', 'Position', [0.02 0.1 0.46 0.8]);
    
    % 热红外图像
    ax2 = subplot(1,2,2, 'Parent', panel);
    imshow(J2, 'Parent', ax2);
    title(ax2, sprintf('热红外图像 (AHE增强)\n%d×%d', size(J2,2), size(J2,1)), ...
          'FontSize', 11, 'FontWeight', 'bold');
    set(ax2, 'Units', 'normalized', 'Position', [0.52 0.1 0.46 0.8]);
    
    % 添加边框
    annotation(panel, 'rectangle', [0 0 1 1], 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    
    drawnow;
end

%% 显示校正结果
function display_rectification_results(parent, J1, J2, J1_rect, J2_rect, rectInfo)
    panel = uipanel('Parent', parent, 'Title', '立体校正结果', ...
                   'Position', [0.35 0.6 0.3 0.25], ...
                   'FontSize', 12, 'BackgroundColor', [0.96 0.96 0.96], ...
                   'BorderWidth', 1, 'HighlightColor', [0.7 0.7 0.7]);
    
    ax = axes('Parent', panel, 'Position', [0.05 0.1 0.9 0.8]);
    
    % 创建校正后的叠加显示
    if size(J1_rect,3) == 3
        overlay = imfuse(rgb2gray(J1_rect), rgb2gray(J2_rect), 'falsecolor', ...
            'Scaling', 'joint', 'ColorChannels', [1 2 0]);
    else
        overlay = imfuse(J1_rect, J2_rect, 'falsecolor', ...
            'Scaling', 'joint', 'ColorChannels', [1 2 0]);
    end
    imshow(overlay, 'Parent', ax);
    
    title(ax, sprintf('校正后图像叠加 (%s)\n图像已实现行对齐', rectInfo.method), ...
          'FontSize', 11, 'FontWeight', 'bold');
    
    % 添加边框
    annotation(panel, 'rectangle', [0 0 1 1], 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    
    drawnow;
end

%% 显示匹配结果（论文图13）
function display_match_results_paper(parent, J1, J2, matchedPoints1, matchedPoints2, matchInfo, transformInfo)
    panel = uipanel('Parent', parent, 'Title', '特征匹配结果', ...
                   'Position', [0.68 0.6 0.3 0.25], ...
                   'FontSize', 12, 'BackgroundColor', [0.96 0.96 0.96], ...
                   'BorderWidth', 1, 'HighlightColor', [0.7 0.7 0.7]);
    
    ax = axes('Parent', panel, 'Position', [0.05 0.1 0.9 0.8]);
    
    % 显示匹配点（论文图13风格）
    showMatchedFeatures(J1, J2, matchedPoints1, matchedPoints2, 'montage', 'Parent', ax);
    
    title(ax, sprintf('KAZE特征匹配结果\n内点: %d (%.1f%%), RMSE: %.2f像素', ...
          transformInfo.numInliers, transformInfo.inlierRatio*100, transformInfo.rmse), ...
          'FontSize', 11, 'FontWeight', 'bold');
    
    % 添加边框
    annotation(panel, 'rectangle', [0 0 1 1], 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    
    drawnow;
end

%% 显示裁剪结果
function display_cropped_images(parent, J1_cropped, J2_cropped, cropInfo)
    panel = uipanel('Parent', parent, 'Title', '重叠区域裁剪结果', ...
                   'Position', [0.68 0.32 0.3 0.25], ...
                   'FontSize', 12, 'BackgroundColor', [0.96 0.96 0.96], ...
                   'BorderWidth', 1, 'HighlightColor', [0.7 0.7 0.7]);
    
    % 显示裁剪后的RGB图像
    ax1 = subplot(1,2,1, 'Parent', panel);
    imshow(J1_cropped, 'Parent', ax1);
    title_str1 = sprintf('RGB重叠区域\n%d×%d\n重叠比例: %.1f%%', ...
        size(J1_cropped,2), size(J1_cropped,1), cropInfo.overlapRatio*100);
    title(ax1, title_str1, 'FontSize', 10, 'FontWeight', 'bold');
    set(ax1, 'Position', [0.05 0.1 0.44 0.8]);
    
    % 显示裁剪后的热红外图像
    ax2 = subplot(1,2,2, 'Parent', panel);
    imshow(J2_cropped, 'Parent', ax2);
    title_str2 = sprintf('热红外重叠区域\n%d×%d', ...
        size(J2_cropped,2), size(J2_cropped,1));
    title(ax2, title_str2, 'FontSize', 10, 'FontWeight', 'bold');
    set(ax2, 'Position', [0.51 0.1 0.44 0.8]);
    
    % 添加边框
    annotation(panel, 'rectangle', [0 0 1 1], 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    
    drawnow;
end

%% 显示最终结果（论文图14）
function display_final_results_paper(parent, J1_cropped, J2_cropped, J_F, ...
    matchInfo, transformInfo, cropInfo, fusionInfo)
    
    panel = uipanel('Parent', parent, 'Title', '最终结果 - 论文图14', ...
                   'Position', [0.02 0.02 0.96 0.55], ...
                   'FontSize', 12, 'BackgroundColor', [0.96 0.96 0.96], ...
                   'BorderWidth', 1, 'HighlightColor', [0.7 0.7 0.7]);
    
    % (a) RGB图像
    ax1 = subplot(2,3,1, 'Parent', panel);
    imshow(J1_cropped, 'Parent', ax1);
    title_str1 = sprintf('(a) RGB图像\n%d×%d', size(J1_cropped,2), size(J1_cropped,1));
    title(ax1, title_str1, 'FontSize', 10, 'FontWeight', 'bold');
    set(ax1, 'Position', [0.02 0.55 0.3 0.4]);
    
    % (b) 重映射后的热红外图像
    ax2 = subplot(2,3,2, 'Parent', panel);
    imshow(J2_cropped, 'Parent', ax2);
    title_str2 = sprintf('(b) 重映射热红外图像\n内点: %d (%.1f%%)', ...
        transformInfo.numInliers, transformInfo.inlierRatio*100);
    title(ax2, title_str2, 'FontSize', 10, 'FontWeight', 'bold');
    set(ax2, 'Position', [0.34 0.55 0.3 0.4]);
    
    % (c) 图像叠加显示
    ax3 = subplot(2,3,3, 'Parent', panel);
    overlay = imfuse(J1_cropped, J2_cropped, 'blend', 'Scaling', 'joint');
    imshow(overlay, 'Parent', ax3);
    title_str3 = sprintf('(c) 图像叠加显示\nRMSE: %.2f像素', transformInfo.rmse);
    title(ax3, title_str3, 'FontSize', 10, 'FontWeight', 'bold');
    set(ax3, 'Position', [0.66 0.55 0.3 0.4]);
    
    % 融合图像
    ax4 = subplot(2,3,4, 'Parent', panel);
    imshow(J_F, 'Parent', ax4);
    title_str4 = sprintf('融合图像\n质量: %.2f', fusionInfo.fusionQuality);
    title(ax4, title_str4, 'FontSize', 10, 'FontWeight', 'bold');
    set(ax4, 'Position', [0.02 0.05 0.3 0.4]);
    
    % 配准误差图
    ax5 = subplot(2,3,5, 'Parent', panel);
    diff_img = imabsdiff(rgb2gray(J1_cropped), rgb2gray(J2_cropped));
    imshow(diff_img, 'Parent', ax5);
    title(ax5, '配准误差图', 'FontSize', 10, 'FontWeight', 'bold');
    colorbar(ax5, 'Location', 'eastoutside');
    set(ax5, 'Position', [0.34 0.05 0.3 0.4]);
    
    % 热力图
    ax6 = subplot(2,3,6, 'Parent', panel);
    J_F_gray = rgb2gray(J_F);
    J_F_heat = mat2gray(J_F_gray);
    imshow(J_F_heat, 'Parent', ax6);
    colormap(ax6, hot);
    colorbar(ax6, 'Location', 'eastoutside');
    title(ax6, '融合图像热力图', 'FontSize', 10, 'FontWeight', 'bold');
    set(ax6, 'Position', [0.66 0.05 0.3 0.4]);
    
    % 添加处理信息
    info_str = sprintf('处理信息:\n匹配方法: %s\n重叠比例: %.1f%%\n融合质量: %.2f', ...
        matchInfo.method, cropInfo.overlapRatio*100, fusionInfo.fusionQuality);
    
    annotation(panel, 'textbox', [0.02 0.95 0.96 0.04], ...
              'String', info_str, ...
              'FontSize', 10, 'FontWeight', 'bold', ...
              'EdgeColor', 'none', ...
              'HorizontalAlignment', 'center', ...
              'BackgroundColor', [0.9 0.95 1]);
    
    % 添加边框
    annotation(panel, 'rectangle', [0 0 1 1], 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    
    fprintf('\n=== 处理完成汇总 ===\n');
    fprintf('匹配方法: %s\n', matchInfo.method);
    fprintf('内点比例: %.1f%%\n', transformInfo.inlierRatio*100);
    fprintf('配准RMSE: %.2f像素\n', transformInfo.rmse);
    fprintf('重叠比例: %.1f%%\n', cropInfo.overlapRatio*100);
    fprintf('融合质量: %.2f\n', fusionInfo.fusionQuality);
    fprintf('结果已保存到: E:/fire_dataset/fire_pairs/pz/\n');
    
    drawnow;
end
