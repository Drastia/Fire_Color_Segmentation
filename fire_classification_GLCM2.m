function fire_classification_GLCM2
    % Create the GUI figure
    fig = figure('Name', 'Disaster Detection', 'NumberTitle', 'off', 'Position', [10, 100, 1300, 500]);

    % Create axes for displaying images
    axes1 = axes('Parent', fig, 'Position', [0.05, 0.55, 0.15, 0.2]);
    axes2 = axes('Parent', fig, 'Position', [0.05, 0.15, 0.15, 0.2]);
    axes3 = axes('Parent', fig, 'Position', [0.25, 0.55, 0.15, 0.2]);
    axes4 = axes('Parent', fig, 'Position', [0.25, 0.15, 0.15, 0.2]);
    axes5 = axes('Parent', fig, 'Position', [0.45, 0.55, 0.15, 0.2]);
    axes6 = axes('Parent', fig, 'Position', [0.45, 0.15, 0.15, 0.2]);
    axes7 = axes('Parent', fig, 'Position', [0.65, 0.35, 0.15, 0.2]);
  

    hText1 = uicontrol('Style', 'text', 'Position', [60, 400, 200, 30], 'String', 'persentase fire', 'FontSize', 10);
    hText2 = uicontrol('Style', 'text', 'Position', [320, 400, 200, 30], 'String', 'persentase water', 'FontSize', 10);
    hText3 = uicontrol('Style', 'text', 'Position', [580, 400, 200, 30], 'String', 'persentase snow', 'FontSize', 10);
    hText4 = uicontrol('Style', 'text', 'Position', [60, 20, 200, 30], 'String', 'persentase fire', 'FontSize', 10);
    hText5 = uicontrol('Style', 'text', 'Position', [320, 20, 200, 30], 'String', 'persentase water', 'FontSize', 10);
    hText6 = uicontrol('Style', 'text', 'Position', [580, 20, 200, 30], 'String', 'persentase snow', 'FontSize', 10);
    hText7 = uicontrol('Style', 'text', 'Position', [60, 200, 200, 30], 'String', 'distance fire', 'FontSize', 10);
    hText8 = uicontrol('Style', 'text', 'Position', [320, 200, 200, 30], 'String', 'distance water', 'FontSize', 10);
    hText9 = uicontrol('Style', 'text', 'Position', [580, 200, 200, 30], 'String', 'distance snow', 'FontSize', 10);


    % Create buttons for loading images and processing
    uicontrol('Style', 'pushbutton', 'String', 'Open Reference Fire Image', 'Position', [50, 460, 150, 30], 'Callback', @openReferenceFireImage);
    uicontrol('Style', 'pushbutton', 'String', 'Open Reference Water Image', 'Position', [250, 460, 150, 30], 'Callback', @openReferenceWaterImage);
    uicontrol('Style', 'pushbutton', 'String', 'Open Reference snow Image', 'Position', [450, 460, 150, 30], 'Callback', @openReferencesnowImage);
    uicontrol('Style', 'pushbutton', 'String', 'Open Input Image', 'Position', [650, 460, 150, 30], 'Callback', @openInputImage);
    uicontrol('Style', 'pushbutton', 'String', 'Process Images', 'Position', [850, 460, 150, 30], 'Callback', @processImages);

    % Variables to hold images
    reffireImage = [];
    refwaterImage = [];
    refsnowImage = [];
    inputImage = [];

    % Define threshold for Euclidean distance
   
    
    function [fireimage, firePercentage] = fireMask(image)
    
        % Mengonversi gambar ke ruang warna HSV
        hsvImage = rgb2hsv(image);

        % Menentukan rentang warna api dalam ruang warna HSV
        hue = hsvImage(:,:,1); 
        saturation = hsvImage(:,:,2);  
        value = hsvImage(:,:,3);  

        redMask = ((hue >= 0 & hue <= 0.05) | (hue >= 0.95 & hue <= 1)) & (saturation > 0.5) & (value > 0.5);
        orangeMask = (hue > 0.05 & hue <= 0.15) & (saturation > 0.5) & (value > 0.5);
        yellowMask = (hue > 0.15 & hue <= 0.2) & (saturation > 0.5) & (value > 0.5);

        fireMask = redMask | orangeMask | yellowMask;
        
        totalPixels = numel(image(:,:,1));
        redPixels = sum(redMask(:));
        orangePixels = sum(orangeMask(:));
        yellowPixels = sum(yellowMask(:));
        firePixels = sum(fireMask(:));
        
        % Menghitung persentase masing-masing warna
        firePercentage = (firePixels / totalPixels) * 100;
        redPercentage = (redPixels / totalPixels) * 100;
        orangePercentage = (orangePixels / totalPixels) * 100;
        yellowPercentage = (yellowPixels / totalPixels) * 100;

        if redPercentage > 2 && yellowPercentage > 2 || orangePercentage > 1 
           resultImage = zeros(size(image), 'like', image);

            % Menerapkan fireMask ke setiap saluran gambar
            resultImage(:,:,1) = image(:,:,1) .* uint8(fireMask);  % Saluran merah
            resultImage(:,:,2) = image(:,:,2) .* uint8(fireMask);  % Saluran hijau
            resultImage(:,:,3) = image(:,:,3) .* uint8(fireMask);  % Saluran biru

            fireimage = resultImage;
     
        else
            resultImage = zeros(size(image), 'like', image);
            fireimage = resultImage;
        end
       
    
  
    end


    function [waterImage , waterPercentage] = waterMask(image)
    % Convert the image to HSV color space
    hsvImage = rgb2hsv(image);

    % Define the hue, saturation, and value components
    hue = hsvImage(:,:,1); 
    saturation = hsvImage(:,:,2);  
    value = hsvImage(:,:,3);  

    % Mask for blue color range (typical for water)
    blueMask = (hue > 0.5 & hue <= 0.7) & (saturation > 0.3) & (value > 0.3);

    % Mask for cyan color range (another common color for water)
    cyanMask = (hue > 0.4 & hue <= 0.5) & (saturation > 0.3) & (value > 0.3);

    % Combine the masks
    waterMask = blueMask | cyanMask;

    % Calculate total pixels and water pixels
    totalPixels = numel(image(:,:,1));
    waterPixels = sum(waterMask(:));
    

    % Calculate the percentage of water pixels
    waterPercentage = (waterPixels / totalPixels) * 100;
 
    if waterPercentage >20
    % Initialize the result image with all black pixels
    resultImage = zeros(size(image), 'like', image);

    % Apply the waterMask to each channel of the image
    resultImage(:,:,1) = image(:,:,1) .* uint8(waterMask);  % Red channel
    resultImage(:,:,2) = image(:,:,2) .* uint8(waterMask);  % Green channel
    resultImage(:,:,3) = image(:,:,3) .* uint8(waterMask);  % Blue channel

    % Set the output variable
    waterImage = resultImage;
    else
     resultImage = zeros(size(image), 'like', image);
     waterImage = resultImage;
    end

