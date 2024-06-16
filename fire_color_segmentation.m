function fire_detection_GUI
    %Create the GUI figure
    fig = figure('Name', 'Fire Detection', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);

    %Create axes for displaying images
    axes1 = axes('Parent', fig, 'Position', [0.05, 0.55, 0.4, 0.4]);
    axes2 = axes('Parent', fig, 'Position', [0.55, 0.55, 0.4, 0.4]);
    axes3 = axes('Parent', fig, 'Position', [0.05, 0.05, 0.4, 0.4]);
    axes4 = axes('Parent', fig, 'Position', [0.55, 0.05, 0.4, 0.4]);

    %Create buttons for loading images and processing
    uicontrol('Style', 'pushbutton', 'String', 'Open Reference Image', 'Position', [10, 550, 150, 30], 'Callback', @(~,~) openReferenceImage());
    uicontrol('Style', 'pushbutton', 'String', 'Open Input Image', 'Position', [10, 510, 150, 30], 'Callback', @(~,~) openInputImage());
    uicontrol('Style', 'pushbutton', 'String', 'Process Images', 'Position', [10, 470, 150, 30], 'Callback', @(~,~) processImages());

    %Variables to hold images
    refImage = [];
    inputImage = [];
    
    %Define threshold for Euclidean distance
    threshold = 0.3;  % You can adjust this value based on your requirements

    %Open image input and reference and then put it in the axes vessel
    function openReferenceImage()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if isequal(filename,0)
            return;
        end
        refImage = imread(fullfile(pathname, filename));
        axes(axes1);
        imshow(refImage);
        title('Reference Image');
    end

    function openInputImage()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if isequal(filename,0)
            return;
        end
        inputImage = imread(fullfile(pathname, filename));
        axes(axes2);
        imshow(inputImage);
        title('Input Image');
    end

    function processImages()
        if isempty(refImage) || isempty(inputImage)
            errordlg('Please load both reference and input images.');
            return;
        end

        %Convert to L*a*b color space
        labRef = rgb2lab(refImage);
        labInput = rgb2lab(inputImage);

        %Segment using K-Means Clustering
        segmentedRef = segmentImage(labRef);
        segmentedInput = segmentImage(labInput);

        %Display segmented images
        axes(axes3);
        imshow(segmentedRef);
        title('Segmented Reference Image');
        axes(axes4);
        imshow(segmentedInput);
        title('Segmented Input Image');

        %Extract features and calculate Euclidean distance
        featuresRef = extractFeatures(segmentedRef);
        featuresInput = extractFeatures(segmentedInput);

        distance = sqrt(sum((featuresRef - featuresInput).^2));
        disp(['Euclidean Distance: ', num2str(distance)]);

        if distance < threshold
            msgbox('Fire detected!', 'Result');
        else
            msgbox('No fire detected.', 'Result');
        end
    end

    function segmentedImg = segmentImage(labImg)
        ab = double(labImg(:,:,2:3));
        nrows = size(ab,1);
        ncols = size(ab,2);
        ab = reshape(ab,nrows*ncols,2);

        nColors = 2;
        [cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                  'Replicates',3);

        pixel_labels = reshape(cluster_idx,nrows,ncols);

        segmentedImg = label2rgb(pixel_labels);
    end

    function features = extractFeatures(segmentedImg)
        grayImg = rgb2gray(segmentedImg);
        glcm = graycomatrix(grayImg);

        stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        features = [stats.Contrast, stats.Correlation, stats.Energy, stats.Homogeneity];
    end
end
