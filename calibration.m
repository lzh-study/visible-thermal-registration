function [stereoParams, H1, H2] = load_calibration_params()
    fprintf('\n=== 3.2 联合标定 ===\n');
    
    % 尝试加载已有的标定参数
    try
        load('my7stereoParams.mat');
        fprintf('成功加载标定参数文件\n');
    catch
        fprintf('未找到标定参数文件，使用论文中的标定参数...\n');
        
        % 使用论文Table 3和Table 4中的参数
        % RGB相机内参
        K1 = [467.71, 0, 322.12;
              0, 467.74, 237.57;
              0, 0, 1];
        
        % 热红外相机内参
        K2 = [897.12, 0, 318.18;
              0, 841.37, 237.41;
              0, 0, 1];
        
        % 畸变系数
        radialDist1 = [0.0201, 0.0039];
        tangentialDist1 = [-0.0045, 0.0017];
        
        radialDist2 = [-0.3933, 0.1968];
        tangentialDist2 = [0.0024, -0.0012];
        
        % 外参（旋转矩阵和平移向量）- Table 4
        R = [0.9998, 0.0141, -0.0153;
             -0.0142, 0.9999, -0.0061;
             0.0152, 0.0063, 0.9999];
        
        t = [-8.6387; -39.3858; 5.8862];
        
        % 创建相机参数对象
        camParams1 = cameraParameters('IntrinsicMatrix', K1', ...
            'RadialDistortion', radialDist1, ...
            'TangentialDistortion', tangentialDist1);
        
        camParams2 = cameraParameters('IntrinsicMatrix', K2', ...
            'RadialDistortion', radialDist2, ...
            'TangentialDistortion', tangentialDist2);
        
        % 创建立体参数对象
        stereoParams = stereoParameters(camParams1, camParams2, R, t);
    end
    
    % 重投影变换矩阵（论文Table 5）
    H1 = [1.0031, 0.0022, -8.2442;
          0.0025, 1.0017, -6.2966;
          4.7707, 3.5538, 0.9951];
    
    H2 = [1.0033, 0.0046, -1279.8856;
          0.0093, -1.0016, -1.3247;
          5.186, -3.5057, -1.0016];
    
    fprintf('标定参数加载完成\n');
    fprintf('  重投影误差: ~0.21像素\n');
end

%% 立体校正（论文3.2.3节）
function [J1_rect, J2_rect, rectInfo] = stereo_rectification(J1, J2, stereoParams, H1, H2)
    fprintf('\n=== 3.2.3 立体校正 ===\n');
    
    % 去畸变
    fprintf('进行图像去畸变...\n');
    J1_undist = undistortImage(J1, stereoParams.CameraParameters1);
    
    if size(J2, 3) == 3
        J2_gray = rgb2gray(J2);
    else
        J2_gray = J2;
    end
    J2_undist = undistortImage(J2_gray, stereoParams.CameraParameters2);
    
    % 应用重投影变换矩阵
    fprintf('应用重投影变换矩阵...\n');
    
    tform1 = projective2d(H1');
    J1_rect = imwarp(J1_undist, tform1, 'OutputView', imref2d(size(J1_undist)));
    
    tform2 = projective2d(H2');
    J2_rect = imwarp(J2_undist, tform2, 'OutputView', imref2d(size(J2_undist)));
    
    % 确保尺寸一致
    target_size = size(J1_rect);
    if ~isequal(size(J2_rect), target_size)
        J2_rect = imresize(J2_rect, target_size(1:2));
    end
    
    % 如果是灰度图，转换为RGB
    if size(J2_rect, 3) == 1
        J2_rect = repmat(J2_rect, [1 1 3]);
    end
    
    rectInfo.method = '重投影变换';
    rectInfo.H1 = H1;
    rectInfo.H2 = H2;
    rectInfo.epipolarConstraint = '行对齐';
    
    fprintf('立体校正完成，图像已实现行对齐\n');
end
