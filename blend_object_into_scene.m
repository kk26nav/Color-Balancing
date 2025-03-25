function blend_object_into_scene()
    clc; clear; close all;

    % -----------------------------
    % 1) Load Images
    % -----------------------------
    phone_img = imread('phone4.jpg');  % Object to blend
    bg_img = imread('source.jpg');     % Background scene

    % Optional resizing
    phone_img = imresize(phone_img, [600, 300]); 
    bg_img = imresize(bg_img, [800, 1200]);

    % -----------------------------
    % 2) Create Alpha Mask (Transparency)
    % -----------------------------
    % HSV-based masking
    phone_hsv = rgb2hsv(phone_img);
    saturation = phone_hsv(:,:,2);
    value = phone_hsv(:,:,3);
    mask = ~(saturation < 0.1 & value > 0.9);  % Detect non-white regions
    mask = imfill(mask, 'holes');               % Fill holes
    mask = bwareaopen(mask, 100);               % Remove small noise
    mask = imclose(mask, strel('disk', 5));     % Smooth edges

    % Convert mask to uint8 alpha channel [0-255]
    alpha = uint8(mask * 255);  

    % Save transparent version (now works correctly)
    imwrite(phone_img, 'transparent_phone.png', 'Alpha', alpha);

    % -----------------------------
    % 3) Color Balancing
    % -----------------------------
    src_points = [50 50; size(phone_img,2)-50 50; size(phone_img,2)/2 size(phone_img,1)/2];
    tgt_points = [400 400; 600 400; 500 600];
    phone_balanced = color_balance_rbf(phone_img, bg_img, src_points, tgt_points);

    % -----------------------------
    % 4) Alpha-Based Blending
    % -----------------------------
    composite_img = bg_img;
    [bgH, bgW, ~] = size(bg_img);
    [phoneH, phoneW, ~] = size(phone_balanced);

    % Position parameters
    topLeftRow = 150; 
    topLeftCol = 300; 

    % Check boundaries
    if (topLeftRow + phoneH > bgH) || (topLeftCol + phoneW > bgW)
        error('Object placement exceeds background dimensions.');
    end

    % Extract target region
    rows = topLeftRow:(topLeftRow + phoneH - 1);
    cols = topLeftCol:(topLeftCol + phoneW - 1);
    bg_region = composite_img(rows, cols, :);

    % Normalize alpha to [0, 1] for blending
    alpha_normalized = double(alpha) / 255;  % Convert to double for calculations
    alpha_3ch = repmat(alpha_normalized, [1, 1, 3]);

    % Blend using alpha values: composite = (phone * alpha) + (bg * (1 - alpha))
    blended_region = uint8(...
        double(phone_balanced) .* alpha_3ch + ...
        double(bg_region) .* (1 - alpha_3ch) ...
    );

    % Update composite image
    composite_img(rows, cols, :) = blended_region;

    % -----------------------------
    % 5) Display Results
    % -----------------------------
    figure('Name','Blending Results');
    subplot(2,2,1), imshow(phone_img), title('Original Object');
    subplot(2,2,2), imshow(alpha), title('Alpha Mask');
    subplot(2,2,3), imshow(phone_balanced), title('Color-Balanced Object');
    subplot(2,2,4), imshow(composite_img), title('Final Composite');
end