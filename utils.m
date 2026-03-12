%% 更新进度条函数
function updateProgress(ax, percent, message)
    cla(ax);
    rectangle(ax, 'Position', [0 0 percent 1], 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'none');
    rectangle(ax, 'Position', [percent 0 100-percent 1], 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none');
    text(ax, 50, 0.5, [num2str(percent) '% - ' message], ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    drawnow;
end

%% 图像加载函数
function [I1, I2] = load_images()
    % 这里替换为您的实际图像路径
    rgbPath = 'E:/fire_dataset/fire_pairs/2r.jpg';
    thermalPath = 'E:/fire_dataset/fire_pairs/2i.jpg';
    
    I1 = imread(rgbPath);
    I2 = imread(thermalPath);
    
    if isempty(I1) || isempty(I2)
        error('无法读取图像，请检查文件路径');
    end
    
    fprintf('图像加载成功:\n');
    fprintf('  RGB图像: %s (%dx%dx%d)\n', rgbPath, size(I1,2), size(I1,1), size(I1,3));
    fprintf('  热红外图像: %s (%dx%dx%d)\n', thermalPath, size(I2,2), size(I2,1), size(I2,3));
end

%% 保存裁剪图像
function save_cropped_images_paper(J1_cropped, J2_cropped, cropInfo)
    save_dir = 'E:/fire_dataset/fire_pairs/pz/';
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
        fprintf('创建目录: %s\n', save_dir);
    end
    
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    size_str = sprintf('%dx%d', size(J1_cropped,2), size(J1_cropped,1));
    
    rgb_filename = fullfile(save_dir, ['rgb_overlap_' size_str '_' timestamp '.jpg']);
    thermal_filename = fullfile(save_dir, ['thermal_overlap_' size_str '_' timestamp '.jpg']);
    
    imwrite(J1_cropped, rgb_filename, 'jpg', 'Quality', 98);
    imwrite(J2_cropped, thermal_filename, 'jpg', 'Quality', 98);
    
    fprintf('\n重叠区域图像已保存:\n');
    fprintf('  RGB图像: %s\n', rgb_filename);
    fprintf('  热红外图像: %s\n', thermal_filename);
end

%% 保存融合图像
function save_fused_image_paper(J_F)
    save_dir = 'E:/fire_dataset/fire_pairs/pz/';
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end
    
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    size_str = sprintf('%dx%d', size(J_F,2), size(J_F,1));
    
    fused_filename = fullfile(save_dir, ['fused_overlap_' size_str '_' timestamp '.jpg']);
    
    imwrite(J_F, fused_filename, 'jpg', 'Quality', 98);
    fprintf('融合图像已保存: %s\n', fused_filename);
end

%% KAZEPoints类
function points = KAZEPoints(locations)
    points = struct('Location', locations, 'Metric', ones(size(locations,1),1));
end
