classdef Edges
    
    properties
        z = 0;                          % z plane in which edges are defined
        timepoint = 1;                  % timepoint for which edges are defined
        
        L = [];                         % left edge xy array
        R = [];                         % right edge xy array
        M = [];                         % midline xy array
        Rh4 = [];                       % rhombomere 4 edge xy array
        Rh6 = [];                       % rhombomere 6 edge xy array
        
        hlL = [];                       % handle for line overlaying left edge
        hlR = [];                       % handle for line overlaying right edge
        hlM = [];                       % handle for line overlaying midline
        hlRh4 = [];                     % handle for patch overlaying rhombomere 4
        hlRh6 = [];                     % handle for patch overlaying rhombomere 6
        
        tissueRotation = 0;             % angle to rotate image by to bring midline vertical
        rhombomereLimits = [0 0];       % y positions at extrema of rotated rhombomeres
        
%         rhombomere_width_mean = [];     % mean widths for rhombomeres 4 and 6
%         rhombomere_width_median = [];   % median widths for rhombomeres 4 and 6
%         rhombomere_length_mean = [];    % mean lengths for rhombomeres 4, 5 and 6;
%         rhombomere_length_median = [];  % median lengths for rhombomeres 4, 5 and 6;
        
        midlineSinuosity = 0;           % sinuosity index of midline
        midlineDefinition = [];
        basal_basal_distances = [];
        ap_lengths = [];
        
    end
    
end