function [matchedPoints1, matchedPoints2, matchInfo] = kaze_feature_matching(J1, J2)
    fprintf('\n=== 3.3.1 KAZE特征检测与一维极线约束匹配 ===\n');
    
    % 转换为灰度图像
    if size(J1, 3) == 3
        gray1 = rgb2gray(J1);
    else
        gray1 = J1;
    end
    
    if size(J2, 3) == 3
        gray2 = rgb2gray(J2);
    else
        gray2 = J2;
    end
    
    % 图像增强
    gray1_enhanced = imadjust(gray1);
    gray2_enhanced = imadjust(gray2);
    
    % KAZE特征检测（改进版）
    fprintf('1. KAZE特征检测（带自适应对比度阈值）...\n');
    
    % 全局阈值
    T_global = 0.0001;
    alpha = 0.5;
    beta = 0.1;
    
    % 检测初始特征点
    points1_init = detectKAZEFeatures(gray1_enhanced, 'Threshold', T_global, ...
        'NumOctaves', 4, 'NumScaleLevels', 4);
    points2_init = detectKAZEFeatures(gray2_enhanced, 'Threshold', T_global, ...
        'NumOctaves', 4, 'NumScaleLevels', 4);
    
    fprintf('  初始特征点: RGB-%d, 热红外-%d\n', length(points1_init), length(points2_init));
    
    % 自适应阈值调整（论文公式5）
    points1 = [];
    points2 = [];
    
    % 对RGB图像进行局部自适应阈值
    for i = 1:length(points1_init)
        loc = round(points1_init.Location(i, :));
        x = max(1, min(loc(1), size(gray1,2)-15));
        y = max(1, min(loc(2), size(gray1,1)-15));
        
        % 提取16x16局部区域
        local_region = gray1(y:min(y+15, size(gray1,1)), x:min(x+15, size(gray1,2)));
        
        % 计算梯度方差
        [gx, gy] = gradient(double(local_region));
        grad_mag = sqrt(gx.^2 + gy.^2);
        sigma2 = var(grad_mag(:));
        
        % 自适应阈值（论文公式5）
        T_local = T_global * (1 + alpha * exp(-beta * sigma2));
        
        if points1_init.Metric(i) > T_local
            points1 = [points1; points1_init(i)];
        end
    end
    
    % 对热红外图像进行局部自适应阈值
    for i = 1:length(points2_init)
        loc = round(points2_init.Location(i, :));
        x = max(1, min(loc(1), size(gray2,2)-15));
        y = max(1, min(loc(2), size(gray2,1)-15));
        
        local_region = gray2(y:min(y+15, size(gray2,1)), x:min(x+15, size(gray2,2)));
        
        [gx, gy] = gradient(double(local_region));
        grad_mag = sqrt(gx.^2 + gy.^2);
        sigma2 = var(grad_mag(:));
        
        T_local = T_global * (1 + alpha * exp(-beta * sigma2));
        
        if points2_init.Metric(i) > T_local
            points2 = [points2; points2_init(i)];
        end
    end
    
    points1 = KAZEPoints(points1.Location);
    points2 = KAZEPoints(points2.Location);
    
    fprintf('  自适应阈值后特征点: RGB-%d, 热红外-%d\n', length(points1), length(points2));
    
    % 提取特征描述符
    fprintf('2. 提取特征描述符...\n');
    [features1, valid_points1] = extractFeatures(gray1_enhanced, points1, 'Method', 'KAZE');
    [features2, valid_points2] = extractFeatures(gray2_enhanced, points2, 'Method', 'KAZE');
    
    % 一维极线约束匹配（论文公式6-8）
    fprintf('3. 一维极线约束匹配...\n');
    
    w = 10;  % 搜索窗口半宽
    matches = [];
    distances = [];
    
    for i = 1:length(valid_points1)
        p1 = valid_points1.Location(i, :);
        y1 = round(p1(2));
        
        % 极线约束：y坐标应该相同（论文公式6）
        candidates = find(abs(valid_points2.Location(:,2) - y1) <= 2);
        
        if length(candidates) < 2
            continue;
        end
        
        % 计算汉明距离（论文公式7）
        best_dist = inf;
        second_best_dist = inf;
        best_idx = -1;
        
        for j = candidates'
            if abs(valid_points2.Location(j,1) - p1(1)) > w
                continue;  % 水平窗口约束
            end
            
            % 计算汉明距离
            dist = sum(bitxor(uint32(features1(i,:)*255), uint32(features2(j,:)*255)));
            
            if dist < best_dist
                second_best_dist = best_dist;
                best_dist = dist;
                best_idx = j;
            elseif dist < second_best_dist
                second_best_dist = dist;
            end
        end
        
        % NNDR筛选（论文公式8）
        if best_idx > 0 && best_dist / second_best_dist < 0.8
            matches = [matches; i, best_idx];
            distances = [distances; best_dist];
        end
    end
    
    fprintf('  初始匹配点对: %d\n', size(matches, 1));
    
    if size(matches, 1) < 4
        error('匹配点不足，请检查图像质量');
    end
    
    % 获取匹配点坐标
    matchedPoints1 = valid_points1.Location(matches(:,1), :);
    matchedPoints2 = valid_points2.Location(matches(:,2), :);
    
    % 存储匹配信息
    matchInfo.method = 'KAZE+自适应阈值+一维极线约束';
    matchInfo.numInitialMatches = size(matches, 1);
    matchInfo.adaptiveThreshold = [alpha, beta];
    matchInfo.searchWindow = w;
    matchInfo.NNDR_threshold = 0.8;
    
    fprintf('  匹配完成，获得 %d 个候选匹配点对\n', size(matchedPoints1, 1));
end
