function main()
    % 清除工作空间
    clear all; clc; close all;
    
    fprintf('========================================\n');
    fprintf('RGB与热红外图像配准与融合系统\n');
    fprintf('========================================\n\n');
    
    %% 1. 初始化界面
    fig = figure('Name', 'RGB与热红外图像配准与融合系统', 'NumberTitle', 'off', ...
                'Position', [100, 100, 1400, 900], 'MenuBar', 'none', ...
                'Color', [0.94 0.94 0.94], 'Resize', 'on');
    
    % 创建主面板
    mainPanel = uipanel('Parent', fig, 'Title', '处理流程', ...
                       'Position', [0.02 0.02 0.96 0.96], ...
                       'FontSize', 14, 'FontWeight', 'bold', ...
                       'BackgroundColor', [0.96 0.96 0.96], ...
                       'BorderType', 'etchedin', 'HighlightColor', [0.5 0.5 0.5]);
    
    % 添加标题
    titlePanel = uipanel('Parent', mainPanel, 'BorderType', 'none', ...
                        'Position', [0.2 0.88 0.6 0.1], ...
                        'BackgroundColor', [0.96 0.96 0.96]);
    uicontrol('Parent', titlePanel, 'Style', 'text', ...
             'String', 'RGB与热红外图像配准与融合系统 ', ...
             'FontSize', 16, 'FontWeight', 'bold', ...
             'ForegroundColor', [0.2 0.2 0.6], ...
             'BackgroundColor', [0.96 0.96 0.96], ...
             'Position', [10 10 800 40], 'HorizontalAlignment', 'center');
    
    %% 2. 图像读取和预处理
    try
        % 进度条
        progressBar = uipanel('Parent', mainPanel, 'Title', '处理进度', ...
                             'Position', [0.35 0.8 0.3 0.07], ...
                             'FontSize', 11, 'BackgroundColor', [0.96 0.96 0.96]);
        progressAxes = axes('Parent', progressBar, 'Position', [0.05 0.3 0.9 0.5], ...
                           'XLim', [0 100], 'YLim', [0 1], 'XTick', [], 'YTick', []);
        rectangle(progressAxes, 'Position', [0 0 0 1], 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'none');
        text(progressAxes, 50, 0.5, '0%', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        drawnow;
        
        % 更新进度条
        updateProgress(progressAxes, 5, '正在加载图像...');
        
        % 读取图像
        [I1, I2] = load_images();
        
        % 图像预处理
        updateProgress(progressAxes, 10, '图像预处理...');
        [J1, J2] = preprocess_images_paper(I1, I2);
        
        % 显示原始图像
        updateProgress(progressAxes, 15, '显示原始图像...');
        display_images(mainPanel, J1, J2, '预处理后图像');
        
        %% 3. 联合标定（模拟标定参数）
        updateProgress(progressAxes, 20, '联合标定处理...');
        [stereoParams, H1, H2] = load_calibration_params();
        
        %% 4. 立体校正
        updateProgress(progressAxes, 25, '立体校正...');
        [J1_rect, J2_rect, rectInfo] = stereo_rectification(J1, J2, stereoParams, H1, H2);
        
        % 显示校正结果
        updateProgress(progressAxes, 30, '显示校正结果...');
        display_rectification_results(mainPanel, J1, J2, J1_rect, J2_rect, rectInfo);
        
        %% 5. KAZE特征检测与一维极线约束匹配
        updateProgress(progressAxes, 40, 'KAZE特征检测与一维极线约束匹配...');
        [matchedPoints1, matchedPoints2, matchInfo] = kaze_feature_matching(J1_rect, J2_rect);
        
        %% 6. 简化仿射变换模型估计
        updateProgress(progressAxes, 50, '简化仿射变换模型估计...');
        [H_final, inlierIdx, transformInfo] = estimate_simplified_affine(matchedPoints1, matchedPoints2);
        
        % 显示匹配结果
        updateProgress(progressAxes, 55, '显示特征匹配结果...');
        display_match_results_paper(mainPanel, J1_rect, J2_rect, ...
            matchedPoints1(inlierIdx), matchedPoints2(inlierIdx), matchInfo, transformInfo);
        
        %% 7. 图像重映射
        updateProgress(progressAxes, 60, '图像重映射...');
        J2_aligned = image_remapping(J2_rect, H_final, size(J1_rect));
        
        %% 8. 精确裁剪共同重叠区域
        updateProgress(progressAxes, 65, '裁剪共同重叠区域...');
        [J1_cropped, J2_cropped, cropInfo] = crop_overlap_region_paper(J1_rect, J2_aligned);
        
        %% 9. 保存裁剪后的图像
        updateProgress(progressAxes, 70, '保存裁剪图像...');
        save_cropped_images_paper(J1_cropped, J2_cropped, cropInfo);
        
        %% 10. 图像融合
        updateProgress(progressAxes, 80, '图像融合处理...');
        [J_F, fusionInfo] = fuse_images_paper(J1_cropped, J2_cropped);
        
        %% 11. 保存融合结果
        updateProgress(progressAxes, 85, '保存融合图像...');
        save_fused_image_paper(J_F);
        
        %% 12. 综合显示结果
        updateProgress(progressAxes, 95, '显示最终结果...');
        display_final_results_paper(mainPanel, J1_cropped, J2_cropped, J_F, ...
            matchInfo, transformInfo, cropInfo, fusionInfo);
        
        % 完成进度条
        updateProgress(progressAxes, 100, '处理完成!');
        pause(0.5);
        delete(progressBar);
        
        fprintf('\n=== 处理完成！===\n');
        
    catch ME
        errordlg(['处理过程中发生错误: ' ME.message], '错误');
        rethrow(ME);
    end
end
