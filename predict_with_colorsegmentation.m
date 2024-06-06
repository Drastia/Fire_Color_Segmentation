function FireDetectionGUI
    % Membuat figure utama
    hFig = figure('Position', [100, 100, 600, 400], 'MenuBar', 'none', ...
        'Name', 'Deteksi Kebakaran', 'NumberTitle', 'off', 'Resize', 'off');

    % Tombol untuk mengunggah gambar
    uicontrol('Style', 'pushbutton', 'String', 'Upload Gambar', ...
        'Position', [250, 350, 100, 40], 'Callback', @uploadImage);

    % Axes untuk menampilkan gambar asli
    hAxes1 = axes('Parent', hFig, 'Units', 'pixels', 'Position', [50, 100, 200, 200]);
    title(hAxes1, 'Gambar Asli');

    % Axes untuk menampilkan hasil segmentasi
    hAxes2 = axes('Parent', hFig, 'Units', 'pixels', 'Position', [350, 100, 200, 200]);
    title(hAxes2, 'Segmentasi Warna Api');

    % Text untuk menampilkan hasil deteksi
    hResult = uicontrol('Style', 'text', 'Position', [200, 50, 200, 40], ...
        'FontSize', 12, 'HorizontalAlignment', 'center', 'String', '');

    function uploadImage(~, ~)
        % Dialog untuk memilih gambar
        [fileName, filePath] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'});
        if fileName == 0
            return; % Jika pengguna membatalkan dialog
        end

        % Memuat gambar yang dipilih
        image = imread(fullfile(filePath, fileName));

        % Menampilkan gambar asli
        axes(hAxes1);
        imshow(image);
        title(hAxes1, 'Gambar Asli');

        % Mengonversi gambar ke ruang warna HSV
        hsvImage = rgb2hsv(image);

        % Menentukan rentang warna api dalam ruang warna HSV
        hue = hsvImage(:,:,1);  % Komponen Hue
        saturation = hsvImage(:,:,2);  % Komponen Saturation
        value = hsvImage(:,:,3);  % Komponen Value

        % Masker untuk warna merah
        redMask = ((hue >= 0 & hue <= 0.05) | (hue >= 0.95 & hue <= 1)) & (saturation > 0.5) & (value > 0.5);
        % Masker untuk warna oranye
        orangeMask = (hue > 0.05 & hue <= 0.15) & (saturation > 0.5) & (value > 0.5);
        % Masker untuk warna kuning
        yellowMask = (hue > 0.15 & hue <= 0.2) & (saturation > 0.5) & (value > 0.5);

        % Menggabungkan semua masker
        fireMask = redMask | orangeMask | yellowMask;

        % Menghitung persentase area merah, oranye, dan kuning dalam gambar
        totalPixels = numel(image(:,:,1));
        redPixels = sum(redMask(:));
        orangePixels = sum(orangeMask(:));
        yellowPixels = sum(yellowMask(:));
        firePixels = sum(fireMask(:));

        % Menghitung persentase masing-masing warna
        redPercentage = (redPixels / totalPixels) * 100;
        orangePercentage = (orangePixels / totalPixels) * 100;
        yellowPercentage = (yellowPixels / totalPixels) * 100;
        firePercentage = (firePixels / totalPixels) * 100;

        % Menampilkan hasil segmentasi warna api
        axes(hAxes2);
        imshow(fireMask);
        title(hAxes2, 'Segmentasi Warna Api');

        % Menampilkan hasil deteksi dengan memastikan adanya campuran warna
        if firePercentage > 20 && (redPercentage > 2 && orangePercentage > 2 || yellowPercentage > 1)
            set(hResult, 'String', 'Kebakaran terdeteksi!', 'ForegroundColor', 'r');
        elseif firePercentage > 5 && (redPercentage > 2 && orangePercentage > 2 || yellowPercentage > 1)
            set(hResult, 'String', 'Api terdeteksi, peringatan terjadi kebakaran!', 'ForegroundColor', 'y');
        else
            set(hResult, 'String', 'Tidak ada kebakaran.', 'ForegroundColor', 'g');
        end
    end
end