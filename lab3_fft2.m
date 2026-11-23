%% Lab 3: Frequency-Domain Filtering with fft2
close all; clear; clc;

scriptFolder = fileparts(mfilename('fullpath'));
outputDir = fullfile(scriptFolder, 'screenshots');
if ~isfolder(outputDir)
    mkdir(outputDir);
end

if exist('peppers.png', 'file')
    I = im2double(rgb2gray(imread('peppers.png')));
else
    I = im2double(imread('cameraman.tif'));
end
[M, N] = size(I);

%% 1) Centered log-magnitude spectrum
F = fft2(I);
Fshift = fftshift(F);
S = log(1 + abs(Fshift));

fig = figure('Position', [100 100 1050 400]);
subplot(1,2,1);
imshow(I, [0 1]);
title('Original image');

subplot(1,2,2);
imshow(S, []);
title('Centered log-magnitude spectrum');

exportgraphics(fig, fullfile(outputDir, '01-spectrum.png'));

%% 2) Ideal and Gaussian low-pass masks
[u, v] = meshgrid(-floor(N/2):ceil(N/2)-1, ...
                  -floor(M/2):ceil(M/2)-1);
D = hypot(u, v);

D0 = 40;
sigma = 20;
H_ideal_LP = double(D <= D0);
H_gauss_LP = exp(-D.^2 / (2 * sigma^2));

fig = figure('Position', [100 100 1050 400]);
subplot(1,2,1);
imshow(H_ideal_LP, [0 1]);
title('Ideal low-pass, cutoff = 40 bins');

subplot(1,2,2);
imshow(H_gauss_LP, [0 1]);
title('Gaussian low-pass, sigma = 20 bins');

exportgraphics(fig, fullfile(outputDir, '02-masks.png'));

%% 3) Apply the low-pass filters
G_ideal = real(ifft2(ifftshift(H_ideal_LP .* Fshift)));
G_gauss = real(ifft2(ifftshift(H_gauss_LP .* Fshift)));

fig = figure('Position', [100 100 1200 400]);
subplot(1,3,1);
imshow(I, [0 1]);
title('Original');

subplot(1,3,2);
imshow(G_ideal, [0 1]);
title('Ideal low-pass');

subplot(1,3,3);
imshow(G_gauss, [0 1]);
title('Gaussian low-pass');

exportgraphics(fig, fullfile(outputDir, '03-low-pass.png'));

%% 4) Gaussian high-pass using the complement
H_gauss_HP = 1 - H_gauss_LP;
G_hp = real(ifft2(ifftshift(H_gauss_HP .* Fshift)));
hpLimit = max(max(abs(G_hp(:))), eps);

fig = figure('Position', [100 100 1050 400]);
subplot(1,2,1);
imshow(I, [0 1]);
title('Original');

subplot(1,2,2);
imshow(G_hp, [-hpLimit hpLimit]);
title('Gaussian high-pass');

exportgraphics(fig, fullfile(outputDir, '04-high-pass.png'));

%% 5) Compare spatial and FFT filtering with the same Gaussian kernel
g = fspecial('gaussian', [1 7], 1.2);
kernel = g' * g;

I_spatial = imfilter(I, kernel, 'circular', 'conv');
H_kernel = psf2otf(kernel, [M N]);
I_fft = real(ifft2(H_kernel .* F));

difference = I_spatial - I_fft;
rmse = sqrt(mean(difference(:).^2));
maxError = max(abs(difference(:)));

fprintf('Matched Gaussian RMSE: %.3e\n', rmse);
fprintf('Maximum absolute difference: %.3e\n', maxError);

fig = figure('Position', [100 100 1200 400]);
subplot(1,3,1);
imshow(I_spatial, [0 1]);
title('Spatial Gaussian');

subplot(1,3,2);
imshow(I_fft, [0 1]);
title('FFT Gaussian');

subplot(1,3,3);
imshow(abs(difference), [0 1]);
title('Absolute difference');

sgtitle(sprintf('RMSE = %.3e | Maximum difference = %.3e', ...
    rmse, maxError));

exportgraphics(fig, fullfile(outputDir, '05-comparison.png'));

%% 6) Reflection answers are in README.md
fprintf('Figures saved to %s\n', outputDir);