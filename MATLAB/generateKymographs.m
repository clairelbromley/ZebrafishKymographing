function generateKymographs(imageStack, metadata)

    %% In temporary absence of metadata, set metadata for 
% import dimension metadata
framespersecond = 5;
umperpixel = 0.218;
scalebarum = 10;

% import cut position from metadata - add offset??
xoffset = -20;
yoffset = -20;
xcut = [213 276] + xoffset;
ycut = [279 308] + yoffset;
cut_theta = atan( ( ycut(2)-ycut(1) )/( xcut(2) - xcut(1) ) );

% generate maximum intensity kymographs - USE IMPROFILE!!!
kym_line_len = 50;
kym_line_width = 9;
num_kyms = 15;

end