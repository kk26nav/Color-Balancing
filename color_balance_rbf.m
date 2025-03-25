function transformed_img = color_balance_rbf(source_img, target_img, src_points, tgt_points)
    % Convert RGB images to CIE LAB color space
    lab_src = rgb2lab(im2double(source_img));
    lab_tgt = rgb2lab(im2double(target_img));

    % Extract image dimensions from source image
    [rows, cols, channels] = size(lab_src);
    
    % Resize target to match source dimensions if needed
    if ~isequal(size(lab_src), size(lab_tgt))
        lab_tgt = imresize(lab_tgt, [rows, cols]);
    end

    % Clamp control points so they fall within [1, cols] and [1, rows]
    src_points(:,1) = min(max(src_points(:,1), 1), cols);
    src_points(:,2) = min(max(src_points(:,2), 1), rows);
    tgt_points(:,1) = min(max(tgt_points(:,1), 1), cols);
    tgt_points(:,2) = min(max(tgt_points(:,2), 1), rows);

    num_pixels = rows * cols;
    
    % Compute color correspondences in Lab space from given control points
    N = size(src_points, 1);
    src_colors = zeros(N, 3);
    tgt_colors = zeros(N, 3);
    for i = 1:N
        src_colors(i,:) = lab_src(src_points(i,2), src_points(i,1), :);
        tgt_colors(i,:) = lab_tgt(tgt_points(i,2), tgt_points(i,1), :);
    end

    %----- RANSAC Outlier Rejection -----
    % Set RANSAC parameters (adjust threshold as needed in Lab space)
    threshold = 2.0;  % allowable color difference in Lab
    max_iter = 200;   % number of iterations
    [inlierMask, bestM] = ransacAffineColor(src_colors, tgt_colors, threshold, max_iter);

    % Filter out outlier correspondences based on RANSAC
    src_points = src_points(inlierMask, :);
    tgt_points = tgt_points(inlierMask, :);
    % Update number of control points after filtering
    num_control = size(src_points, 1);
    %------------------------------------

    % Create grid of pixel coordinates for the entire image
    [X, Y] = meshgrid(1:cols, 1:rows);
    pixel_coords = [X(:), Y(:)];  % size: (num_pixels x 2)

    % Initialize the output (transformed) image in Lab space
    transformed_lab = lab_src;

    % For each LAB channel, compute an RBF correction based on the inlier control points
    for c = 1:channels
        % Extract control point values for channel c using interp2
        src_vals = interp2(X, Y, lab_src(:,:,c), src_points(:,1), src_points(:,2), 'linear', 0);
        tgt_vals = interp2(X, Y, lab_tgt(:,:,c), tgt_points(:,1), tgt_points(:,2), 'linear', 0);

        % Compute distances from every pixel to each control point
        distances = pdist2(pixel_coords, src_points);  % (num_pixels x num_control)
        epsilon = 1e-6;  % small constant to avoid division by zero
        % Use a Gaussian RBF kernel; sigma is set to the mean distance
        rbf_weights = exp(-distances.^2 / (2 * (mean(distances(:))^2 + epsilon)));

        % Compute RBF correction: a weighted sum of the differences (target - source)
        rbf_vals = rbf_weights * (tgt_vals - src_vals);  % (num_pixels x 1)
        % Sum of weights for normalization
        weight_sum = sum(rbf_weights, 2) + epsilon;  % (num_pixels x 1)

        % Reshape the normalized correction to image size and apply it to the source channel
        rbf_correction = reshape(rbf_vals ./ weight_sum, rows, cols);
        transformed_lab(:,:,c) = lab_src(:,:,c) + rbf_correction;
    end

    % Convert the corrected LAB image back to RGB
    transformed_img = lab2rgb(transformed_lab);
    % Clamp LAB values to valid ranges
    transformed_lab(:,:,1) = min(max(transformed_lab(:,:,1), 0), 100);    % L: [0, 100]
    transformed_lab(:,:,2) = min(max(transformed_lab(:,:,2), -128), 127);  % a: [-128, 127]
    transformed_lab(:,:,3) = min(max(transformed_lab(:,:,3), -128), 127);  % b: [-128, 127]

    % Convert back to RGB and scale to [0, 1]
    transformed_img = lab2rgb(transformed_lab);
    
    % Ensure output is uint8 [0, 255]
    transformed_img = im2uint8(transformed_img);
end

%% RANSAC for Affine Color Transformation in LAB space
function [inlierMask, bestM] = ransacAffineColor(src_colors, tgt_colors, threshold, max_iter)
    N = size(src_colors, 1);
    if N < 4
        inlierMask = true(N,1);
        bestM = eye(3,4);
        return;
    end
    bestInlierCount = 0;
    bestM = eye(3,4);  % Default transform
    % Convert source colors to homogeneous coordinates (Nx4)
    src_h = [src_colors, ones(N,1)];
    
    for i = 1:max_iter
        % Randomly select 4 distinct correspondences
        subset_idx = randperm(N, 4);
        % Estimate affine transform (3x4) from these 4 points
        M_est = estimateAffine3x4(src_h(subset_idx,:), tgt_colors(subset_idx,:));
        % Apply the estimated transform to all source colors
        tgt_pred = applyAffine3x4(M_est, src_h);
        % Compute Euclidean errors between predicted and actual target colors
        errors = sqrt(sum((tgt_pred - tgt_colors).^2, 2));
        % Determine current inliers
        currInlierMask = errors < threshold;
        inlierCount = sum(currInlierMask);
        if inlierCount > bestInlierCount
            bestInlierCount = inlierCount;
            bestM = M_est;
        end
    end
    
    % Recompute inlier mask using best transform found
    tgt_pred = applyAffine3x4(bestM, src_h);
    finalErrors = sqrt(sum((tgt_pred - tgt_colors).^2, 2));
    inlierMask = finalErrors < threshold;
end

%% Helper: Estimate a 3x4 affine transform from 4 correspondences
function M = estimateAffine3x4(src_h, tgt)
    % Solve for M in M * src_h' = tgt'
    M = tgt' / src_h';
end

%% Helper: Apply a 3x4 affine transform to homogeneous coordinates
function tgt_pred = applyAffine3x4(M, src_h)
    tgt_pred = (M * src_h')';
end
