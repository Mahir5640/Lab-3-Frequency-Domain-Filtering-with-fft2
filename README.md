# Lab 3 — Frequency-Domain Filtering with fft2

**Mahir Foysol Chowdhury**  
Mathematical Algorithms (DSP) — Image Processing Labs

## How to run

Open `lab3_fft2.m` in MATLAB with Image Processing Toolbox and click Run.
The script saves five PNG figures in the `screenshots` folder and prints
the Gaussian comparison errors in the Command Window.

## 1. Magnitude spectrum

The 2-D FFT represents the image in terms of spatial frequencies.
Applying `fftshift` moves the zero-frequency component to the center.
The log scale compresses the magnitude range so weaker components
are easier to see.

![Original image and centered log-magnitude spectrum](screenshots/01-spectrum.png)

## 2. Ideal and Gaussian low-pass filters

The ideal filter keeps frequencies within a radius of 40 bins and sets
frequencies outside that radius to zero. The Gaussian filter reduces
the weights smoothly with distance from the center, using a standard
deviation of 20 frequency bins.

![Ideal and Gaussian low-pass masks](screenshots/02-masks.png)

## 3. Low-pass filtering results

I multiplied the centered image spectrum by each filter mask and then
used the inverse FFT to reconstruct the filtered images. Both filters
smooth fine detail. The ideal filter's sharp cutoff can produce ripples
near strong edges. The Gaussian filter gives smoother transitions.

![Original and low-pass results](screenshots/03-low-pass.png)

## 4. Gaussian high-pass filtering

I formed the high-pass mask by subtracting the Gaussian low-pass mask
from one. This removes the zero-frequency component and emphasizes
edges and fine texture. In the high-pass display, mid-gray represents
a response near zero.

![Original and Gaussian high-pass result](screenshots/04-high-pass.png)

## 5. Spatial and frequency-domain Gaussian comparison

I used the same 7×7 Gaussian kernel with a standard deviation of
1.2 pixels and circular boundary handling in both methods. I used
`imfilter` for spatial convolution and `psf2otf` to obtain the same
kernel's frequency response for FFT multiplication.

The starter code used different Gaussian filters and boundary handling
for the two methods. Matching both settings makes this a direct check
of the convolution theorem. The RMSE and maximum absolute difference
shown in the figure should be close to zero, with any remaining
difference caused by floating-point rounding.

![Spatial result, FFT result, and absolute difference](screenshots/05-comparison.png)

## 6. Reflections

1. **Why does ideal low-pass filtering cause ringing?**  
   The sharp frequency cutoff creates an oscillating spatial filter
   response. Near strong image edges, this response can overshoot and
   undershoot, producing alternating bright and dark ripples.

2. **What does `fftshift` do visually?**  
   It moves the zero-frequency component from the corner to the center.
   The low frequencies appear around the center, and higher frequencies
   appear farther away. The frequency magnitudes are preserved.

3. **When is frequency-domain filtering computationally preferable?**  
   FFT filtering can be faster for large images with large kernels,
   especially when several filters reuse the same image FFT. For small
   or separable kernels, spatial filtering can be faster because it
   avoids the overhead of the FFT and inverse FFT.