end
    
    function [snowImage, snowPercentage] = snowMask(image)
    % Convert the image to HSV color space
    hsvImage = rgb2hsv(image);

    % Define the hue, saturation, and value components
    hue = hsvImage(:,:,1); 
    saturation = hsvImage(:,:,2);  
    value = hsvImage(:,:,3);  

    % Mask for light colors typical in snow (white, light gray, etc.)
    lightMask = (value > 0.8) & (saturation < 0.2);  

    % Calculate total pixels and snow pixels
    totalPixels = numel(hsvImage(:,:,1));
    snowPixels = sum(lightMask(:));

    
    % Calculate the percentage of snow pixels
    snowPercentage = (snowPixels / totalPixels) * 100;
 
    if snowPercentage > 20

    % Initialize the result image with all black pixels
    resultImage = zeros(size(image), 'like', image);

    % Apply the snowMask to each channel of the image
    resultImage(:,:,1) = image(:,:,1) .* uint8(lightMask);  % Red channel
    resultImage(:,:,2) = image(:,:,2) .* uint8(lightMask);  % Green channel
    resultImage(:,:,3) = image(:,:,3) .* uint8(lightMask);  % Blue channel

    % Set the output variable
    snowImage = resultImage;
    else
        resultImage = zeros(size(image), 'like', image);
        snowImage = resultImage;
    end

