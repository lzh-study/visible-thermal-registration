function [H_final, inlierIdx, transformInfo] = estimate_simplified_affine(points1, points2)
    fprintf('\n=== 3.3.2 简化仿射变换模型估计 ===\n');
    
    numPoints = size(points1, 1);
    if numPoints < 4
        error('至少需要4个匹配点进行RANSAC估计');
    end
    
    % RANSAC参数
    maxTrials = 3000;
    maxDistance = 3.0;  % 内点距离阈值
    confidence = 99;
    
    bestInliers = 0;
    bestParams = [];
    bestInlierIdx = [];
    
    fprintf('RANSAC迭代估计简化仿射模型（4参数）...\n');
    
    for trial = 1:maxTrials
        % 随机选择2对非共线点（最小样本集）
        idx = randperm(numPoints, 2);
        p1 = points1(idx, :);
        p2 = points2(idx, :);
        
        % 检查共线性
        if abs(p1(1,1) - p1(2,1)) < 1e-6 && abs(p1(1,2) - p1(2,2)) < 1e-6
            continue;
        end
        
        % 构建矩阵A和b（论文公式13）
        A = [p1(1,1), p1(1,2), 1, 0;
             0, 0, 0, 1;
             p1(2,1), p1(2,2), 1, 0;
             0, 0, 0, 1];
        
        b = [p2(1,1);
             p2(1,2) - p1(1,2);
             p2(2,1);
             p2(2,2) - p1(2,2)];
        
        % 求解参数（论文公式14）
        if rank(A) == 4
            params = A \ b;
            
            % 计算所有点的投影误差
            errors = zeros(numPoints, 1);
            for i = 1:numPoints
                x_proj = params(1) * points1(i,1) + params(2) * points1(i,2) + params(3);
                y_proj = points1(i,2) + params(4);
                
                err = sqrt((x_proj - points2(i,1))^2 + (y_proj - points2(i,2))^2);
                errors(i) = err;
            end
            
            % 统计内点
            inliers = errors < maxDistance;
            numInliers = sum(inliers);
            
            if numInliers > bestInliers
                bestInliers = numInliers;
                bestParams = params;
                bestInlierIdx = inliers;
                
                % 如果内点足够多，提前停止
                if numInliers > 0.7 * numPoints
                    break;
                end
            end
        end
    end
    
    % 使用所有内点重新估计参数
    if ~isempty(bestParams) && bestInliers >= 4
        inlierIdx = bestInlierIdx;
        inlierPoints1 = points1(inlierIdx, :);
        inlierPoints2 = points2(inlierIdx, :);
        
        % 构建所有内点的方程组
        A_all = [];
        b_all = [];
        for i = 1:size(inlierPoints1, 1)
            A_all = [A_all;
                     inlierPoints1(i,1), inlierPoints1(i,2), 1, 0;
                     0, 0, 0, 1];
            b_all = [b_all;
                     inlierPoints2(i,1);
                     inlierPoints2(i,2) - inlierPoints1(i,2)];
        end
        
        % 最小二乘求解最终参数
        finalParams = A_all \ b_all;
        
        % 构建仿射变换矩阵
        H_final = [finalParams(1), finalParams(2), finalParams(3);
                   0, 1, finalParams(4);
                   0, 0, 1];
        
        % 计算最终误差
        finalErrors = zeros(sum(inlierIdx), 1);
        for i = 1:sum(inlierIdx)
            x_proj = finalParams(1) * inlierPoints1(i,1) + finalParams(2) * inlierPoints1(i,2) + finalParams(3);
            y_proj = inlierPoints1(i,2) + finalParams(4);
            finalErrors(i) = sqrt((x_proj - inlierPoints2(i,1))^2 + (y_proj - inlierPoints2(i,2))^2);
        end
        
        transformInfo.method = '简化仿射变换';
        transformInfo.params = finalParams;
        transformInfo.numInliers = sum(inlierIdx);
        transformInfo.inlierRatio = sum(inlierIdx) / numPoints;
        transformInfo.rmse = sqrt(mean(finalErrors.^2));
        transformInfo.maxError = max(finalErrors);
        transformInfo.minError = min(finalErrors);
        
        fprintf('  简化仿射模型参数: a11=%.4f, a12=%.4f, tx=%.4f, ty=%.4f\n', ...
            finalParams(1), finalParams(2), finalParams(3), finalParams(4));
        fprintf('  内点数量: %d/%d (%.1f%%)\n', sum(inlierIdx), numPoints, ...
            transformInfo.inlierRatio*100);
        fprintf('  RMSE: %.2f像素\n', transformInfo.rmse);
        
    else
        error('RANSAC未能找到足够的内点');
    end
end
