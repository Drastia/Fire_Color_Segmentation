% Load the reference image (first image)
referenceImage = imread('D:\IF61\PCD\fire1.jpg');

% Convert the reference image to HSV color space for color detection
hsvRef = rgb2hsv(referenceImage);

% Define HSV range for detecting fire color (tweak these values if necessary)
hueMin = 0; hueMax = 0.1; % Adjust hue range for fire
satMin = 0.5; satMax = 1; % Adjust saturation range for fire
valMin = 0.5; valMax = 1; % Adjust value range for fire

% Create a mask for the fire color
fireMaskRef = (hsvRef(:,:,1) >= hueMin & hsvRef(:,:,1) <= hueMax) & ...
              (hsvRef(:,:,2) >= satMin & hsvRef(:,:,2) <= satMax) & ...
              (hsvRef(:,:,3) >= valMin & hsvRef(:,:,3) <= valMax);

% Apply the mask to the reference image
fireRef = referenceImage;
fireRef(repmat(~fireMaskRef, [1 1 3])) = 0;

% Detect the bounding box of the fire in the reference image
statsRef = regionprops(fireMaskRef, 'BoundingBox');
bboxRef = statsRef(1).BoundingBox; % Assuming there's only one fire region

% Extract the fire region
fireRegionRef = imcrop(referenceImage, bboxRef);

% Show the fire region
figure;
imshow(fireRegionRef);
title('Detected Fire Region in Reference Image');

% Load the input image (second image)
inputImage = imread('D:\IF61\PCD\download3.jpeg');

% Convert the input image to HSV color space
hsvInput = rgb2hsv(inputImage);

% Create a mask for the fire color in the input image
fireMaskInput = (hsvInput(:,:,1) >= hueMin & hsvInput(:,:,1) <= hueMax) & ...
                (hsvInput(:,:,2) >= satMin & hsvInput(:,:,2) <= satMax) & ...
                (hsvInput(:,:,3) >= valMin & hsvInput(:,:,3) <= valMax);

% Apply the mask to the input image
fireInput = inputImage;
fireInput(repmat(~fireMaskInput, [1 1 3])) = 0;

% Detect the bounding box of the fire in the input image
statsInput = regionprops(fireMaskInput, 'BoundingBox');

% Initialize the minimum distance to a large value
minDistance = inf;
bestMatch = [];

% Loop through each detected fire region in the input image
for k = 1:length(statsInput)
    bboxInput = statsInput(k).BoundingBox;
    fireRegionInput = imcrop(inputImage, bboxInput);
    
    % Resize the fire region in the input image to match the reference fire region
    resizedFireRegionInput = imresize(fireRegionInput, [size(fireRegionRef, 1) size(fireRegionRef, 2)]);
    
    % Calculate the Euclidean distance between the reference fire region and the input fire region
    distance = sqrt(sum((double(fireRegionRef(:)) - double(resizedFireRegionInput(:))).^2));
    
    % Update the minimum distance and best match if a closer match is found
    if distance < minDistance
        minDistance = distance;
        bestMatch = bboxInput;
    end
end

% Display the best match bounding box on the input image
figure;
imshow(inputImage);
hold on;
if ~isempty(bestMatch)
    rectangle('Position', bestMatch, 'EdgeColor', 'r', 'LineWidth', 2);
    title('Detected Fire Region in Input Image');
else
    title('No Fire Detected in Input Image');
end
hold off;