end


    % Nested functions for callbacks
    function openReferenceFireImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if isequal(filename, 0)
            return;
        end
        reffireImage = imread(fullfile(pathname, filename));
        axes(axes1);
        imshow(reffireImage);
        title('Reference Image');
    end

     function openReferenceWaterImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if isequal(filename, 0)
            return;
        end
        refwaterImage = imread(fullfile(pathname, filename));
        axes(axes3);
        imshow(refwaterImage);
        title('Reference Image');
     end

    function openReferencesnowImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if isequal(filename, 0)
            return;
        end
        refsnowImage = imread(fullfile(pathname, filename));
        axes(axes5);
        imshow(refsnowImage);
        title('Reference Image');
    end

    function openInputImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if isequal(filename, 0)
            return;
        end
        inputImage = imread(fullfile(pathname, filename));
        axes(axes7);
        imshow(inputImage);
        title('Input Image');
    end
    

    
    function processImages(~, ~)
        if isempty(reffireImage) || isempty(inputImage) || isempty(refwaterImage)|| isempty(refsnowImage)
            errordlg('Please load both reference and input images.');
            return;
        end
        [fireRefImage, fireRefPercentage] = fireMask(reffireImage);
        [waterRefImage, waterRefPercentage] = waterMask(refwaterImage);
        [snowRefImage, snowRefPercentage] = snowMask(refsnowImage);

        [fireInputImage, fireInputPercentage] = fireMask(inputImage);
        [waterInputImage, waterInputPercentage] = waterMask(inputImage);
        [snowInputImage, snowInputPercentage] = snowMask(inputImage);
    

        % Convert images to grayscale
        grayReffireImage = rgb2gray(fireRefImage);
        grayRefwaterImage = rgb2gray(waterRefImage);
        grayRefsnowImage = rgb2gray(snowRefImage);
        grayInputfireImage = rgb2gray(fireInputImage);
        grayInputwaterImage = rgb2gray(waterInputImage);
        grayInputsnowImage = rgb2gray(snowInputImage);

        
        set(hText1, 'String', fireRefPercentage);
        set(hText2, 'String', waterRefPercentage);
        set(hText3, 'String', snowRefPercentage);
        set(hText4, 'String', fireInputPercentage);
        set(hText5, 'String', waterInputPercentage);
        set(hText6, 'String', snowInputPercentage);
        
        
        % Display grayscale images
        axes(axes1);
        imshow(grayReffireImage);
        title('Grayscale fire Reference Image');

        axes(axes3);
        imshow(grayRefwaterImage);
        title('Grayscale water Reference Image');

        axes(axes5);
        imshow(grayRefsnowImage);
        title('Grayscale snow Reference Image');

        axes(axes2);
        imshow(grayInputfireImage);
        title('Grayscale fire Input Image');

        axes(axes4);
        imshow(grayInputwaterImage);
        title('Grayscale water Input Image');

        axes(axes6);
        imshow(grayInputsnowImage);
        title('Grayscale snow Input Image');

        % Compute GLCM and extract features
        reffireGlcm = graycomatrix(grayReffireImage);
        reffireStats = graycoprops(reffireGlcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        reffireFeatures = [reffireStats.Contrast, reffireStats.Correlation, reffireStats.Energy, reffireStats.Homogeneity];

        refwaterGlcm = graycomatrix(grayRefwaterImage);
        refwaterStats = graycoprops(refwaterGlcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        refwaterFeatures = [refwaterStats.Contrast, refwaterStats.Correlation, refwaterStats.Energy, refwaterStats.Homogeneity];

        refsnowGlcm = graycomatrix(grayRefsnowImage);
        refsnowStats = graycoprops(refsnowGlcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        refsnowFeatures = [refsnowStats.Contrast, refsnowStats.Correlation, refsnowStats.Energy, refsnowStats.Homogeneity];

        inputfireGlcm = graycomatrix(grayInputfireImage);
        inputfireStats = graycoprops(inputfireGlcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        inputfireFeatures = [inputfireStats.Contrast, inputfireStats.Correlation, inputfireStats.Energy, inputfireStats.Homogeneity];

        inputwaterGlcm = graycomatrix(grayInputwaterImage);
        inputwaterStats = graycoprops(inputwaterGlcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        inputwaterFeatures = [inputwaterStats.Contrast, inputwaterStats.Correlation, inputwaterStats.Energy, inputwaterStats.Homogeneity];

        inputsnowGlcm = graycomatrix(grayInputsnowImage);
        inputsnowStats = graycoprops(inputsnowGlcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        inputsnowFeatures = [inputsnowStats.Contrast, inputsnowStats.Correlation, inputsnowStats.Energy, inputsnowStats.Homogeneity];

        % Compute Euclidean distance between the features
        distanceFire = sqrt(sum((reffireFeatures - inputfireFeatures).^2));
        distanceWater = sqrt(sum((refwaterFeatures - inputwaterFeatures).^2));
        distancesnow = sqrt(sum((refsnowFeatures - inputsnowFeatures).^2));

       if isnan(distanceFire)
         distanceFire = inf ;
       end

       if isnan(distanceWater)
            distanceWater = inf ;
       end

       if isnan(distancesnow)
            distancesnow = inf ;
       end
        
        disp(['Euclidean fire Distance: ', num2str(distanceFire)]);
        disp(['Euclidean water Distance: ', num2str(distanceWater)]);
        disp(['Euclidean snow Distance: ', num2str(distancesnow)]);
        set(hText7, 'String', distanceFire);
        set(hText8, 'String', distanceWater);
        set(hText9, 'String', distancesnow);
        
        if distanceFire < distanceWater && distanceFire < distancesnow
        msgbox('The input image is fire', 'Result');
    elseif distanceWater < distanceFire && distanceWater < distancesnow
        msgbox('The input image is water', 'Result');
    elseif distancesnow < distanceFire && distancesnow < distanceWater
        msgbox('The input image is snow', 'Result');
        else
        msgbox('Unable to determine the type of disaster', 'Result');
        end
    end
   
    
    
end
