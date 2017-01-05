% MEDIANFILTERINGMULTISIZETILED
%   Make a tiled figure for thesis use where top left tile is raw image
%   data identified by path in INPUT_IMAGE, and columns 2-4 show median
%   filtered, median thresholded and denoised images using each kernel size
%   given by vector [MED_FILT_SIZES]. Resulting plots are spaced according
%   to PLOT_SPACE and fig and png files are saved to OUTPUT_PATH. 

function medianFilteringMultiSizeTiled(input_image, output_path, med_filt_sizes, plot_space)

%% Define variables if any arguments have been replacecd with []
if isempty(plot_space)
    plot_space = 0.01;
end

if isempty(med_filt_sizes)
    med_filt_sizes = [5 10 50 200];
end 

if isempty(input_image)
    [fname, pname, ~] = uigetfile('*.tif', 'Please choose a raw image to create a figure for...');
    input_image = [pname filesep fname];
end

if isempty(output_path)
    [fname, pname] = uiputfile('*.png', 'Please create a fileto output a figure to...');
    [~,fname,~] = fileparts(fname);
    output_path = [pname filesep fname];
end

%% Generate median filtered/thresholded/denoised images
im = imread(input_image);

medfiltims = zeros(size(im, 1), size(im, 2), length(med_filt_sizes));
threshims = zeros(size(im, 1), size(im, 2), length(med_filt_sizes));
denoisedims = zeros(size(im, 1), size(im, 2), length(med_filt_sizes));

for ind = 1:length(med_filt_sizes)
    
    medfiltims(:,:,ind) = medfilt2(im, [med_filt_sizes(ind) med_filt_sizes(ind)]);
    
    threshim = im;
    threshim(im < squeeze(medfiltims(:,:,ind))) = 0;
    threshims(:,:,ind) = threshim;
    
    binary_im = (threshim > 0);
    se = strel('disk', 1);
    binary_im = imerode(binary_im, se);
    binary_im = imdilate(binary_im, se);
    denoisedim = threshim;
    denoisedim(binary_im == 0) = 0;
    denoisedims(:,:,ind) = denoisedim;
    
    clear denoisedim;
    clear binary_im;
    clear threshim;

end

%% Generate output figure

% get display size in pix
dispSize = get(0, 'MonitorPositions');
dispSize = dispSize(3:end);

fig_pos = [1 1 (4/length(med_filt_sizes)) * min(dispSize) min(dispSize)]; % assume for now 4x4 tiling...
hfig = figure('Unit', 'pixels', 'Position', fig_pos);
plot_size = (1 - ((length(med_filt_sizes) + 1) * plot_space)) / (length(med_filt_sizes)); % plot sizes ALWAYS in normalised units

ax_inds_h = repmat(1:4, 1, length(med_filt_sizes));
ax_inds_v = repmat(1:length(med_filt_sizes), 4, 1);
ax_inds_v = ax_inds_v(:)';

for ax_ind = 1:4*length(med_filt_sizes)
    
        h(ax_ind) = subplot('Position', [ (((ax_inds_h(ax_ind) - 1) * plot_size) + ax_inds_h(ax_ind) * plot_space) (1 - (((ax_inds_v(ax_ind)) * plot_size) + ((ax_inds_v(ax_ind) ) * plot_space))) ...
            (plot_size) (plot_size) ]);
        imagesc(checkerboard(10));
        set(h(ax_ind), 'XTick', [], 'YTick', []);
        axis equal tight;

end
